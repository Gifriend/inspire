import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/elearning/elearning_lecturer_models.dart';
import 'package:inspire/core/models/models.dart';

abstract class ElearningLecturerService {
  Future<List<CourseListModel>> getLecturerCourses();
  Future<CourseDetailModel> getCourseDetail(int kelasId);
  Future<List<SessionModel>> getCourseContent(int kelasId);
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId);
  Future<List<StudentInfoModel>> getCourseLeaderboard(int kelasId);
  Future<MaterialModel> createMaterial({
    required String title,
    required String type,
    String? content,
    String? fileUrl,
    required String sessionId,
  });
  
  Future<AssignmentModel> createAssignment({
    required String title,
    required String description,
    required DateTime deadline,
    required String sessionId,
  });

  Future<QuizModel> createQuiz({
    required String title,
    required int duration,
    required DateTime startTime,
    required DateTime endTime,
    required String gradingMethod,
    required String sessionId,
    required List<Map<String, dynamic>> questions,
  });

  Future<void> gradeSubmission({
    required String submissionId,
    required String grade,
    required String feedback,
  });

  Future<List<SubmissionModel>> getAssignmentSubmissions(String assignmentId);
  Future<SubmissionModel> getSubmissionDetail(String submissionId);
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId);
}

class ElearningLecturerServiceImpl implements ElearningLecturerService {
  final DioClient _dioClient;

  ElearningLecturerServiceImpl(this._dioClient);

  @override
  Future<List<CourseListModel>> getLecturerCourses() async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/lecturer/courses',
      );

      if (response == null) {
        return [];
      }

      final items = response;
      return items
          .map((item) => CourseListModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading lecturer courses: $e');
    }
  }

  @override
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId) async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/course/$kelasId/students',
      );

      if (response == null) {
        return [];
      }

      final items = response;
      return items
          .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading course students: $e');
    }
  }

  @override
  Future<List<StudentInfoModel>> getCourseLeaderboard(int kelasId) async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/course/$kelasId/leaderboard',
      );

      if (response == null) {
        return [];
      }

      final items = response;
      return items
          .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading course leaderboard: $e');
    }
  }

  @override
  Future<CourseDetailModel> getCourseDetail(int kelasId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/elearning/course-detail/$kelasId',
      );

      if (response == null) {
        throw Exception('Failed to load course detail');
      }

      return CourseDetailModel.fromJson(response);
    } catch (e) {
      throw Exception('Error loading course detail: $e');
    }
  }

  @override
  Future<List<SessionModel>> getCourseContent(int kelasId) async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/course/$kelasId',
      );

      if (response == null) {
        throw Exception('Failed to load course content');
      }

        final items = response;
        return items
          .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading course content: $e');
    }
  }

  @override
  Future<MaterialModel> createMaterial({
    required String title,
    required String type,
    String? content,
    String? fileUrl,
    required String sessionId,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/elearning/material',
        data: {
          'title': title,
          'type': type,
          'content': content,
          'fileUrl': fileUrl,
          'sessionId': sessionId,
        },
      );

      if (response == null) {
        throw Exception('Failed to create material');
      }

      return MaterialModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating material: $e');
    }
  }

  @override
  Future<AssignmentModel> createAssignment({
    required String title,
    required String description,
    required DateTime deadline,
    required String sessionId,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/elearning/assignment',
        data: {
          'title': title,
          'description': description,
          'deadline': deadline.toIso8601String(),
          'sessionId': sessionId,
        },
      );

      if (response == null) {
        throw Exception('Failed to create assignment');
      }

      return AssignmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating assignment: $e');
    }
  }

  @override
  Future<QuizModel> createQuiz({
    required String title,
    required int duration,
    required DateTime startTime,
    required DateTime endTime,
    required String gradingMethod,
    required String sessionId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/elearning/quiz',
        data: {
          'title': title,
          'duration': duration,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'gradingMethod': gradingMethod,
          'sessionId': sessionId,
          'questions': questions,
        },
      );

      if (response == null) {
        throw Exception('Failed to create quiz');
      }

      return QuizModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }

  @override
  Future<void> gradeSubmission({
    required String submissionId,
    required String grade,
    required String feedback,
  }) async {
    try {
      await _dioClient.patch(
        '/elearning/submission/$submissionId/grade',
        data: {
          'grade': grade,
          'feedback': feedback,
        },
      );
    } catch (e) {
      throw Exception('Error grading submission: $e');
    }
  }

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(
      String assignmentId) async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/assignment/$assignmentId/submissions',
      );

      if (response == null) {
        return [];
      }

        final items = response;
        return items
          .map((item) => SubmissionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading submissions: $e');
    }
  }

  @override
  Future<SubmissionModel> getSubmissionDetail(String submissionId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/elearning/submission/$submissionId',
      );

      if (response == null) {
        throw Exception('Submission not found');
      }

      return SubmissionModel.fromJson(response);
    } catch (e) {
      throw Exception('Error loading submission: $e');
    }
  }

  @override
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId) async {
    try {
      final response = await _dioClient.get<List>(
        '/elearning/quiz/$quizId/attempts',
      );

      if (response == null) {
        return [];
      }

        final items = response;
        return items
          .map((item) =>
            QuizAttemptModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading quiz attempts: $e');
    }
  }
}

final elearningLecturerServiceProvider =
    Provider<ElearningLecturerService>((ref) {
  return ElearningLecturerServiceImpl(ref.watch(dioClientProvider));
});
