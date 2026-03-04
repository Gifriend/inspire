import 'package:inspire/core/models/classroom/classroom_models.dart';

/// Status autentikasi Google untuk Google Classroom
abstract class ClassroomAuthState {
  const ClassroomAuthState();
}

class ClassroomAuthInitial extends ClassroomAuthState {
  const ClassroomAuthInitial();
}

class ClassroomAuthLoading extends ClassroomAuthState {
  const ClassroomAuthLoading();
}

class ClassroomAuthAuthenticated extends ClassroomAuthState {
  final String accessToken;
  final String? userEmail;
  final String? userName;
  const ClassroomAuthAuthenticated({
    required this.accessToken,
    this.userEmail,
    this.userName,
  });
}

class ClassroomAuthError extends ClassroomAuthState {
  final String message;
  const ClassroomAuthError(this.message);
}

/// State daftar kelas Classroom
abstract class ClassroomCoursesState {
  const ClassroomCoursesState();
}

class ClassroomCoursesInitial extends ClassroomCoursesState {
  const ClassroomCoursesInitial();
}

class ClassroomCoursesLoading extends ClassroomCoursesState {
  const ClassroomCoursesLoading();
}

class ClassroomCoursesLoaded extends ClassroomCoursesState {
  final List<ClassroomCourse> courses;
  const ClassroomCoursesLoaded(this.courses);
}

class ClassroomCoursesError extends ClassroomCoursesState {
  final String message;
  const ClassroomCoursesError(this.message);
}

/// State daftar tugas kelas Classroom
abstract class ClassroomCourseWorkState {
  const ClassroomCourseWorkState();
}

class ClassroomCourseWorkInitial extends ClassroomCourseWorkState {
  const ClassroomCourseWorkInitial();
}

class ClassroomCourseWorkLoading extends ClassroomCourseWorkState {
  const ClassroomCourseWorkLoading();
}

class ClassroomCourseWorkLoaded extends ClassroomCourseWorkState {
  final List<ClassroomCourseWork> courseWorkList;
  const ClassroomCourseWorkLoaded(this.courseWorkList);
}

class ClassroomCourseWorkError extends ClassroomCourseWorkState {
  final String message;
  const ClassroomCourseWorkError(this.message);
}

/// State daftar mahasiswa kelas Classroom
abstract class ClassroomStudentsState {
  const ClassroomStudentsState();
}

class ClassroomStudentsInitial extends ClassroomStudentsState {
  const ClassroomStudentsInitial();
}

class ClassroomStudentsLoading extends ClassroomStudentsState {
  const ClassroomStudentsLoading();
}

class ClassroomStudentsLoaded extends ClassroomStudentsState {
  final List<ClassroomStudent> students;
  const ClassroomStudentsLoaded(this.students);
}

class ClassroomStudentsError extends ClassroomStudentsState {
  final String message;
  const ClassroomStudentsError(this.message);
}
