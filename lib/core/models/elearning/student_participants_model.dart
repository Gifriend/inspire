import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_participants_model.freezed.dart';
part 'student_participants_model.g.dart';

@freezed
abstract class StudentParticipant with _$StudentParticipant {
  const factory StudentParticipant({
    required int id,
    required String name,
    String? nim,
    String? photo,
  }) = _StudentParticipant;

  factory StudentParticipant.fromJson(Map<String, dynamic> json) =>
      _$StudentParticipantFromJson(json);
}

@freezed
abstract class DosenInfo with _$DosenInfo {
  const factory DosenInfo({
    required int id,
    required String name,
    String? nip,
    String? photo,
  }) = _DosenInfo;

  factory DosenInfo.fromJson(Map<String, dynamic> json) =>
      _$DosenInfoFromJson(json);
}

@freezed
abstract class StudentParticipantsData with _$StudentParticipantsData {
  const factory StudentParticipantsData({
    required int kelasId,
    @Default('') String namaKelas,
    @Default('') String kodeMK,
    @Default('') String namaMK,
    @Default(0) int sks,
    @Default('') String academicYear,
    required DosenInfo dosen,
    required int totalPeserta,
    required List<StudentParticipant> peserta,
  }) = _StudentParticipantsData;

  factory StudentParticipantsData.fromJson(Map<String, dynamic> json) =>
      _$StudentParticipantsDataFromJson(json);
}
