import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/classroom/presentation/controllers/classroom_controllers.dart';
import 'package:inspire/features/classroom/presentation/screens/student/classroom_courses_screen.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

/// Layar utama Google Classroom untuk Dosen.
/// Dosen dapat melihat daftar kelas, tugas, dan mahasiswa.
class ClassroomLecturerCoursesScreen extends ConsumerStatefulWidget {
  const ClassroomLecturerCoursesScreen({super.key});

  @override
  ConsumerState<ClassroomLecturerCoursesScreen> createState() =>
      _ClassroomLecturerCoursesScreenState();
}

class _ClassroomLecturerCoursesScreenState
    extends ConsumerState<ClassroomLecturerCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authState = ref.read(classroomAuthLecturerControllerProvider);
    if (authState is ClassroomAuthAuthenticated) {
      ref
          .read(classroomCoursesControllerProvider.notifier)
          .loadCourses(authState.accessToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(classroomAuthLecturerControllerProvider);
    final coursesState = ref.watch(classroomCoursesControllerProvider);

    // Jika belum login → tampilkan tombol login Google
    if (authState is! ClassroomAuthAuthenticated) {
      return _buildSignInPrompt(authState);
    }

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Google Classroom – Dosen',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BaseColor.white),
            tooltip: 'Logout Google',
            onPressed: () async {
              await ref
                  .read(classroomAuthLecturerControllerProvider.notifier)
                  .signOut();
            },
          ),
        ],
      ),
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info akun Google
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: BaseSize.w16,
              vertical: BaseSize.h12,
            ),
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle,
                  color: Color(0xFF1A73E8),
                  size: 32,
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.userName ?? 'Dosen Google',
                        style: BaseTypography.bodyMedium.toBold,
                      ),
                      if (authState.userEmail != null)
                        Text(
                          authState.userEmail!,
                          style: BaseTypography.bodySmall.toGrey,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Text(
              'Kelas yang Anda Ampu',
              style: BaseTypography.titleMedium.toBold,
            ),
          ),
          Gap.h12,
          Expanded(child: _buildContent(coursesState, authState.accessToken)),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt(ClassroomAuthState authState) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Google Classroom – Dosen',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: BaseColor.primaryInspire,
              ),
              Gap.h24,
              Text(
                'Masuk ke Google Classroom\nsebagai Dosen',
                style: BaseTypography.titleLarge.toBold,
                textAlign: TextAlign.center,
              ),
              Gap.h12,
              Text(
                'Login dengan akun Google untuk mengakses kelas, tugas, dan daftar mahasiswa di Google Classroom.',
                style: BaseTypography.bodyMedium.toGrey,
                textAlign: TextAlign.center,
              ),
              Gap.h32,
              if (authState is ClassroomAuthLoading)
                const CircularProgressIndicator(color: Color(0xFF1A73E8))
              else ...[
                if (authState is ClassroomAuthError) ...[
                  Container(
                    padding: EdgeInsets.all(BaseSize.w12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                    ),
                    child: Text(
                      authState.message,
                      style: BaseTypography.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap.h16,
                ],
                _LecturerGoogleSignInButton(
                  onPressed: () => ref
                      .read(classroomAuthLecturerControllerProvider.notifier)
                      .signIn(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ClassroomCoursesState state, String accessToken) {
    if (state is ClassroomCoursesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
      );
    }

    if (state is ClassroomCoursesError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              Gap.h16,
              Text(
                state.message,
                style: BaseTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(classroomCoursesControllerProvider.notifier)
                    .loadCourses(accessToken),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ClassroomCoursesLoaded) {
      if (state.courses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 56, color: BaseColor.grey),
              Gap.h16,
              Text(
                'Belum ada kelas yang diampu',
                style: BaseTypography.bodyLarge.toGrey,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          return ClassroomCourseCard(
            course: course,
            showActions: true,
            onTap: () => context.pushNamed(
              AppRoute.classroomCourseWorkLecturer,
              pathParameters: {'courseId': course.id},
              extra: {'courseName': course.name, 'accessToken': accessToken},
            ),
            onStudentsTap: () => context.pushNamed(
              AppRoute.classroomStudents,
              pathParameters: {'courseId': course.id},
              extra: {'courseName': course.name, 'accessToken': accessToken},
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── GOOGLE SIGN IN BUTTON (LECTURER VARIANT) ────────────────────────────────

class _LecturerGoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LecturerGoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.login, color: Color(0xFF1A73E8)),
        label: const Text(
          'Masuk dengan Google (Dosen)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF1A73E8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: const Color(0xFF1A73E8),
        ),
      ),
    );
  }
}
