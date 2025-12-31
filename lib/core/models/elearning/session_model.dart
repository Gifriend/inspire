import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/material_model.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required int id,
    required String title,
    String? description,
    required int weekNumber,
    required int kelasPerkuliahanId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<MaterialModel> materials,
    @Default([]) List<AssignmentModel> assignments,
    @Default([]) List<QuizModel> quizzes,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}
