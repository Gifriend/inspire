import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';

part 'quiz_state.freezed.dart';

@freezed
class QuizState with _$QuizState {
  const factory QuizState.initial() = _Initial;
  const factory QuizState.loading() = _Loading;
  const factory QuizState.loaded(QuizModel quiz) = _Loaded;
  const factory QuizState.taking(QuizModel quiz, Map<int, String> answers) = _Taking;
  const factory QuizState.submitting() = _Submitting;
  const factory QuizState.submitted(QuizAttemptModel attempt) = _Submitted;
  const factory QuizState.error(String message) = _Error;
}
