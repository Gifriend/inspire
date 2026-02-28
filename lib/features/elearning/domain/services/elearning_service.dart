import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';
import 'package:inspire/core/models/elearning/material_model.dart';
import 'package:inspire/core/models/elearning/course_detail_model.dart';
import 'package:inspire/core/models/elearning/elearning_class_config_model.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';
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
    required String quizId,
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

  Future<AssignmentModel> getAssignmentDetail(String id) async {
    try {
      return await _repository.getAssignmentDetail(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizModel> getQuizDetail(String id) async {
    try {
      return await _repository.getQuizDetail(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<MaterialModel> getMaterialDetail(String id) async {
    try {
      return await _repository.getMaterialDetail(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseDetailModel> getCourseDetail(int kelasId) async {
    try {
      return await _repository.getCourseDetail(kelasId);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — Courses ─────────────────────────────────────────────────────────────

  /// Kelas yang diampu dosen yang sedang login (dengan konfig e-learning).
  Future<List<LecturerCourseModel>> getLecturerCourses() async {
    try {
      return await _repository.getLecturerCourses();
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — Grading ────────────────────────────────────────────────────────────

  /// Daftar submission mahasiswa untuk satu tugas.
  Future<List<SubmissionWithStudentModel>> getAssignmentSubmissions(
    String assignmentId,
  ) async {
    try {
      return await _repository.getAssignmentSubmissions(assignmentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Memberi nilai pada satu submission.
  Future<SubmissionModel> gradeSubmission(
    String submissionId,
    GradeSubmissionRequest request,
  ) async {
    try {
      return await _repository.gradeSubmission(submissionId, request);
    } catch (e) {
      rethrow;
    }
  }

  /// Daftar semua percobaan kuis oleh mahasiswa (view dosen).
  Future<List<QuizAttemptWithStudentModel>> getQuizAttempts(
    String quizId,
  ) async {
    try {
      return await _repository.getQuizAttempts(quizId);
    } catch (e) {
      rethrow;
    }
  }

  /// Detail satu submission.
  Future<SubmissionModel> getSubmissionDetail(String submissionId) async {
    try {
      return await _repository.getSubmissionDetail(submissionId);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Lecturer — E-learning Setup ─────────────────────────────────────────────────────

  /// Konfigurasi e-learning tersimpan untuk sebuah kelas.
  Future<ElearningClassConfigModel?> getClassSetup(int kelasId) async {
    try {
      return await _repository.getClassSetup(kelasId);
    } catch (e) {
      rethrow;
    }
  }

  /// Simpan pilihan setup e-learning (NEW, EXISTING / clone, atau merge).
  Future<SetupElearningResultModel> setupClass(
    SetupElearningClassRequest request,
  ) async {
    try {
      return await _repository.setupClass(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Gabungkan beberapa kelas ke satu sumber e-learning.
  Future<MergeElearningResultModel> mergeClasses(
    MergeElearningClassesRequest request,
  ) async {
    try {
      return await _repository.mergeClasses(request);
    } catch (e) {
      rethrow;
    }
  }

  /// Pisahkan kelas dari gabungan e-learning.
  Future<ElearningClassConfigModel> unmergeClass(int kelasId) async {
    try {
      return await _repository.unmergeClass(kelasId);
    } catch (e) {
      rethrow;
    }
  }

  /// Sembunyikan / tampilkan item (materi / tugas / kuis) secara individual.
  Future<void> toggleVisibility(ToggleVisibilityRequest request) async {
    try {
      return await _repository.toggleVisibility(request);
    } catch (e) {
      rethrow;
    }
  }
}
