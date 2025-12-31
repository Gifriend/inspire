import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

enum QuizGradingMethod {
  @JsonValue('HIGHEST')
  HIGHEST,
  @JsonValue('AVERAGE')
  AVERAGE,
  @JsonValue('LATEST')
  LATEST,
}

enum QuestionType {
  @JsonValue('MULTIPLE_CHOICE')
  MULTIPLE_CHOICE,
  @JsonValue('TRUE_FALSE')
  TRUE_FALSE,
  @JsonValue('ESSAY')
  ESSAY,
}

@freezed
abstract class QuizModel with _$QuizModel {
  const factory QuizModel({
    required int id,
    required String title,
    required int duration, // in minutes
    required DateTime startTime,
    required DateTime endTime,
    required QuizGradingMethod gradingMethod,
    required int sessionId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<QuizQuestionModel> questions,
    @Default([]) List<QuizAttemptModel> attempts,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}

@freezed
abstract class QuizQuestionModel with _$QuizQuestionModel {
  const factory QuizQuestionModel({
    required int id,
    required String text,
    required QuestionType type,
    @Default([]) List<String> options, // For multiple choice
    required String correctAnswer,
    required double points,
    required int quizId,
  }) = _QuizQuestionModel;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);
}

@freezed
abstract class QuizAttemptModel with _$QuizAttemptModel {
  const factory QuizAttemptModel({
    required int id,
    required int studentId,
    required int quizId,
    required double score,
    required DateTime startedAt,
    DateTime? finishedAt,
  }) = _QuizAttemptModel;

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);
}

@freezed
abstract class QuizAnswerModel with _$QuizAnswerModel {
  const factory QuizAnswerModel({
    required int questionId,
    required String answer,
  }) = _QuizAnswerModel;

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerModelFromJson(json);
}
