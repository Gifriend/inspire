import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/features/presentation.dart';
import '../../features/krs/presentation/screens/add_class_screen.dart';
import '../../features/krs/presentation/screens/krs_screen.dart';
import 'routing.dart';

class AppRoute {
  static const String main = 'main';
  static const String viewAll = 'view-all';

  // splash
  static const String splash = 'splash';

  // home
  static const String home = 'home';

  //Rating
  static const String rating = 'rating';

  //Term and Condition
  static const String termAndCondition = 'term-and-condition';

  //Authentication
  static const String authentication = "authentication";

  //Dashboard
  static const String dashboard = 'dashboard';

  //Presensi
  static const String presensi = 'presensi';
  static const String presensiDetail = 'presensi-detail';

  //login
  static const String login = 'login';

  //E-Learning
  static const String eLearning = 'elearning';
  static const String eLearningSearch = 'elearning-search';
  static const String courseDetail = 'course-detail';
  static const String materialDetail = 'material-detail';
  static const String assignmentDetail = 'assignment-detail';
  static const String quizDetail = 'quiz-detail';
  static const String quizTaking = 'quiz-taking';
  
  //Announcement
  static const String announcementList = 'announcement-list';
  static const String announcementDetail = 'announcement-detail';
  
  //KRS
  static const String krs = 'krs';
  static const String krsAddClass = 'krs-add-class';
  
  //KHS
  static const String khs = 'khs';
  static const String khsDetail = 'khs-detail';
  
  //Transcript
  static const String transcript = 'transcript';
  
  //Lecturer Dashboard
  static const String lecturerDashboard = 'lecturer-dashboard';
  static const String krsLecturer = 'krs-lecturer';
  static const String presensiLecturer = 'presensi-lecturer';
  static const String eLearningLecturer = 'elearning-lecturer';
  static const String lecturerCourseDetail = 'lecturer-course-detail';
  static const String announcementLecturer = 'announcement-lecturer';
  static const String gradingLecturer = 'grading-lecturer';
  static const String myClassesLecturer = 'my-classes-lecturer';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    routerNeglect: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: AppRoute.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/elearning',
        name: AppRoute.eLearning,
        builder: (context, state) => const ElearningScreen(),
      ),
      GoRoute(
        path: '/course/:kelasId',
        name: AppRoute.courseDetail,
        builder: (context, state) {
          final kelasId = state.pathParameters['kelasId'] ?? '0';
          final courseName = state.uri.queryParameters['courseName'] ?? 'Course';
          return CourseDetailScreen(kelasId: kelasId, courseName: courseName);
        },
      ),
      GoRoute(
        path: '/material/:materialId',
        name: AppRoute.materialDetail,
        builder: (context, state) {
          final material = state.extra;
          return MaterialDetailScreen(material: material as dynamic);
        },
      ),
      GoRoute(
        path: '/assignment/:assignmentId',
        name: AppRoute.assignmentDetail,
        builder: (context, state) {
          final assignmentId = state.pathParameters['assignmentId'] ?? '0';
          return AssignmentDetailScreen(assignmentId: assignmentId);
        },
      ),
      GoRoute(
        path: '/quiz/:quizId',
        name: AppRoute.quizDetail,
        builder: (context, state) {
          final quizId = state.pathParameters['quizId'] ?? '0';
          return QuizDetailScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: '/quiz/:quizId/take',
        name: AppRoute.quizTaking,
        builder: (context, state) {
          final quiz = state.extra;
          return QuizTakingScreen(quiz: quiz as dynamic);
        },
      ),
      GoRoute(
        path: '/announcement',
        name: AppRoute.announcementList,
        builder: (context, state) => const AnnouncementListScreen(),
      ),
      GoRoute(
        path: '/announcement/:id',
        name: AppRoute.announcementDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return AnnouncementDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/krs/:semester',
        name: AppRoute.krs,
        builder: (context, state) {
          final semester = state.pathParameters['semester'] ?? '1';
          return KrsScreen(semester: semester);
        },
      ),
      GoRoute(
        path: '/krs/:semester/add-class',
        name: AppRoute.krsAddClass,
        builder: (context, state) {
          final semester = state.pathParameters['semester'] ?? '1';
          return AddClassScreen(semester: semester);
        },
      ),
      GoRoute(
        path: '/khs',
        name: AppRoute.khs,
        builder: (context, state) => const KhsSemesterListScreen(),
      ),
      GoRoute(
        path: '/khs/:semester',
        name: AppRoute.khsDetail,
        builder: (context, state) {
          final semester = state.pathParameters['semester'] ?? '';
          return KhsDetailScreen(semester: semester);
        },
      ),
      GoRoute(
        path: '/transcript',
        name: AppRoute.transcript,
        builder: (context, state) => const TranscriptScreen(),
      ),
      GoRoute(
        path: '/lecturer-dashboard',
        name: AppRoute.lecturerDashboard,
        builder: (context, state) => const LecturerDashboardScreen(),
      ),
      GoRoute(
        path: '/krs-lecturer',
        name: AppRoute.krsLecturer,
        builder: (context, state) => const KrsLecturerScreen(),
      ),
      GoRoute(
        path: '/presensi-lecturer',
        name: AppRoute.presensiLecturer,
        builder: (context, state) => const PresensiLecturerScreen(),
      ),
      GoRoute(
        path: '/elearning-lecturer',
        name: AppRoute.eLearningLecturer,
        builder: (context, state) => const ElearningLecturerScreen(),
      ),
      // GoRoute(
      //   path: '/lecturer-course-detail/:kelasId/:courseName',
      //   name: 'lecturerCourseDetail',
      //   builder: (context, state) {
      //     final kelasId = state.pathParameters['kelasId']!;
      //     final courseName = state.pathParameters['courseName']!;
      //     return LecturerCourseDetailScreen(
      //       kelasId: kelasId,
      //       courseName: courseName,
      //     );
      //   },
      // ),
      GoRoute(
        path: '/create-quiz',
        name: 'createQuiz',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final sessions = extra['sessions'] as List<SessionModel>;
          final kelasId = extra['kelasId'] as int;
          return CreateQuizScreen(sessions: sessions, kelasId: kelasId);
        },
      ),
      GoRoute(
        path: '/announcement-lecturer',
        name: AppRoute.announcementLecturer,
        builder: (context, state) => const AnnouncementLecturerScreen(),
      ),
      GoRoute(
        path: '/grading-lecturer',
        name: AppRoute.gradingLecturer,
        builder: (context, state) => const GradingLecturerScreen(),
      ),
      GoRoute(
        path: '/my-classes-lecturer',
        name: AppRoute.myClassesLecturer,
        builder: (context, state) => const MyClassesLecturerScreen(),
      ),
      // GoRoute(
      //   path: '/login',
      //   name: AppRoute.login,
      //   builder: (context, state) => const LoginScreen(),
      // ),
      presensiRouting,
      // elearningRouting,
      // authenticationRouting,
      // dashboardRouting,
      // accountRouting,
    ],
  );
});

class RouteParam {
  final Map<String, dynamic> params;

  const RouteParam({required this.params});
}
