import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/services/google_auth_service.dart';
import 'package:inspire/features/classroom/data/classroom_repository.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

// ─── AUTH CONTROLLER (MAHASISWA) ─────────────────────────────────────────────

final classroomAuthControllerProvider = StateNotifierProvider.autoDispose<
    ClassroomAuthController, ClassroomAuthState>(
  (ref) => ClassroomAuthController(ref.watch(googleAuthServiceProvider)),
);

// ─── AUTH CONTROLLER (DOSEN) ─────────────────────────────────────────────────

final classroomAuthLecturerControllerProvider =
    StateNotifierProvider.autoDispose<ClassroomAuthController,
        ClassroomAuthState>(
  (ref) =>
      ClassroomAuthController(ref.watch(googleAuthLecturerServiceProvider)),
);

class ClassroomAuthController extends StateNotifier<ClassroomAuthState> {
  final GoogleAuthService _authService;

  ClassroomAuthController(this._authService)
      : super(const ClassroomAuthInitial()) {
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    final token = await _authService.signInSilently();
    if (token != null) {
      final user = _authService.currentUser;
      state = ClassroomAuthAuthenticated(
        accessToken: token,
        userEmail: user?.email,
        userName: user?.displayName,
      );
    }
  }

  Future<void> signIn() async {
    state = const ClassroomAuthLoading();
    try {
      final token = await _authService.signInWithGoogle();
      if (token == null) {
        state = const ClassroomAuthInitial();
        return;
      }
      final user = _authService.currentUser;
      state = ClassroomAuthAuthenticated(
        accessToken: token,
        userEmail: user?.email,
        userName: user?.displayName,
      );
    } catch (e) {
      state = ClassroomAuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const ClassroomAuthInitial();
  }
}

// ─── COURSES CONTROLLER ──────────────────────────────────────────────────────

final classroomCoursesControllerProvider = StateNotifierProvider.autoDispose<
    ClassroomCoursesController, ClassroomCoursesState>(
  (ref) => ClassroomCoursesController(ref.watch(classroomRepositoryProvider)),
);

class ClassroomCoursesController
    extends StateNotifier<ClassroomCoursesState> {
  final ClassroomRepository _repo;

  ClassroomCoursesController(this._repo)
      : super(const ClassroomCoursesInitial());

  Future<void> loadCourses(String googleAccessToken) async {
    state = const ClassroomCoursesLoading();
    try {
      final courses = await _repo.getCourses(googleAccessToken);
      state = ClassroomCoursesLoaded(courses);
    } catch (e) {
      state = ClassroomCoursesError(e.toString());
    }
  }
}

// ─── COURSE WORK CONTROLLER ──────────────────────────────────────────────────

final classroomCourseWorkControllerProvider =
    StateNotifierProvider.autoDispose.family<ClassroomCourseWorkController,
        ClassroomCourseWorkState, String>(
  (ref, courseId) =>
      ClassroomCourseWorkController(ref.watch(classroomRepositoryProvider)),
);

class ClassroomCourseWorkController
    extends StateNotifier<ClassroomCourseWorkState> {
  final ClassroomRepository _repo;

  ClassroomCourseWorkController(this._repo)
      : super(const ClassroomCourseWorkInitial());

  Future<void> loadCourseWork(
    String googleAccessToken,
    String courseId,
  ) async {
    state = const ClassroomCourseWorkLoading();
    try {
      final work = await _repo.getCourseWork(googleAccessToken, courseId);
      state = ClassroomCourseWorkLoaded(work);
    } catch (e) {
      state = ClassroomCourseWorkError(e.toString());
    }
  }
}

// ─── STUDENTS CONTROLLER ─────────────────────────────────────────────────────

final classroomStudentsControllerProvider =
    StateNotifierProvider.autoDispose.family<ClassroomStudentsController,
        ClassroomStudentsState, String>(
  (ref, courseId) =>
      ClassroomStudentsController(ref.watch(classroomRepositoryProvider)),
);

class ClassroomStudentsController
    extends StateNotifier<ClassroomStudentsState> {
  final ClassroomRepository _repo;

  ClassroomStudentsController(this._repo)
      : super(const ClassroomStudentsInitial());

  Future<void> loadStudents(
    String googleAccessToken,
    String courseId,
  ) async {
    state = const ClassroomStudentsLoading();
    try {
      final students = await _repo.getStudents(googleAccessToken, courseId);
      state = ClassroomStudentsLoaded(students);
    } catch (e) {
      state = ClassroomStudentsError(e.toString());
    }
  }
}
