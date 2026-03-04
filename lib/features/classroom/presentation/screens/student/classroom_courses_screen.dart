import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/classroom/presentation/controllers/classroom_controllers.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

/// Layar untuk mahasiswa melihat daftar kelas Google Classroom mereka.
class ClassroomCoursesScreen extends ConsumerStatefulWidget {
  const ClassroomCoursesScreen({super.key});

  @override
  ConsumerState<ClassroomCoursesScreen> createState() =>
      _ClassroomCoursesScreenState();
}

class _ClassroomCoursesScreenState
    extends ConsumerState<ClassroomCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final authState = ref.read(classroomAuthControllerProvider);
    if (authState is ClassroomAuthAuthenticated) {
      ref
          .read(classroomCoursesControllerProvider.notifier)
          .loadCourses(authState.accessToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(classroomAuthControllerProvider);
    final coursesState = ref.watch(classroomCoursesControllerProvider);

    // Jika belum login Google → tampilkan layar login
    if (authState is! ClassroomAuthAuthenticated) {
      return _buildSignInPrompt(authState);
    }

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Google Classroom',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: BaseColor.white),
            tooltip: 'Logout Google',
            onPressed: () async {
              await ref.read(classroomAuthControllerProvider.notifier).signOut();
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
                horizontal: BaseSize.w16, vertical: BaseSize.h12),
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_circle,
                    color: Color(0xFF1A73E8), size: 32),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.userName ?? 'Pengguna Google',
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
            child: Text('Kelas Saya',
                style: BaseTypography.titleMedium.toBold),
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
        title: 'Google Classroom',
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
              Image.asset(
                'assets/images/google_classroom.png',
                width: 80,
                errorBuilder: (ctx, e, st) => const Icon(
                  Icons.school,
                  size: 80,
                  color: BaseColor.primaryInspire,
                ),
              ),
              Gap.h24,
              Text(
                'Masuk ke Google Classroom',
                style: BaseTypography.titleLarge.toBold,
                textAlign: TextAlign.center,
              ),
              Gap.h12,
              Text(
                'Login dengan akun Google Anda untuk mengakses kelas dan tugas di Google Classroom.',
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
                      borderRadius:
                          BorderRadius.circular(BaseSize.radiusSm),
                    ),
                    child: Text(
                      authState.message,
                      style:
                          BaseTypography.bodySmall.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap.h16,
                ],
                _GoogleSignInButton(
                  onPressed: () =>
                      ref.read(classroomAuthControllerProvider.notifier).signIn(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    ClassroomCoursesState state,
    String accessToken,
  ) {
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
              Text(state.message,
                  style: BaseTypography.bodyMedium,
                  textAlign: TextAlign.center),
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
                'Belum ada kelas',
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
            onTap: () => context.pushNamed(
              AppRoute.classroomCourseWork,
              pathParameters: {'courseId': course.id},
              extra: {
                'courseName': course.name,
                'accessToken': accessToken,
              },
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── REUSABLE WIDGETS ────────────────────────────────────────────────────────

class ClassroomCourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onStudentsTap;

  const ClassroomCourseCard({
    super.key,
    required this.course,
    required this.onTap,
    this.showActions = false,
    this.onStudentsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      elevation: 2,
      color: BaseColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _courseColor(course.name),
                      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        course.name.isNotEmpty
                            ? course.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: BaseTypography.bodyMedium.toBold,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (course.section != null &&
                            course.section!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            course.section!,
                            style: BaseTypography.bodySmall.toGrey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (course.descriptionHeading != null &&
                  course.descriptionHeading!.isNotEmpty) ...[
                Gap.h8,
                Text(
                  course.descriptionHeading!,
                  style: BaseTypography.bodySmall.toGrey,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (showActions && onStudentsTap != null) ...[
                Gap.h12,
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.assignment, size: 16),
                      label: const Text('Tugas'),
                    ),
                    Gap.w8,
                    TextButton.icon(
                      onPressed: onStudentsTap,
                      icon: const Icon(Icons.people, size: 16),
                      label: const Text('Mahasiswa'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _courseColor(String name) {
    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFF188038),
      const Color(0xFFD93025),
      const Color(0xFFF29900),
      const Color(0xFF9334E6),
      const Color(0xFF00897B),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: _GoogleLogo(),
        label: const Text(
          'Masuk dengan Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFDADCE0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: Colors.black87,
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw "G" letter representation with arc segments
    final rect = Rect.fromCircle(center: center, radius: radius * 0.85);

    // Blue segment
    _drawArc(canvas, rect, -0.1, 0.65, const Color(0xFF4285F4));
    // Red segment
    _drawArc(canvas, rect, 0.55, 0.6, const Color(0xFFEA4335));
    // Yellow segment
    _drawArc(canvas, rect, 1.1, 0.6, const Color(0xFFFBBC05));
    // Green segment
    _drawArc(canvas, rect, 1.65, 0.6, const Color(0xFF34A853));

    // White center circle
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, whitePaint);

    // Blue horizontal bar (right side)
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
          center.dx, center.dy - radius * 0.12, radius * 0.9, radius * 0.24),
      barPaint,
    );
  }

  void _drawArc(
      Canvas canvas, Rect rect, double start, double sweep, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = rect.width * 0.15;
    canvas.drawArc(rect, start * 3.14159, sweep * 3.14159, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
