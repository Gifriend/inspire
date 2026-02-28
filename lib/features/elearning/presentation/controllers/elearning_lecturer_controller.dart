import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/elearning_lecturer_state.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

/// Daftar submission mahasiswa per tugas — state terpisah per [assignmentId].
final assignmentSubmissionsControllerProvider = StateNotifierProvider.autoDispose
    .family<AssignmentSubmissionsController, AssignmentSubmissionsState, String>(
  (ref, assignmentId) {
    keepAliveFor(ref, const Duration(minutes: 5));
    return AssignmentSubmissionsController(
      ref.watch(elearningServiceProvider),
      assignmentId,
    );
  },
);

/// Daftar percobaan kuis per kuis — state terpisah per [quizId].
final quizAttemptsControllerProvider = StateNotifierProvider.autoDispose
    .family<QuizAttemptsController, QuizAttemptsState, String>(
  (ref, quizId) {
    keepAliveFor(ref, const Duration(minutes: 5));
    return QuizAttemptsController(ref.watch(elearningServiceProvider), quizId);
  },
);

// ─── AssignmentSubmissionsController ─────────────────────────────────────────

/// Mengelola daftar submission dan operasi pemberian nilai.
class AssignmentSubmissionsController
    extends StateNotifier<AssignmentSubmissionsState> {
  final ElearningService _service;
  final String assignmentId;

  AssignmentSubmissionsController(this._service, this.assignmentId)
      : super(const AssignmentSubmissionsState.initial());

  /// Memuat seluruh submission mahasiswa untuk tugas ini.
  Future<void> loadSubmissions() async {
    try {
      state = const AssignmentSubmissionsState.loading();
      final submissions =
          await _service.getAssignmentSubmissions(assignmentId);
      state = AssignmentSubmissionsState.loaded(submissions);
    } catch (e) {
      state = AssignmentSubmissionsState.error(e.toString());
    }
  }

  /// Memberi nilai pada satu submission, lalu memperbarui daftar secara lokal.
  Future<bool> gradeSubmission(
    String submissionId,
    GradeSubmissionRequest request,
  ) async {
    final prevSubmissions =
        state.whenOrNull(loaded: (submissions) => submissions);
    try {
      state = const AssignmentSubmissionsState.grading();
      await _service.gradeSubmission(submissionId, request);

      // Perbarui item yang di-grade langsung di state lokal agar tidak
      // perlu round-trip ke server.
      if (prevSubmissions != null) {
        final updated = prevSubmissions.map((s) {
          return s.id == submissionId
              ? s.copyWith(grade: request.grade, feedback: request.feedback)
              : s;
        }).toList();
        state = AssignmentSubmissionsState.loaded(updated);
      } else {
        await loadSubmissions();
      }

      state = const AssignmentSubmissionsState.graded('Nilai berhasil disimpan');
      return true;
    } catch (e) {
      state = AssignmentSubmissionsState.error(e.toString());
      return false;
    }
  }

  void resetToInitial() => state = const AssignmentSubmissionsState.initial();
}

// ─── QuizAttemptsController ───────────────────────────────────────────────────

/// Memuat daftar percobaan kuis oleh seluruh mahasiswa (read-only untuk dosen).
class QuizAttemptsController extends StateNotifier<QuizAttemptsState> {
  final ElearningService _service;
  final String quizId;

  QuizAttemptsController(this._service, this.quizId)
      : super(const QuizAttemptsState.initial());

  Future<void> loadAttempts() async {
    try {
      state = const QuizAttemptsState.loading();
      final attempts = await _service.getQuizAttempts(quizId);
      state = QuizAttemptsState.loaded(attempts);
    } catch (e) {
      state = QuizAttemptsState.error(e.toString());
    }
  }
}
