import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/presensi/presensi_record.dart';

part 'presensi_session_model.freezed.dart';
part 'presensi_session_model.g.dart';

enum SessionType {
  @JsonValue('KELAS')
  kelas,
  @JsonValue('UAS')
  uas,
  @JsonValue('EVENT')
  event,
}

@freezed
abstract class PresensiSessionModel with _$PresensiSessionModel {
  const factory PresensiSessionModel({
    required int id,
    required String title,
    @Default(SessionType.kelas) SessionType type,
    required DateTime date,
    @Default(true) bool isOpen,
    required String token,
    DateTime? deadlineAt,
    int? kelasPerkuliahanId,
    @Default([]) List<PresensiRecordModel> records,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PresensiSessionModel;

  factory PresensiSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PresensiSessionModelFromJson(json);
}
