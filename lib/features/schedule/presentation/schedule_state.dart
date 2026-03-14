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
