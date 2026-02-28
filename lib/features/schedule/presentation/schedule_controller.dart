import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/schedule/domain/services/schedule_service.dart';
import 'package:inspire/features/schedule/presentation/schedule_state.dart';

class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleService _service;

  ScheduleController(this._service) : super(const ScheduleState.initial());

  /// Load schedule for a given month/year.
  Future<void> loadSchedule({required int year, required int month}) async {
    state = const ScheduleState.loading();
    try {
      final schedule =
          await _service.getMonthlySchedule(year: year, month: month);
      state = ScheduleState.loaded(schedule);
    } catch (e) {
      state = ScheduleState.error(e.toString());
    }
  }
}

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  final service = ref.watch(scheduleServiceProvider);
  return ScheduleController(service);
});
