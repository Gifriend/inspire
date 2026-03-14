import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/features/schedule/domain/services/schedule_service.dart';
import 'package:inspire/features/schedule/presentation/schedule_state.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleService _service;
  final Map<String, MonthlyScheduleModel> _monthCache = {};
  String? _activeRequestKey;

  ScheduleController(this._service) : super(const ScheduleState.initial());

  /// Load schedule for a given month/year.
  Future<void> loadSchedule({required int year, required int month}) async {
    final requestKey = '$year-$month';
    final cached = _monthCache[requestKey];
    if (cached != null) {
      state = ScheduleState.loaded(cached);
      return;
    }

    _activeRequestKey = requestKey;

    final shouldShowBlockingLoader = state.maybeWhen(
      initial: () => true,
      error: (_) => true,
      orElse: () => false,
    );

    if (shouldShowBlockingLoader) {
      state = const ScheduleState.loading();
    }

    try {
      final schedule =
          await _service.getMonthlySchedule(year: year, month: month);
      _monthCache[requestKey] = schedule;
      if (_activeRequestKey != requestKey) {
        return;
      }
      state = ScheduleState.loaded(schedule);
    } catch (e) {
      if (_activeRequestKey != requestKey) {
        return;
      }
      state = ScheduleState.error(e.toString());
    }
  }
}

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final service = ref.watch(scheduleServiceProvider);
  return ScheduleController(service);
});
