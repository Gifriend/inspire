import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

enum QuizGradingMethod {
  @JsonValue('HIGHEST_GRADE')
  HIGHEST_GRADE,
  @JsonValue('AVERAGE_GRADE')
  AVERAGE_GRADE,
  @JsonValue('LATEST_GRADE')
  LATEST_GRADE,
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
    required String id,
    required String title,
    String? description,
    required int duration, // in minutes
    required DateTime startTime,
    required DateTime endTime,
    required QuizGradingMethod gradingMethod,
    required String sessionId,
    required DateTime createdAt,
    @Default([]) List<QuizQuestionModel> questions,
    @Default([]) List<QuizAttemptModel> attempts,
  }) = _QuizModel;

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}

@freezed
abstract class QuizQuestionModel with _$QuizQuestionModel {
  const factory QuizQuestionModel({
    required String id,
    required String text,
    required QuestionType type,
    @Default([]) List<String> options, 
    String? correctAnswer,
    required num points,
    String? quizId,
  }) = _QuizQuestionModel;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);
}

@freezed
abstract class QuizAttemptModel with _$QuizAttemptModel {
  const factory QuizAttemptModel({
    required String id,
    required int studentId,
    required String quizId,
    required num score,
    required DateTime startedAt,
    DateTime? finishedAt,
  }) = _QuizAttemptModel;

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);
}

@freezed
abstract class QuizAnswerModel with _$QuizAnswerModel {
  const factory QuizAnswerModel({
    required String questionId,
    required String answer,
  }) = _QuizAnswerModel;

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerModelFromJson(json);
}
