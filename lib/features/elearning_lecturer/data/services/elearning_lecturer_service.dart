import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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
    String kategori,
    double bobot,
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
    String kategori,
    double bobot,
  });

  Future<ParticipationData> getParticipation(int kelasId);
  Future<RankingData> getRanking(int kelasId);

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
      final response = await _dioClient.get<dynamic>(
        '/elearning/lecturer/courses',
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<CourseListModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((item) => CourseListModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar kelas');
    }
  }

  @override
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/course/$kelasId/students',
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<StudentInfoModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar mahasiswa',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar mahasiswa');
    }
  }

  @override
  Future<List<StudentInfoModel>> getCourseLeaderboard(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/course/$kelasId/leaderboard',
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<StudentInfoModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat leaderboard',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat leaderboard');
    }
  }

  @override
  Future<CourseDetailModel> getCourseDetail(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/course-detail/$kelasId',
      );
      if (response == null) throw const ApiException(message: 'Data kelas kosong');
      return ApiEnvelope.fromDynamic<CourseDetailModel>(
        response,
        dataParser: (data) =>
            CourseDetailModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail kelas');
    }
  }

  @override
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/setup/class/$kelasId',
      );
      if (response == null) return null;
      return ApiEnvelope.fromDynamic<ElearningClassConfigModel?>(
        response,
        dataParser: (data) {
          if (data == null || (data is List && data.isEmpty)) return null;
          return ElearningClassConfigModel.fromJson(
              ApiEnvelope.parseSingleMap(data));
        },
        defaultMessage: 'Gagal memuat konfigurasi e-learning',
      ).data;
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
        if (response == null) return [];
        return ApiEnvelope.fromDynamic<List<SessionModel>>(
          response,
          dataParser: (data) => (data as List)
              .map((item) => SessionModel.fromJson(item as Map<String, dynamic>))
              .toList(),
          defaultMessage: 'Gagal memuat konten kelas',
        ).data;
    } catch (e) {
        throw ApiException.from(e, fallbackMessage: 'Gagal memuat konten kelas');
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
      final response = await _dioClient.post<dynamic>(
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
      if (response is! Map<String, dynamic>) {
        throw const ApiException(message: 'Gagal menyimpan pengaturan e-learning kelas');
      }
      return response;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menyimpan pengaturan e-learning kelas');
    }
  }

  @override
  Future<Map<String, dynamic>> mergeClasses({
    required int masterKelasPerkuliahanId,
    required List<int> memberKelasPerkuliahanIds,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        '/elearning/setup/merge',
        data: {
          'masterKelasPerkuliahanId': masterKelasPerkuliahanId,
          'memberKelasPerkuliahanIds': memberKelasPerkuliahanIds,
        },
      );
      if (response is! Map<String, dynamic>) {
        throw const ApiException(message: 'Gagal menyimpan penggabungan kelas e-learning');
      }
      return response;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menyimpan penggabungan kelas e-learning');
    }
  }

  @override
  Future<ElearningClassConfigModel> unmergeClass(int kelasId) async {
    try {
      final response = await _dioClient.patch<dynamic>(
        '/elearning/setup/unmerge/$kelasId',
      );
      if (response == null) throw const ApiException(message: 'Gagal memisahkan kelas e-learning');
      return ApiEnvelope.fromDynamic<ElearningClassConfigModel>(
        response,
        dataParser: (data) =>
            ElearningClassConfigModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memisahkan kelas e-learning',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memisahkan kelas e-learning');
    }
  }

  @override
  Future<void> toggleVisibility({
    required ElearningEntityType entityType,
    required String entityId,
    required bool isHidden,
  }) async {
    try {
      await _dioClient.patch<dynamic>(
        '/elearning/setup/visibility',
        data: {
          'entityType': _entityTypeToApiValue(entityType),
          'entityId': entityId,
          'isHidden': isHidden,
        },
      );
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal mengatur visibilitas konten');
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
      final response = await _dioClient.post<dynamic>(
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
      if (response == null) throw const ApiException(message: 'Gagal membuat materi');
      return ApiEnvelope.fromDynamic<MaterialModel>(
        response,
        dataParser: (data) =>
            MaterialModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membuat materi',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal membuat materi');
    }
  }

  @override
  Future<AssignmentModel> createAssignment({
    required String title,
    required String description,
    required DateTime deadline,
    required String sessionId,
    String kategori = 'TUGAS',
    double bobot = 0.0,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        '/elearning/assignment',
        data: {
          'title': title,
          'description': description,
          'deadline': deadline.toIso8601String(),
          'sessionId': sessionId,
          'kategori': kategori,
          'bobot': bobot,
        },
      );
      if (response == null) throw const ApiException(message: 'Gagal membuat tugas');
      return ApiEnvelope.fromDynamic<AssignmentModel>(
        response,
        dataParser: (data) =>
            AssignmentModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membuat tugas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal membuat tugas');
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
    String kategori = 'KUIS',
    double bobot = 0.0,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        '/elearning/quiz',
        data: {
          'title': title,
          'duration': duration,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'gradingMethod': gradingMethod,
          'sessionId': sessionId,
          'questions': questions,
          'kategori': kategori,
          'bobot': bobot,
        },
      );
      if (response == null) throw const ApiException(message: 'Gagal membuat kuis');
      return ApiEnvelope.fromDynamic<QuizModel>(
        response,
        dataParser: (data) =>
            QuizModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membuat kuis',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal membuat kuis');
    }
  }

  @override
  Future<ParticipationData> getParticipation(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/kelas/$kelasId/participation',
      );
      if (response == null) throw const ApiException(message: 'Data partisipasi kosong');
      return ApiEnvelope.fromDynamic<ParticipationData>(
        response,
        dataParser: (data) =>
            ParticipationData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat data partisipasi',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat data partisipasi');
    }
  }

  @override
  Future<RankingData> getRanking(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/kelas/$kelasId/ranking',
      );
      if (response == null) throw const ApiException(message: 'Data ranking kosong');
      return ApiEnvelope.fromDynamic<RankingData>(
        response,
        dataParser: (data) =>
            RankingData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat data ranking',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat data ranking');
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
      final response = await _dioClient.get<dynamic>(
        '/elearning/assignment/$assignmentId/submissions',
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<SubmissionModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((item) => SubmissionModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar submission',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar submission');
    }
  }

  @override
  Future<SubmissionModel> getSubmissionDetail(String submissionId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/submission/$submissionId',
      );
      if (response == null) throw const ApiException(message: 'Submission tidak ditemukan');
      return ApiEnvelope.fromDynamic<SubmissionModel>(
        response,
        dataParser: (data) =>
            SubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail submission',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail submission');
    }
  }

  @override
  Future<List<QuizAttemptModel>> getQuizAttempts(String quizId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        '/elearning/quiz/$quizId/attempts',
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<QuizAttemptModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((item) => QuizAttemptModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat percobaan kuis',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat percobaan kuis');
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
