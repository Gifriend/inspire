import '../../../core/models/models.dart';

sealed class ElearningLecturerState {
  const ElearningLecturerState();
}

class ElearningLecturerInitial extends ElearningLecturerState {
  const ElearningLecturerInitial();
}

class ElearningLecturerLoading extends ElearningLecturerState {
  const ElearningLecturerLoading();
}

class ElearningLecturerError extends ElearningLecturerState {
  final String message;
  const ElearningLecturerError(this.message);
}

// For course list
class CourseListLoaded extends ElearningLecturerState {
  final List<CourseListModel> courses;
  const CourseListLoaded(this.courses);
}

// For course detail with content
class CourseDetailLoaded extends ElearningLecturerState {
  final CourseDetailModel courseDetail;
  final List<SessionModel> sessions;
  final ElearningClassConfigModel? setupConfig;
  final List<CourseListModel> lecturerCourses;

  const CourseDetailLoaded(
    this.courseDetail,
    this.sessions, {
    this.setupConfig,
    this.lecturerCourses = const [],
  });
}

// For students list
class StudentsLoaded extends ElearningLecturerState {
  final List<StudentInfoModel> students;
  const StudentsLoaded(this.students);
}

// For leaderboard
class LeaderboardLoaded extends ElearningLecturerState {
  final List<StudentInfoModel> leaderboard;
  const LeaderboardLoaded(this.leaderboard);
}

// For assignment submissions
class SubmissionsLoaded extends ElearningLecturerState {
  final List<SubmissionModel> submissions;
  const SubmissionsLoaded(this.submissions);
}

// For quiz attempts
class QuizAttemptsLoaded extends ElearningLecturerState {
  final List<QuizAttemptModel> attempts;
  const QuizAttemptsLoaded(this.attempts);
}

// Success states
class MaterialCreated extends ElearningLecturerState {
  const MaterialCreated();
}

class AssignmentCreated extends ElearningLecturerState {
  const AssignmentCreated();
}

class QuizCreated extends ElearningLecturerState {
  const QuizCreated();
}

class SubmissionGraded extends ElearningLecturerState {
  const SubmissionGraded();
}

class SetupClassSaved extends ElearningLecturerState {
  final String message;
  const SetupClassSaved(this.message);
}

class MergeClassesSaved extends ElearningLecturerState {
  final String message;
  const MergeClassesSaved(this.message);
}

class UnmergeClassSaved extends ElearningLecturerState {
  const UnmergeClassSaved();
}

class VisibilityUpdated extends ElearningLecturerState {
  const VisibilityUpdated();
}
