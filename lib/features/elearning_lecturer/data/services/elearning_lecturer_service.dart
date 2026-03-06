import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/models.dart';

abstract class ElearningLecturerService {
  Future<List<CourseListModel>> getLecturerCourses();
  Future<CourseDetailModel> getCourseDetail(int kelasId);
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId);
  Future<List<SessionModel>> getCourseContent(int kelasId);
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId);
  Future<List<StudentInfoModel>> getCourseLeaderboard(int kelasId);
  Future<Map<String, dynamic>> setupClass({
    required int kelasPerkuliahanId,
    required ElearningSetupMode setupMode,
    int? sourceKelasPerkuliahanId,
    bool? isMergedClass,
    bool? cloneContentAsHidden,
  });
  Future<Map<String, dynamic>> mergeClasses({
    required int masterKelasPerkuliahanId,
    required List<int> memberKelasPerkuliahanIds,
  });
  Future<ElearningClassConfigModel> unmergeClass(int kelasId);
  Future<void> toggleVisibility({
    required ElearningEntityType entityType,
    required String entityId,
    required bool isHidden,
  });
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
    bool hideGrades = false,
    bool hideUntilDeadline = false,
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
          .map(
            (item) => StudentInfoModel.fromJson(item as Map<String, dynamic>),
          )
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
          .map(
            (item) => StudentInfoModel.fromJson(item as Map<String, dynamic>),
          )
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
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/elearning/setup/class/$kelasId',
      );

      if (response == null) {
        return null;
      }

      return ElearningClassConfigModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SessionModel>> getCourseContent(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/course/$kelasId',
      );

      if (response == null) {
        debugPrint('[DEBUG] getCourseContent: response is null');
        return [];
      }

      if (response is List) {
        debugPrint(
          '[DEBUG] getCourseContent: response is List with ${response.length} items',
        );
        return response
            .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final sessions = response['sessions'];
        if (sessions is List) {
          debugPrint(
            '[DEBUG] getCourseContent: response is Map with sessions List of ${sessions.length} items',
          );
          return sessions
              .map(
                (item) => SessionModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }

      debugPrint(
        '[DEBUG] getCourseContent: response is unknown format, returning empty',
      );
      return [];
    } catch (e) {
      debugPrint('[DEBUG] getCourseContent error: $e');
      throw Exception('Error loading course content: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> setupClass({
    required int kelasPerkuliahanId,
    required ElearningSetupMode setupMode,
    int? sourceKelasPerkuliahanId,
    bool? isMergedClass,
    bool? cloneContentAsHidden,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/elearning/setup/class',
        data: {
          'kelasPerkuliahanId': kelasPerkuliahanId,
          'setupMode': _setupModeToApiValue(setupMode),
          if (sourceKelasPerkuliahanId != null)
            'sourceKelasPerkuliahanId': sourceKelasPerkuliahanId,
          if (isMergedClass != null) 'isMergedClass': isMergedClass,
          if (cloneContentAsHidden != null)
            'cloneContentAsHidden': cloneContentAsHidden,
        },
      );

      if (response == null) {
        throw Exception('Gagal menyimpan pengaturan e-learning kelas');
      }

      return response;
    } catch (e) {
      throw Exception('Error setup kelas e-learning: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> mergeClasses({
    required int masterKelasPerkuliahanId,
    required List<int> memberKelasPerkuliahanIds,
  }) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/elearning/setup/merge',
        data: {
          'masterKelasPerkuliahanId': masterKelasPerkuliahanId,
          'memberKelasPerkuliahanIds': memberKelasPerkuliahanIds,
        },
      );

      if (response == null) {
        throw Exception('Gagal menyimpan penggabungan kelas e-learning');
      }

      return response;
    } catch (e) {
      throw Exception('Error merge kelas e-learning: $e');
    }
  }

  @override
  Future<ElearningClassConfigModel> unmergeClass(int kelasId) async {
    try {
      final response = await _dioClient.patch<Map<String, dynamic>>(
        '/elearning/setup/unmerge/$kelasId',
      );

      if (response == null) {
        throw Exception('Gagal memisahkan kelas e-learning');
      }

      return ElearningClassConfigModel.fromJson(response);
    } catch (e) {
      throw Exception('Error unmerge kelas e-learning: $e');
    }
  }

  @override
  Future<void> toggleVisibility({
    required ElearningEntityType entityType,
    required String entityId,
    required bool isHidden,
  }) async {
    try {
      await _dioClient.patch<Map<String, dynamic>>(
        '/elearning/setup/visibility',
        data: {
          'entityType': _entityTypeToApiValue(entityType),
          'entityId': entityId,
          'isHidden': isHidden,
        },
      );
    } catch (e) {
      throw Exception('Error mengatur visibilitas konten: $e');
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
          // Only include optional fields when they have a value to avoid
          // NestJS ValidationPipe rejecting explicit null properties.
          if (content != null) 'content': content,
          if (fileUrl != null) 'fileUrl': fileUrl,
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
    bool hideGrades = false,
    bool hideUntilDeadline = false,
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
          // Note: hideGrades / hideUntilDeadline are not in the backend DTO;
          // omit them to avoid a 400 from ValidationPipe.
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
        data: {'grade': grade, 'feedback': feedback},
      );
    } catch (e) {
      throw Exception('Error grading submission: $e');
    }
  }

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
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
          .map(
            (item) => QuizAttemptModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Error loading quiz attempts: $e');
    }
  }

  String _setupModeToApiValue(ElearningSetupMode mode) {
    switch (mode) {
      case ElearningSetupMode.newClass:
        return 'NEW';
      case ElearningSetupMode.existing:
        return 'EXISTING';
    }
  }

  String _entityTypeToApiValue(ElearningEntityType type) {
    switch (type) {
      case ElearningEntityType.material:
        return 'MATERIAL';
      case ElearningEntityType.assignment:
        return 'ASSIGNMENT';
      case ElearningEntityType.quiz:
        return 'QUIZ';
    }
  }
}

final elearningLecturerServiceProvider = Provider<ElearningLecturerService>((
  ref,
) {
  return ElearningLecturerServiceImpl(ref.watch(dioClientProvider));
});
