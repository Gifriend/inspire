import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/elearning_lecturer/data/services/elearning_lecturer_service.dart';
import 'elearning_lecturer_state.dart';

final elearningLecturerControllerProvider =
    StateNotifierProvider<ElearningLecturerController, ElearningLecturerState>(
  (ref) => ElearningLecturerController(
    ref.watch(elearningLecturerServiceProvider),
  ),
);

class ElearningLecturerController extends StateNotifier<ElearningLecturerState> {
  final ElearningLecturerService _service;

  ElearningLecturerController(this._service)
      : super(const ElearningLecturerInitial());

  Future<void> loadLecturerCourses() async {
    state = const ElearningLecturerLoading();
    try {
      final courses = await _service.getLecturerCourses();
      state = CourseListLoaded(courses);
    } catch (e) {
      state = ElearningLecturerError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> loadCourseDetail(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final courseDetail = await _service.getCourseDetail(kelasId);
      final sessions = await _service.getCourseContent(kelasId);
      state = CourseDetailLoaded(courseDetail, sessions);
    } catch (e) {
      state = ElearningLecturerError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> loadCourseStudents(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final students = await _service.getCourseStudents(kelasId);
      state = StudentsLoaded(students);
    } catch (e) {
      state = ElearningLecturerError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> loadCourseLeaderboard(int kelasId) async {
    state = const ElearningLecturerLoading();
    try {
      final leaderboard = await _service.getCourseLeaderboard(kelasId);
      state = LeaderboardLoaded(leaderboard);
    } catch (e) {
      state = ElearningLecturerError(e.toString().replaceAll('Exception: ', ''));
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
      state = ElearningLecturerError(e.toString());
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
      state = ElearningLecturerError(e.toString());
    }
  }

  Future<void> createQuiz({
    required String title,
    required int duration,
    required DateTime startTime,
    required DateTime endTime,
    required String gradingMethod,
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
        sessionId: sessionId,
        questions: questions,
      );
      state = const QuizCreated();
    } catch (e) {
      state = ElearningLecturerError(e.toString());
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