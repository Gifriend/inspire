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

  // ─── Student — Participants & Grades ────────────────────────────────────────────────

  /// Daftar peserta (participants) yang terdaftar di suatu kelas.
  Future<StudentParticipantsData> getStudentParticipants(int kelasId) async {
    try {
      final data = await _dioClient.get(
        Endpoint.studentParticipants(kelasId),
      );

      return StudentParticipantsData.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Nilai & ranking mahasiswa sendiri dalam suatu kelas.
  Future<StudentGradesData> getStudentGrades(int kelasId) async {
    try {
      final data = await _dioClient.get(
        Endpoint.studentGrades(kelasId),
      );

      return StudentGradesData.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — Courses ─────────────────────────────────────────────────────────────

  /// Semua kelas yang diampu dosen yang sedang login.
  Future<List<LecturerCourseModel>> getLecturerCourses() async {
    try {
      final data = await _dioClient.get(Endpoint.lecturerCourses);
      if (data is List) {
        return data
            .map((json) => LecturerCourseModel.fromJson(json))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — Grading ────────────────────────────────────────────────────────────

  /// Daftar submission mahasiswa untuk sebuah tugas.
  Future<List<SubmissionWithStudentModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      final data =
          await _dioClient.get(Endpoint.assignmentSubmissions(assignmentId));
      if (data is List) {
        return data
            .map((json) => SubmissionWithStudentModel.fromJson(json))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Memberi nilai pada sebuah submission.
  Future<SubmissionModel> gradeSubmission(
    String submissionId,
    GradeSubmissionRequest request,
  ) async {
    try {
      final data = await _dioClient.patch(
        Endpoint.submissionGrade(submissionId),
        data: request.toJson(),
      );
      return SubmissionModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Daftar percobaan kuis oleh seluruh mahasiswa (view dosen).
  Future<List<QuizAttemptWithStudentModel>> getQuizAttempts(
    String quizId,
  ) async {
    try {
      final data = await _dioClient.get(Endpoint.quizAttempts(quizId));
      if (data is List) {
        return data
            .map((json) => QuizAttemptWithStudentModel.fromJson(json))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Detail satu submission (tanpa filter dosen).
  Future<SubmissionModel> getSubmissionDetail(String submissionId) async {
    try {
      final data =
          await _dioClient.get(Endpoint.submissionDetail(submissionId));
      return SubmissionModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — E-learning Setup ─────────────────────────────────────────────────────

  /// Konfigurasi e-learning tersimpan untuk sebuah kelas.
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId) async {
    try {
      final data = await _dioClient.get(Endpoint.elearningClassSetup(kelasId));
      if (data == null) return null;
      return ElearningClassConfigModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Simpan pilihan setup e-learning (NEW, EXISTING / clone, atau merge).
  Future<SetupElearningResultModel> setupClass(
    SetupElearningClassRequest request,
  ) async {
    try {
      final data = await _dioClient.post(
        Endpoint.elearningSetupClass,
        data: request.toJson(),
      );
      return SetupElearningResultModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Gabungkan beberapa kelas ke satu sumber e-learning.
  Future<MergeElearningResultModel> mergeClasses(
    MergeElearningClassesRequest request,
  ) async {
    try {
      final data = await _dioClient.post(
        Endpoint.elearningSetupMerge,
        data: request.toJson(),
      );
      return MergeElearningResultModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Pisahkan sebuah kelas dari gabungan e-learning.
  Future<ElearningClassConfigModel> unmergeClass(int kelasId) async {
    try {
      final data = await _dioClient.patch(
        Endpoint.elearningSetupUnmerge(kelasId),
      );
      return ElearningClassConfigModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Ubah visibilitas item (materi / tugas / kuis) per item.
  Future<void> toggleVisibility(ToggleVisibilityRequest request) async {
    try {
      await _dioClient.patch(
        Endpoint.elearningSetupVisibility,
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
