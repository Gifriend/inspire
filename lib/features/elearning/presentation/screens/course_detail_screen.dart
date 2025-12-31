import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
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
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kelasId = int.tryParse(widget.kelasId);
      if (kelasId != null) {
        ref
            .read(courseControllerProvider(kelasId).notifier)
            .loadCourseContent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kelasId = int.tryParse(widget.kelasId);

    if (kelasId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: BaseColor.primaryInspire,
          foregroundColor: BaseColor.white,
        ),
        body: const Center(
          child: Text('Invalid course ID'),
        ),
      );
    }

    final courseState = ref.watch(courseControllerProvider(kelasId));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: BaseTypography.titleLarge.toBold,
        ),
        backgroundColor: BaseColor.primaryInspire,
        foregroundColor: BaseColor.white,
      ),
      loading: courseState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      child: courseState.maybeWhen(
        loaded: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: BaseColor.grey,
                  ),
                  Gap.h16,
                  Text(
                    'Belum ada sesi perkuliahan',
                    style: BaseTypography.bodyLarge.toGrey,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(BaseSize.w16),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => Gap.h16,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w16,
                    vertical: BaseSize.h8,
                  ),
                  childrenPadding: EdgeInsets.all(BaseSize.w16),
                  leading: CircleAvatar(
                    backgroundColor: BaseColor.primaryInspire,
                    child: Text(
                      '${session.weekNumber}',
                      style: BaseTypography.titleMedium.toBold.toWhite,
                    ),
                  ),
                  title: Text(
                    session.title,
                    style: BaseTypography.titleMedium.toBold,
                  ),
                  subtitle: session.description != null
                      ? Text(
                          session.description!,
                          style: BaseTypography.bodySmall.toGrey,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  children: [
                    // Materials Section
                    if (session.materials.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.article,
                                size: 20,
                                color: BaseColor.primaryInspire,
                              ),
                              Gap.w8,
                              Text(
                                'Materi',
                                style: BaseTypography.titleSmall.toBold,
                              ),
                            ],
                          ),
                          Gap.h8,
                          ...session.materials.map((material) {
                            return InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoute.materialDetail,
                                  pathParameters: {
                                    'materialId': material.id.toString()
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: BaseSize.h8),
                                padding: EdgeInsets.all(BaseSize.w12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(BaseSize.radiusSm),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      material.type.name == 'FILE'
                                          ? Icons.insert_drive_file
                                          : Icons.text_fields,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    Gap.w12,
                                    Expanded(
                                      child: Text(
                                        material.title,
                                        style: BaseTypography.bodyMedium,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: BaseColor.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Gap.h16,
                        ],
                      ),

                    // Assignments Section
                    if (session.assignments.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment,
                                size: 20,
                                color: Colors.orange,
                              ),
                              Gap.w8,
                              Text(
                                'Tugas',
                                style: BaseTypography.titleSmall.toBold,
                              ),
                            ],
                          ),
                          Gap.h8,
                          ...session.assignments.map((assignment) {
                            final isOverdue =
                                DateTime.now().isAfter(assignment.deadline);
                            return InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoute.assignmentDetail,
                                  pathParameters: {
                                    'assignmentId': assignment.id.toString()
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: BaseSize.h8),
                                padding: EdgeInsets.all(BaseSize.w12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(BaseSize.radiusSm),
                                  border: isOverdue
                                      ? Border.all(color: Colors.red, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.assignment_turned_in,
                                          color: isOverdue
                                              ? Colors.red
                                              : Colors.orange,
                                          size: 20,
                                        ),
                                        Gap.w12,
                                        Expanded(
                                          child: Text(
                                            assignment.title,
                                            style: BaseTypography.bodyMedium
                                                .toBold,
                                          ),
                                        ),
                                        if (assignment.submission != null)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: BaseSize.w8,
                                              vertical: BaseSize.h4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      BaseSize.radiusSm),
                                            ),
                                            child: Text(
                                              'Submitted',
                                              style: BaseTypography.bodySmall
                                                  .toWhite,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Gap.h4,
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isOverdue
                                              ? Colors.red
                                              : BaseColor.grey,
                                        ),
                                        Gap.w4,
                                        Text(
                                          'Deadline: ${Jiffy.parse(assignment.deadline.toString()).yMMMd}',
                                          style: BaseTypography.bodySmall
                                              .copyWith(
                                            color: isOverdue
                                                ? Colors.red
                                                : BaseColor.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Gap.h16,
                        ],
                      ),

                    // Quizzes Section
                    if (session.quizzes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.quiz,
                                size: 20,
                                color: Colors.purple,
                              ),
                              Gap.w8,
                              Text(
                                'Kuis',
                                style: BaseTypography.titleSmall.toBold,
                              ),
                            ],
                          ),
                          Gap.h8,
                          ...session.quizzes.map((quiz) {
                            final isActive = DateTime.now().isAfter(quiz.startTime) &&
                                DateTime.now().isBefore(quiz.endTime);
                            final hasAttempt = quiz.attempts.isNotEmpty;
                            
                            return InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoute.quizDetail,
                                  pathParameters: {
                                    'quizId': quiz.id.toString()
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: BaseSize.h8),
                                padding: EdgeInsets.all(BaseSize.w12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(BaseSize.radiusSm),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.quiz_outlined,
                                          color: Colors.purple,
                                          size: 20,
                                        ),
                                        Gap.w12,
                                        Expanded(
                                          child: Text(
                                            quiz.title,
                                            style: BaseTypography.bodyMedium
                                                .toBold,
                                          ),
                                        ),
                                        if (isActive && !hasAttempt)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: BaseSize.w8,
                                              vertical: BaseSize.h4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      BaseSize.radiusSm),
                                            ),
                                            child: Text(
                                              'Active',
                                              style: BaseTypography.bodySmall
                                                  .toWhite,
                                            ),
                                          ),
                                        if (hasAttempt)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: BaseSize.w8,
                                              vertical: BaseSize.h4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      BaseSize.radiusSm),
                                            ),
                                            child: Text(
                                              'Completed',
                                              style: BaseTypography.bodySmall
                                                  .toWhite,
                                            ),
                                          ),
                                      ],
                                    ),
                                    Gap.h4,
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 14,
                                          color: BaseColor.grey,
                                        ),
                                        Gap.w4,
                                        Text(
                                          '${quiz.duration} menit',
                                          style:
                                              BaseTypography.bodySmall.toGrey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              Gap.h16,
              Text(
                message,
                style: BaseTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(courseControllerProvider(kelasId).notifier)
                      .loadCourseContent();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
