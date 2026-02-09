import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/quiz_state.dart';

final quizControllerProvider =
    StateNotifierProvider.autoDispose<QuizController, QuizState>((ref) {
      return QuizController(ref.watch(elearningServiceProvider));
    });

class QuizController extends StateNotifier<QuizState> {
  final ElearningService _service;

  QuizController(this._service) : super(const QuizState.initial());

  void setAnswer(String questionId, String answer, QuizModel quiz) {
    state.maybeWhen(
      taking: (currentQuiz, answers) {
        final newAnswers = Map<String, String>.from(answers);
        newAnswers[questionId] = answer;
        state = QuizState.taking(currentQuiz, newAnswers);
      },
      orElse: () {
        state = QuizState.taking(quiz, {questionId: answer});
      },
    );
  }

  Future<void> submitQuiz(Map<String, dynamic> payload) async {
    try {
      final answers = (payload['answers'] as List<dynamic>).map((e) {
        final map = e as Map<String, dynamic>;
        return QuizAnswerModel(
          questionId: map['questionId'] as String,
          answer: map['answer'] as String,
        );
      }).toList();
      
      state.maybeWhen(
        taking: (quiz, answerMap) {
          answerMap.forEach((questionId, answer) {
            answers.add(
              QuizAnswerModel(questionId: questionId, answer: answer),
            );
          });
        },
        orElse: () {},
      );

      state = const QuizState.submitting();
      final attempt = await _service.submitQuiz(
        quizId: payload['quizId'] as String,
        answers: answers,
      );
      state = QuizState.submitted(attempt);
    } catch (e) {
      state = QuizState.error(e.toString());
    }
  }

  Future<void> loadQuizDetail(String id) async {
    try {
      state = const QuizState.loading();
      final quiz = await _service.getQuizDetail(id);
      state = QuizState.loaded(quiz);
    } catch (e) {
      state = QuizState.error(e.toString());
    }
  }
}
