import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/features/elearning_lecturer/data/services/elearning_lecturer_service.dart';
import 'elearning_lecturer_state.dart';
import 'package:flutter/foundation.dart';

final elearningLecturerControllerProvider =
    StateNotifierProvider<ElearningLecturerController, ElearningLecturerState>(
      (ref) => ElearningLecturerController(
        ref.watch(elearningLecturerServiceProvider),
      ),
    );

class ElearningLecturerController
    extends StateNotifier<ElearningLecturerState> {
  final ElearningLecturerService _service;

  ElearningLecturerController(this._service)
    : super(const ElearningLecturerInitial());

  Future<void> loadLecturerCourses() async {
    state = const ElearningLecturerLoading();
    try {
      final courses = await _service.getLecturerCourses();
      state = CourseListLoaded(courses);
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadCourseDetail(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final courseDetail = await _service.getCourseDetail(kelasId);
      final setupConfig = await _service.getClassSetup(kelasId);
      final lecturerCourses = await _service.getLecturerCourses();

      // Primary: Use sessions from courseDetail response
      var sessions = courseDetail.sessions;
      debugPrint('[DEBUG] courseDetail.sessions count: ${sessions.length}');

      // Fallback: If courseDetail.sessions is empty, try to fetch from dedicated endpoint
      if (sessions.isEmpty) {
        try {
          sessions = await _service.getCourseContent(kelasId);
          debugPrint(
            '[DEBUG] Fallback to getCourseContent: ${sessions.length} sessions',
          );
        } catch (e) {
          debugPrint('[DEBUG] getCourseContent also failed: $e');
          // Continue with empty sessions
        }
      }

      debugPrint('[DEBUG] Final sessions count: ${sessions.length}');
      state = CourseDetailLoaded(
        courseDetail,
        sessions,
        setupConfig: setupConfig,
        lecturerCourses: lecturerCourses,
      );
    } catch (e) {
      debugPrint('[DEBUG] loadCourseDetail error: $e');
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> setupClass({
    required int kelasPerkuliahanId,
    required ElearningSetupMode setupMode,
    int? sourceKelasPerkuliahanId,
    bool? isMergedClass,
    bool? cloneContentAsHidden,
  }) async {
    try {
      final response = await _service.setupClass(
        kelasPerkuliahanId: kelasPerkuliahanId,
        setupMode: setupMode,
        sourceKelasPerkuliahanId: sourceKelasPerkuliahanId,
        isMergedClass: isMergedClass,
        cloneContentAsHidden: cloneContentAsHidden,
      );

      final message =
          (response['message'] as String?) ??
          'Pengaturan e-learning kelas berhasil disimpan';
      state = SetupClassSaved(message);
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> mergeClasses({
    required int masterKelasPerkuliahanId,
    required List<int> memberKelasPerkuliahanIds,
  }) async {
    try {
      final response = await _service.mergeClasses(
        masterKelasPerkuliahanId: masterKelasPerkuliahanId,
        memberKelasPerkuliahanIds: memberKelasPerkuliahanIds,
      );

      final message =
          (response['message'] as String?) ??
          'Penggabungan kelas e-learning berhasil disimpan';
      state = MergeClassesSaved(message);
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> unmergeClass(int kelasPerkuliahanId) async {
    try {
      await _service.unmergeClass(kelasPerkuliahanId);
      state = const UnmergeClassSaved();
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> toggleVisibility({
    required ElearningEntityType entityType,
    required String entityId,
    required bool isHidden,
  }) async {
    try {
      await _service.toggleVisibility(
        entityType: entityType,
        entityId: entityId,
        isHidden: isHidden,
      );
      state = const VisibilityUpdated();
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadCourseStudents(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final students = await _service.getCourseStudents(kelasId);
      state = StudentsLoaded(students);
    } catch (e) {
      debugPrint('[DEBUG] loadCourseStudents error: $e');
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadCourseLeaderboard(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final leaderboard = await _service.getCourseLeaderboard(kelasId);
      state = LeaderboardLoaded(leaderboard);
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> createMaterial({
    required String title,
    required String type,
    String? content,
    String? fileUrl,
    required String sessionId,
  }) async {
    try {
      await _service.createMaterial(
        title: title,
        type: type,
        content: content,
        fileUrl: fileUrl,
        sessionId: sessionId,
      );
      state = const MaterialCreated();
      // Reload data after creation
      // state = const ElearningLecturerLoading();
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> createAssignment({
    required String title,
    required String description,
    required DateTime deadline,
    required String sessionId,
  }) async {
    try {
      await _service.createAssignment(
        title: title,
        description: description,
        deadline: deadline,
        sessionId: sessionId,
      );
      state = const AssignmentCreated();
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> createQuiz({
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
      await _service.createQuiz(
        title: title,
        duration: duration,
        startTime: startTime,
        endTime: endTime,
        gradingMethod: gradingMethod,
        hideGrades: hideGrades,
        hideUntilDeadline: hideUntilDeadline,
        sessionId: sessionId,
        questions: questions,
      );
      state = const QuizCreated();
    } catch (e) {
      state = ElearningLecturerError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadSubmissions(String assignmentId) async {
    state = const ElearningLecturerLoading();
    try {
      final submissions = await _service.getAssignmentSubmissions(assignmentId);
      state = SubmissionsLoaded(submissions);
    } catch (e) {
      state = ElearningLecturerError(e.toString());
    }
  }

  Future<void> gradeSubmission({
    required String submissionId,
    required String grade,
    required String feedback,
  }) async {
    try {
      await _service.gradeSubmission(
        submissionId: submissionId,
        grade: grade,
        feedback: feedback,
      );
      state = const SubmissionGraded();
    } catch (e) {
      state = ElearningLecturerError(e.toString());
    }
  }

  Future<void> loadQuizAttempts(String quizId) async {
    state = const ElearningLecturerLoading();
    try {
      final attempts = await _service.getQuizAttempts(quizId);
      state = QuizAttemptsLoaded(attempts);
    } catch (e) {
      state = ElearningLecturerError(e.toString());
    }
  }

  void resetState() {
    state = const ElearningLecturerInitial();
  }
}
