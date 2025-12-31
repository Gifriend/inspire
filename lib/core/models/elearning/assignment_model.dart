import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

@freezed
abstract class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required int id,
    required String title,
    String? description,
    required DateTime deadline,
    @Default(false) bool allowLate,
    required int sessionId,
    required DateTime createdAt,
    required DateTime updatedAt,
    SubmissionModel? submission, // Current user's submission if any
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}

@freezed
abstract class SubmissionModel with _$SubmissionModel {
  const factory SubmissionModel({
    required int id,
    required int studentId,
    required int assignmentId,
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
