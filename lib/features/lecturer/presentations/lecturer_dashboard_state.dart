// Dashboard State Management (without Freezed for simplicity)

sealed class LecturerDashboardState {
  const LecturerDashboardState();
}

class LecturerDashboardInitial extends LecturerDashboardState {
  const LecturerDashboardInitial();
}

class LecturerDashboardLoading extends LecturerDashboardState {
  const LecturerDashboardLoading();
}

class LecturerDashboardLoaded extends LecturerDashboardState {
  final DashboardData data;
  const LecturerDashboardLoaded(this.data);
}

class LecturerDashboardError extends LecturerDashboardState {
  final String message;
  const LecturerDashboardError(this.message);
}

// Data Models
class DashboardData {
  final int totalClasses;
  final int totalStudents;
  final int pendingKrs;
  final int todayPresence;
  final List<ClassInfo> recentClasses;
  final List<ActivityInfo> recentActivities;

  const DashboardData({
    required this.totalClasses,
    required this.totalStudents,
    required this.pendingKrs,
    required this.todayPresence,
    required this.recentClasses,
    required this.recentActivities,
  });
}

class ClassInfo {
  final int id;
  final String code;
  final String name;
  final String schedule;
  final int studentCount;
  final String courseName;
  final String room;

  const ClassInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.schedule,
    required this.studentCount,
    required this.courseName,
    required this.room,
  });
}

class ActivityInfo {
  final String title;
  final String description;
  final DateTime timestamp;
  final String type;

  const ActivityInfo({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}
