import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

enum TaskKategori {
  @JsonValue('TUGAS')
  tugas,
  @JsonValue('UTS')
  uts,
  @JsonValue('UAS')
  uas,
  @JsonValue('KUIS')
  kuis,
  @JsonValue('PARTISIPASI')
  partisipasi,
}

@freezed
abstract class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required String id,
    required String title,
    String? description,
    String? fileUrl,
    required DateTime deadline,
    @Default(false) bool allowLate,
    @Default(false) bool isHidden,
    @Default(TaskKategori.tugas) TaskKategori kategori,
    @Default(0.0) double bobot,
    required String sessionId,
    required DateTime createdAt,
    SubmissionModel? submission, // Current user's submission if any
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}

@freezed
abstract class SubmissionModel with _$SubmissionModel {
  const factory SubmissionModel({
    required String id,
    required int studentId,
    required String assignmentId,
    String? fileUrl,
    String? textContent,
    double? grade,
    String? feedback,
    required DateTime submittedAt,
    DateTime? gradedAt,
  }) = _SubmissionModel;

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionModelFromJson(json);
}
