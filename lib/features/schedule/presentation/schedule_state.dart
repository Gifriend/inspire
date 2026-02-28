import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/schedule/schedule_model.dart';

part 'schedule_state.freezed.dart';

@freezed
abstract class ScheduleState with _$ScheduleState {
  const factory ScheduleState.initial() = _Initial;
  const factory ScheduleState.loading() = _Loading;
  const factory ScheduleState.loaded(MonthlyScheduleModel schedule) = _Loaded;
  const factory ScheduleState.error(String message) = _Error;
}
