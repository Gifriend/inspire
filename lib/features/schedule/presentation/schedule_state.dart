import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/holiday/holiday_model.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';

part 'schedule_state.freezed.dart';

enum ScheduleStatus { initial, loading, loaded, error }

@freezed
abstract class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    required ScheduleStatus status,
    required DateTime focusedMonth,
    DateTime? selectedDay,
    MonthlyScheduleModel? schedule,
    @Default(<String, HolidayModel>{}) Map<String, HolidayModel> holidays,
    @Default(<int>{}) Set<int> loadedHolidayYears,
    String? errorMessage,
  }) = _ScheduleState;

  factory ScheduleState.initial() {
    final now = DateTime.now();
    return ScheduleState(
      status: ScheduleStatus.initial,
      focusedMonth: DateTime(now.year, now.month),
    );
  }
}

extension ScheduleStateMaybeWhenX on ScheduleState {
  T maybeWhen<T>({
    T Function(ScheduleState state)? initial,
    T Function(ScheduleState state)? loading,
    T Function(MonthlyScheduleModel schedule, ScheduleState state)? loaded,
    T Function(String message, ScheduleState state)? error,
    required T Function() orElse,
  }) {
    switch (status) {
      case ScheduleStatus.initial:
        return initial != null ? initial(this) : orElse();
      case ScheduleStatus.loading:
        return loading != null ? loading(this) : orElse();
      case ScheduleStatus.loaded:
        if (schedule != null && loaded != null) {
          return loaded(schedule!, this);
        }
        return orElse();
      case ScheduleStatus.error:
        final message = errorMessage ?? 'Gagal memuat jadwal';
        return error != null ? error(message, this) : orElse();
    }
  }
}
