import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';
import 'package:inspire/core/models/elearning/material_model.dart';
import 'package:inspire/core/models/elearning/course_detail_model.dart';
import 'package:inspire/core/models/elearning/elearning_class_config_model.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';
import 'package:inspire/core/models/elearning/student_participants_model.dart';
import 'package:inspire/core/models/elearning/student_grades_model.dart';
import 'package:inspire/core/data_sources/network/network.dart';

class ElearningRepository {
  final DioClient _dioClient;

  ElearningRepository(this._dioClient);

  // Get student's enrolled courses
  Future<List<CourseListModel>> getStudentCourses() async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.studentCourses,
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<CourseListModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((json) => CourseListModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar mata kuliah',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar mata kuliah');
    }
  }

  // Get course content (all sessions with materials, assignments, quizzes)
  Future<List<SessionModel>> getCourseContent(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.courseContent(kelasId),
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<SessionModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat konten mata kuliah',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat konten mata kuliah');
    }
  }

  // Submit assignment
  Future<SubmissionModel> submitAssignment({
    required int assignmentId,
    String? fileUrl,
    String? textContent,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.assignmentSubmit,
        data: {
          'assignmentId': assignmentId,
          'fileUrl': fileUrl,
          'textContent': textContent,
        },
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<SubmissionModel>(
        response,
        dataParser: (data) =>
            SubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal mengirim tugas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal mengirim tugas');
    }
  }

  // Submit quiz
  Future<QuizAttemptModel> submitQuiz({
    required String quizId,
    required List<QuizAnswerModel> answers,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.quizSubmit,
        data: {
          'quizId': quizId,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<QuizAttemptModel>(
        response,
        dataParser: (data) =>
            QuizAttemptModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal mengirim jawaban kuis',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal mengirim jawaban kuis');
    }
  }

  // Get assignment detail with submission status
  Future<AssignmentModel> getAssignmentDetail(String id) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.assignmentDetail(id),
      );
      if (response == null) throw const ApiException(message: 'Data tugas kosong');
      return ApiEnvelope.fromDynamic<AssignmentModel>(
        response,
        dataParser: (data) =>
            AssignmentModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail tugas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail tugas');
    }
  }

  // Get quiz detail with questions & attempts
  Future<QuizModel> getQuizDetail(String id) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.quizDetail(id),
      );
      if (response == null) throw const ApiException(message: 'Data kuis kosong');
      return ApiEnvelope.fromDynamic<QuizModel>(
        response,
        dataParser: (data) =>
            QuizModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail kuis',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail kuis');
    }
  }

  // Get material detail
  Future<MaterialModel> getMaterialDetail(String id) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.materialDetail(id),
      );
      if (response == null) throw const ApiException(message: 'Data materi kosong');
      return ApiEnvelope.fromDynamic<MaterialModel>(
        response,
        dataParser: (data) =>
            MaterialModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail materi',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail materi');
    }
  }

  // Get course detail with complete information
  Future<CourseDetailModel> getCourseDetail(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.courseDetail(kelasId),
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

  // ─── Student — Participants & Grades ────────────────────────────────────────────────

  /// Daftar peserta (participants) yang terdaftar di suatu kelas.
  Future<StudentParticipantsData> getStudentParticipants(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.studentParticipants(kelasId),
      );
      if (response == null) throw const ApiException(message: 'Data peserta kosong');
      return ApiEnvelope.fromDynamic<StudentParticipantsData>(
        response,
        dataParser: (data) =>
            StudentParticipantsData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat daftar peserta',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar peserta');
    }
  }

  /// Nilai & ranking mahasiswa sendiri dalam suatu kelas.
  Future<StudentGradesData> getStudentGrades(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.studentGrades(kelasId),
      );
      if (response == null) throw const ApiException(message: 'Data nilai kosong');
      return ApiEnvelope.fromDynamic<StudentGradesData>(
        response,
        dataParser: (data) =>
            StudentGradesData.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat nilai',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat nilai');
    }
  }

  // ─── Lecturer — Courses ─────────────────────────────────────────────────────────────

  /// Semua kelas yang diampu dosen yang sedang login.
  Future<List<LecturerCourseModel>> getLecturerCourses() async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.lecturerCourses,
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<LecturerCourseModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((json) => LecturerCourseModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar kelas dosen',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar kelas dosen');
    }
  }

  // ─── Lecturer — Grading ────────────────────────────────────────────────────────────

  /// Daftar submission mahasiswa untuk sebuah tugas.
  Future<List<SubmissionWithStudentModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.assignmentSubmissions(assignmentId),
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<SubmissionWithStudentModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((json) =>
                SubmissionWithStudentModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat daftar submission',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar submission');
    }
  }

  /// Memberi nilai pada sebuah submission.
  Future<SubmissionModel> gradeSubmission(
    String submissionId,
    GradeSubmissionRequest request,
  ) async {
    try {
      final response = await _dioClient.patch<dynamic>(
        Endpoint.submissionGrade(submissionId),
        data: request.toJson(),
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<SubmissionModel>(
        response,
        dataParser: (data) =>
            SubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memberi nilai',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memberi nilai');
    }
  }

  /// Daftar percobaan kuis oleh seluruh mahasiswa (view dosen).
  Future<List<QuizAttemptWithStudentModel>> getQuizAttempts(
    String quizId,
  ) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.quizAttempts(quizId),
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<QuizAttemptWithStudentModel>>(
        response,
        dataParser: (data) => (data as List)
            .map((json) =>
                QuizAttemptWithStudentModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        defaultMessage: 'Gagal memuat percobaan kuis',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat percobaan kuis');
    }
  }

  /// Detail satu submission (tanpa filter dosen).
  Future<SubmissionModel> getSubmissionDetail(String submissionId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.submissionDetail(submissionId),
      );
      if (response == null) throw const ApiException(message: 'Data submission kosong');
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

  // ─── Lecturer — E-learning Setup ─────────────────────────────────────────────────────

  /// Konfigurasi e-learning tersimpan untuk sebuah kelas.
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.elearningClassSetup(kelasId),
      );
      if (response == null) return null;
      return ApiEnvelope.fromDynamic<ElearningClassConfigModel?>(
        response,
        dataParser: (data) {
          if (data == null) return null;
          if (data is List && data.isEmpty) return null;
          return ElearningClassConfigModel.fromJson(
              ApiEnvelope.parseSingleMap(data));
        },
        defaultMessage: 'Gagal memuat konfigurasi e-learning',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat konfigurasi e-learning');
    }
  }

  /// Simpan pilihan setup e-learning (NEW, EXISTING / clone, atau merge).
  Future<SetupElearningResultModel> setupClass(
    SetupElearningClassRequest request,
  ) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.elearningSetupClass,
        data: request.toJson(),
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<SetupElearningResultModel>(
        response,
        dataParser: (data) =>
            SetupElearningResultModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menyimpan setup e-learning',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menyimpan setup e-learning');
    }
  }

  /// Gabungkan beberapa kelas ke satu sumber e-learning.
  Future<MergeElearningResultModel> mergeClasses(
    MergeElearningClassesRequest request,
  ) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.elearningSetupMerge,
        data: request.toJson(),
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<MergeElearningResultModel>(
        response,
        dataParser: (data) =>
            MergeElearningResultModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menggabungkan kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menggabungkan kelas');
    }
  }

  /// Pisahkan sebuah kelas dari gabungan e-learning.
  Future<ElearningClassConfigModel> unmergeClass(int kelasId) async {
    try {
      final response = await _dioClient.patch<dynamic>(
        Endpoint.elearningSetupUnmerge(kelasId),
      );
      if (response == null) throw const ApiException(message: 'Respons kosong');
      return ApiEnvelope.fromDynamic<ElearningClassConfigModel>(
        response,
        dataParser: (data) =>
            ElearningClassConfigModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memisahkan kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memisahkan kelas');
    }
  }

  /// Ubah visibilitas item (materi / tugas / kuis) per item.
  Future<void> toggleVisibility(ToggleVisibilityRequest request) async {
    try {
      await _dioClient.patch<dynamic>(
        Endpoint.elearningSetupVisibility,
        data: request.toJson(),
      );
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal mengubah visibilitas');
    }
  }
}
