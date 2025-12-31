import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';
import 'package:inspire/features/elearning/data/repositories/elearning_repository.dart';

import '../../../../core/data_sources/network/dio_client.dart';

final elearningServiceProvider = Provider<ElearningService>((ref) {
  return ElearningService(
    ElearningRepository(ref.watch(dioClientProvider)),
  );
});

class ElearningService {
  final ElearningRepository _repository;

  ElearningService(this._repository);

  Future<List<CourseListModel>> getStudentCourses() async {
    try {
      return await _repository.getStudentCourses();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SessionModel>> getCourseContent(int kelasId) async {
    try {
      return await _repository.getCourseContent(kelasId);
    } catch (e) {
      rethrow;
    }
  }

  Future<SubmissionModel> submitAssignment({
    required int assignmentId,
    String? fileUrl,
    String? textContent,
  }) async {
    try {
      return await _repository.submitAssignment(
        assignmentId: assignmentId,
        fileUrl: fileUrl,
        textContent: textContent,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizAttemptModel> submitQuiz({
    required int quizId,
    required List<QuizAnswerModel> answers,
  }) async {
    try {
      return await _repository.submitQuiz(
        quizId: quizId,
        answers: answers,
      );
    } catch (e) {
      rethrow;
    }
  }
}
