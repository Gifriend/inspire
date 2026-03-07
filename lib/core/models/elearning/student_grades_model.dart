import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_grades_model.freezed.dart';
part 'student_grades_model.g.dart';

@freezed
abstract class GradeDetailTugas with _$GradeDetailTugas {
  const factory GradeDetailTugas({
    required String id,
    required String title,
    @Default('TUGAS') String kategori,
    @Default(0.0) double bobot,
    required DateTime deadline,
    @Default(0) int pertemuan,
    @Default(false) bool submitted,
    double? nilai,
    String? feedback,
    DateTime? submittedAt,
    @Default(0.0) double kontribusi,
  }) = _GradeDetailTugas;

  factory GradeDetailTugas.fromJson(Map<String, dynamic> json) =>
      _$GradeDetailTugasFromJson(json);
}

@freezed
abstract class GradeDetailKuis with _$GradeDetailKuis {
  const factory GradeDetailKuis({
    required String id,
    required String title,
    @Default('KUIS') String kategori,
    @Default(0.0) double bobot,
    @Default(0.0) double maxPoints,
    @Default(0) int pertemuan,
    @Default(false) bool attempted,
    double? score,
    double? scorePercentage,
    DateTime? finishedAt,
    @Default(0.0) double kontribusi,
  }) = _GradeDetailKuis;

  factory GradeDetailKuis.fromJson(Map<String, dynamic> json) =>
      _$GradeDetailKuisFromJson(json);
}

@freezed
abstract class StudentGradesData with _$StudentGradesData {
  const factory StudentGradesData({
    required int kelasId,
    @Default('') String namaKelas,
    @Default('') String kodeMK,
    @Default('') String namaMK,
    @Default(0) int sks,
    @Default('') String academicYear,
    @Default('') String dosenNama,
    @Default(0.0) double totalBobot,
    @Default(0.0) double totalNilai,
    @Default(0) int peringkat,
    @Default(0) int totalPeserta,
    String? catatan,
    required List<GradeDetailTugas> detailTugas,
    required List<GradeDetailKuis> detailKuis,
  }) = _StudentGradesData;

  factory StudentGradesData.fromJson(Map<String, dynamic> json) =>
      _$StudentGradesDataFromJson(json);
}
