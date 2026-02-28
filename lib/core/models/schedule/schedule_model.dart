import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
abstract class ScheduleEventModel with _$ScheduleEventModel {
  const factory ScheduleEventModel({
    required String date,
    required String dayName,
    required String startTime,
    required String endTime,
    required String mataKuliah,
    required String kodeMK,
    required String kelas,
    String? ruangan,
    required String dosenNama,
    required String googleCalendarUrl,
  }) = _ScheduleEventModel;

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEventModelFromJson(json);
}

@freezed
abstract class MonthlyScheduleModel with _$MonthlyScheduleModel {
  const factory MonthlyScheduleModel({
    required int year,
    required int month,
    required String monthName,
    required String role,
    required int totalEvents,
    required List<ScheduleEventModel> events,
    required String icalUrl,
  }) = _MonthlyScheduleModel;

  factory MonthlyScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$MonthlyScheduleModelFromJson(json);
}
