import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/classroom/presentation/controllers/classroom_controllers.dart';
import 'package:inspire/features/classroom/presentation/screens/student/classroom_course_work_screen.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

/// Layar untuk Dosen melihat daftar tugas & materi di satu kelas Classroom.
///
/// Dosen memiliki tampilan tambahan: bisa melihat jumlah mahasiswa dan keterangan
/// tipe tugas lebih detail dibanding mahasiswa.
class ClassroomCourseWorkLecturerScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final String accessToken;

  const ClassroomCourseWorkLecturerScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.accessToken,
  });

  @override
  ConsumerState<ClassroomCourseWorkLecturerScreen> createState() =>
      _ClassroomCourseWorkLecturerScreenState();
}

class _ClassroomCourseWorkLecturerScreenState
    extends ConsumerState<ClassroomCourseWorkLecturerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(classroomCourseWorkControllerProvider(widget.courseId).notifier)
          .loadCourseWork(widget.accessToken, widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(classroomCourseWorkControllerProvider(widget.courseId));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: widget.courseName,
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt, color: BaseColor.white),
            tooltip: 'Lihat Mahasiswa',
            onPressed: () => context.pushNamed(
              AppRoute.classroomStudents,
              pathParameters: {'courseId': widget.courseId},
              extra: {
                'courseName': widget.courseName,
                'accessToken': widget.accessToken,
              },
            ),
          ),
        ],
      ),
      disableSingleChildScrollView: true,
      child: Column(
        children: [
          // Banner info kelas
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
                horizontal: BaseSize.w16, vertical: BaseSize.h12),
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF1A73E8), size: 18),
                Gap.w8,
                Expanded(
                  child: Text(
                    'Tekan ikon 👥 di kanan atas untuk melihat daftar mahasiswa.',
                    style: BaseTypography.bodySmall
                        .copyWith(color: const Color(0xFF1A73E8)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildContent(ClassroomCourseWorkState state) {
    if (state is ClassroomCourseWorkLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
      );
    }

    if (state is ClassroomCourseWorkError) {
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
                    .read(classroomCourseWorkControllerProvider(widget.courseId)
                        .notifier)
                    .loadCourseWork(widget.accessToken, widget.courseId),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ClassroomCourseWorkLoaded) {
      if (state.courseWorkList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 56, color: BaseColor.grey),
              Gap.h16,
              Text('Belum ada tugas atau materi',
                  style: BaseTypography.bodyLarge.toGrey),
            ],
          ),
        );
      }

      // Kelompokkan berdasarkan tipe
      final assignments = state.courseWorkList
          .where((w) => w.workType == 'ASSIGNMENT')
          .toList();
      final materials = state.courseWorkList
          .where((w) => w.workType == 'MATERIAL')
          .toList();
      final quizzes = state.courseWorkList
          .where(
              (w) => w.workType.contains('QUESTION'))
          .toList();

      return SingleChildScrollView(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary chips
            Wrap(
              spacing: BaseSize.w8,
              runSpacing: BaseSize.h8,
              children: [
                _SummaryChip(
                    icon: Icons.assignment,
                    label: '${assignments.length} Tugas',
                    color: const Color(0xFF1A73E8)),
                _SummaryChip(
                    icon: Icons.menu_book,
                    label: '${materials.length} Materi',
                    color: const Color(0xFF34A853)),
                _SummaryChip(
                    icon: Icons.quiz,
                    label: '${quizzes.length} Kuis',
                    color: const Color(0xFFD93025)),
              ],
            ),
            Gap.h16,
            ...state.courseWorkList
                .map((item) => ClassroomCourseWorkCard(item: item)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: BaseSize.w12, vertical: BaseSize.h6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          Gap.w4,
          Text(
            label,
            style: BaseTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
