import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/core/models/classroom/classroom_models.dart';
import 'package:inspire/features/classroom/presentation/controllers/classroom_controllers.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

/// Layar untuk mahasiswa melihat daftar tugas & materi di satu kelas Classroom.
class ClassroomCourseWorkScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final String accessToken;

  const ClassroomCourseWorkScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.accessToken,
  });

  @override
  ConsumerState<ClassroomCourseWorkScreen> createState() =>
      _ClassroomCourseWorkScreenState();
}

class _ClassroomCourseWorkScreenState
    extends ConsumerState<ClassroomCourseWorkScreen> {
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
      ),
      disableSingleChildScrollView: true,
      child: _buildContent(state),
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

      return ListView.builder(
        padding: EdgeInsets.all(BaseSize.w16),
        itemCount: state.courseWorkList.length,
        itemBuilder: (context, index) {
          return ClassroomCourseWorkCard(
            item: state.courseWorkList[index],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── COURSE WORK CARD (reusable) ─────────────────────────────────────────────

String _formatDate(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

class ClassroomCourseWorkCard extends StatelessWidget {
  final ClassroomCourseWork item;
  const ClassroomCourseWorkCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      elevation: 1,
      color: BaseColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _workTypeIcon(),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: BaseSize.w6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _workTypeColor().withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(BaseSize.radiusSm),
                        ),
                        child: Text(
                          item.workTypeLabel,
                          style: BaseTypography.bodySmall.copyWith(
                            color: _workTypeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h6,
                  Text(
                    item.title,
                    style: BaseTypography.bodyMedium.toBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    Gap.h4,
                    Text(
                      item.description!,
                      style: BaseTypography.bodySmall.toGrey,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Gap.h8,
                  Row(
                    children: [
                      if (item.dueDate != null) ...[
                        const Icon(Icons.calendar_today,
                            size: 13, color: Colors.orange),
                        Gap.w4,
                        Text(
                          'Tenggat: ${_formatDate(item.dueDate!)}',
                          style: BaseTypography.bodySmall.copyWith(
                              color: Colors.orange.shade700),
                        ),
                        Gap.w12,
                      ],
                      if (item.maxPoints != null) ...[
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        Gap.w4,
                        Text(
                          '${item.maxPoints!.toInt()} poin',
                          style: BaseTypography.bodySmall.toGrey,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workTypeIcon() {
    IconData icon;
    Color color;
    switch (item.workType) {
      case 'ASSIGNMENT':
        icon = Icons.assignment;
        color = const Color(0xFF1A73E8);
        break;
      case 'MATERIAL':
        icon = Icons.menu_book;
        color = const Color(0xFF34A853);
        break;
      case 'MULTIPLE_CHOICE_QUESTION':
      case 'SHORT_ANSWER_QUESTION':
        icon = Icons.quiz;
        color = const Color(0xFFD93025);
        break;
      default:
        icon = Icons.article;
        color = Colors.grey;
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Color _workTypeColor() {
    switch (item.workType) {
      case 'ASSIGNMENT':
        return const Color(0xFF1A73E8);
      case 'MATERIAL':
        return const Color(0xFF34A853);
      case 'MULTIPLE_CHOICE_QUESTION':
      case 'SHORT_ANSWER_QUESTION':
        return const Color(0xFFD93025);
      default:
        return Colors.grey;
    }
  }
}
