import 'package:inspire/core/constants/endpoint/endpoint.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';
import 'package:inspire/core/models/elearning/material_model.dart';
import 'package:inspire/core/models/elearning/course_detail_model.dart';
import '../../../../core/data_sources/network/dio_client.dart';

class ElearningRepository {
  final DioClient _dioClient;

  ElearningRepository(this._dioClient);

  // Get student's enrolled courses
  Future<List<CourseListModel>> getStudentCourses() async {
    try {
      final data = await _dioClient.get(Endpoint.studentCourses);
      
      if (data is List) {
        return data.map((json) => CourseListModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get course content (all sessions with materials, assignments, quizzes)
  Future<List<SessionModel>> getCourseContent(int kelasId) async {
    try {
      final data = await _dioClient.get(
        Endpoint.courseContent(kelasId),
      );

      if (data is List) {
        return data.map((json) => SessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Submit assignment
  Future<SubmissionModel> submitAssignment({
    required int assignmentId,
    String? fileUrl,
    String? textContent,
  }) async {
    try {
      final data = await _dioClient.post(
        Endpoint.assignmentSubmit,
        data: {
          'assignmentId': assignmentId,
          'fileUrl': fileUrl,
          'textContent': textContent,
        },
      );

      return SubmissionModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Submit quiz
  Future<QuizAttemptModel> submitQuiz({
    required String quizId,
    required List<QuizAnswerModel> answers,
  }) async {
    try {
      final data = await _dioClient.post(
        Endpoint.quizSubmit,
        data: {
          'quizId': quizId,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );

      return QuizAttemptModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get assignment detail with submission status
  Future<AssignmentModel> getAssignmentDetail(String id) async {
    try {
      final data = await _dioClient.get(
        Endpoint.assignmentDetail(id),
      );

      return AssignmentModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get quiz detail with questions & attempts
  Future<QuizModel> getQuizDetail(String id) async {
    try {
      final data = await _dioClient.get(
        Endpoint.quizDetail(id),
      );

      return QuizModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get material detail
  Future<MaterialModel> getMaterialDetail(String id) async {
    try {
      final data = await _dioClient.get(
        Endpoint.materialDetail(id),
      );

      return MaterialModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get course detail with complete information
  Future<CourseDetailModel> getCourseDetail(int kelasId) async {
    try {
      final data = await _dioClient.get(
        Endpoint.courseDetail(kelasId),
      );

      return CourseDetailModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
