import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';
import 'package:inspire/core/models/elearning/material_model.dart' as elearning;
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/models/elearning/session_model.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart'; 
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String kelasId;
  final String courseName;

  const CourseDetailScreen({
    super.key,
    required this.kelasId,
    required this.courseName,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late final int? _parsedKelasId;

  @override
  void initState() {
    super.initState();
    _parsedKelasId = int.tryParse(widget.kelasId);
    
    if (_parsedKelasId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(courseControllerProvider(_parsedKelasId).notifier).loadCourseContent();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedKelasId == null) {
      return const Scaffold(body: Center(child: Text('Invalid Course ID')));
    }

    final courseState = ref.watch(courseControllerProvider(_parsedKelasId));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(title: widget.courseName),
      child: courseState.when(
        initial: () => const SizedBox.shrink(),
        // 1. Implementasi Skeleton Loading
        loading: () => const _CourseDetailSkeleton(),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              Gap.h16,
              Text(message, textAlign: TextAlign.center),
              Gap.h16,
              ButtonWidget.primary(
                text: 'Coba Lagi',
                onTap: () => ref.read(courseControllerProvider(_parsedKelasId).notifier).loadCourseContent(),
              ),
            ],
          ),
        ),
        loaded: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: BaseColor.grey),
                  Gap.h16,
                  Text('Belum ada sesi perkuliahan', style: BaseTypography.bodyLarge.toGrey),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(BaseSize.w16),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => Gap.h16,
            itemBuilder: (context, index) {
              return _SessionCard(session: sessions[index]);
            },
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Refactoring Widget: Session Card (Agar build utama tidak menumpuk)
// -----------------------------------------------------------------------------
class _SessionCard extends StatelessWidget {
  final SessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseSize.radiusMd)),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: BaseSize.w16, vertical: BaseSize.h8),
        childrenPadding: EdgeInsets.fromLTRB(BaseSize.w16, 0, BaseSize.w16, BaseSize.w16),
        leading: CircleAvatar(
          backgroundColor: BaseColor.primaryInspire,
          child: Text('${session.weekNumber}', style: BaseTypography.titleMedium.toBold.toWhite),
        ),
        title: Text(session.title, style: BaseTypography.titleMedium.toBold),
        subtitle: session.description != null
            ? Text(session.description!, style: BaseTypography.bodySmall.toGrey, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        children: [
          if (session.materials.isNotEmpty) ...[
            _SectionHeader(icon: Icons.article, color: BaseColor.primaryInspire, title: 'Materi'),
            ...session.materials.map((m) => _MaterialItem(material: m)),
            Gap.h12,
          ],
          if (session.assignments.isNotEmpty) ...[
            const _SectionHeader(icon: Icons.assignment, color: Colors.orange, title: 'Tugas'),
            ...session.assignments.map((a) => _AssignmentItem(assignment: a)),
            Gap.h12,
          ],
          if (session.quizzes.isNotEmpty) ...[
            const _SectionHeader(icon: Icons.quiz, color: Colors.purple, title: 'Kuis'),
            ...session.quizzes.map((q) => _QuizItem(quiz: q)),
          ],
        ],
      ),
    );
  }
}

// Header Kecil untuk setiap section (Materi/Tugas/Kuis)
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _SectionHeader({required this.icon, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          Gap.w8,
          Text(title, style: BaseTypography.titleSmall.toBold),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Sub-Widgets Item (Material, Assignment, Quiz)
// -----------------------------------------------------------------------------

class _MaterialItem extends StatelessWidget {
  final elearning.MaterialModel material;
  const _MaterialItem({required this.material});

  @override
  Widget build(BuildContext context) {
    return _BaseItemContainer(
      color: Colors.blue,
      onTap: () => context.pushNamed(
        AppRoute.materialDetail,
        pathParameters: {'materialId': material.id.toString()},
        extra: material, // Pass object jika perlu
      ),
      child: Row(
        children: [
          Icon(
            material.type == elearning.MaterialType.FILE ? Icons.insert_drive_file : Icons.text_fields,
            color: Colors.blue,
            size: 20,
          ),
          Gap.w12,
          Expanded(child: Text(material.title, style: BaseTypography.bodyMedium)),
          Icon(Icons.chevron_right, color: BaseColor.grey),
        ],
      ),
    );
  }
}

class _AssignmentItem extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentItem({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateTime.now().isAfter(assignment.deadline);
    final isSubmitted = assignment.submission != null;

    return _BaseItemContainer(
      color: isOverdue && !isSubmitted ? Colors.red : Colors.orange,
      borderColor: isOverdue && !isSubmitted ? Colors.red : null,
      onTap: () => context.pushNamed(
        AppRoute.assignmentDetail,
        pathParameters: {'assignmentId': assignment.id.toString()},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSubmitted ? Icons.assignment_turned_in : Icons.assignment,
                color: isSubmitted ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                size: 20,
              ),
              Gap.w12,
              Expanded(child: Text(assignment.title, style: BaseTypography.bodyMedium.toBold)),
              if (isSubmitted)
                _StatusChip(text: 'Submitted', color: Colors.green),
            ],
          ),
          Gap.h4,
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: isOverdue ? Colors.red : BaseColor.grey),
              Gap.w4,
              Text(
                'Deadline: ${Jiffy.parse(assignment.deadline.toString()).yMMMd}',
                style: BaseTypography.bodySmall.copyWith(
                  color: isOverdue ? Colors.red : BaseColor.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizItem extends StatelessWidget {
  final QuizModel quiz;
  const _QuizItem({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isActive = now.isAfter(quiz.startTime) && now.isBefore(quiz.endTime);
    final hasAttempt = quiz.attempts.isNotEmpty;

    return _BaseItemContainer(
      color: Colors.purple,
      onTap: () => context.pushNamed(
        AppRoute.quizDetail,
        pathParameters: {'quizId': quiz.id.toString()},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined, color: Colors.purple, size: 20),
              Gap.w12,
              Expanded(child: Text(quiz.title, style: BaseTypography.bodyMedium.toBold)),
              if (hasAttempt)
                _StatusChip(text: 'Selesai', color: Colors.blue)
              else if (isActive)
                _StatusChip(text: 'Aktif', color: Colors.green),
            ],
          ),
          Gap.h4,
          Row(
            children: [
              Icon(Icons.timer, size: 14, color: BaseColor.grey),
              Gap.w4,
              Text('${quiz.duration} menit', style: BaseTypography.bodySmall.toGrey),
            ],
          ),
        ],
      ),
    );
  }
}

// Container dasar untuk item (Materi/Tugas/Kuis) agar style seragam
class _BaseItemContainer extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final Color? borderColor;

  const _BaseItemContainer({
    required this.color,
    required this.onTap,
    required this.child,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        child: Container(
          padding: EdgeInsets.all(BaseSize.w12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w8, vertical: BaseSize.h4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Text(text, style: BaseTypography.labelSmall.toWhite),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Skeleton Loading Widget
// -----------------------------------------------------------------------------
class _CourseDetailSkeleton extends StatelessWidget {
  const _CourseDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(BaseSize.w16),
      itemCount: 4, // Tampilkan 4 dummy items
      separatorBuilder: (_, __) => Gap.h16,
      itemBuilder: (_, __) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseSize.radiusMd)),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonLoading(width: 40, height: 40, borderRadius: 20), // Circle Avatar
                  Gap.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLoading(width: 150, height: 20),
                      Gap.h4,
                      const SkeletonLoading(width: 100, height: 14),
                    ],
                  ),
                ],
              ),
              Gap.h16,
              const SkeletonLoading(width: double.infinity, height: 60), // Content placeholder
            ],
          ),
        ),
      ),
    );
  }
}