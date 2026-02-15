import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/features/elearning/presentation/controllers/course_list_controller.dart';
import 'package:inspire/features/elearning/presentation/states/course_list_state.dart';

import '../../../core/constants/constants.dart';

class ElearningScreen extends ConsumerStatefulWidget {
  const ElearningScreen({super.key});

  @override
  ConsumerState<ElearningScreen> createState() => _ElearningScreenState();
}

class _ElearningScreenState extends ConsumerState<ElearningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseListControllerProvider.notifier).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseListState = ref.watch(courseListControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'E-Learning',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gap.h16,
          // ScreenTitleWidget.titleOnly(title: 'E-Learning'),
          Gap.h20,
          ButtonWidget.primary(
            text: 'Cari Course',
            color: BaseColor.primaryInspire,
            onTap: () {},
          ),
          Gap.h12,
          Text('Daftar Course Anda', style: BaseTypography.titleLarge.toBold),
          Gap.h24,
          Expanded(
            child: courseListState.maybeWhen(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (courses) {
                if (courses.isEmpty) {
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
                          'Belum ada course terdaftar',
                          style: BaseTypography.bodyLarge.toGrey,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1.25,
                    crossAxisSpacing: BaseSize.w8,
                    mainAxisSpacing: BaseSize.h12,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _buildElearningCard(context, course);
                  },
                );
              },
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    Gap.h16,
                    Text(
                      'Gagal memuat course',
                      style: BaseTypography.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    Gap.h8,
                    Text(
                      message,
                      style: BaseTypography.bodySmall.toGrey,
                      textAlign: TextAlign.center,
                    ),
                    Gap.h16,
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(courseListControllerProvider.notifier)
                            .loadCourses();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElearningCard(BuildContext context, dynamic course) {
    final id = course.id;
    final courseName = course.mataKuliah?.name ?? course.nama;
    final courseCode = course.kode;
    final description = course.mataKuliah?.deskripsi ?? 'Tidak ada deskripsi';
    final dosenName = course.dosen?.name;

    return GestureDetector(
      key: ValueKey(id),
      onTap: () {
        context.pushNamed(
          AppRoute.courseDetail,
          pathParameters: {'kelasId': id.toString()},
          queryParameters: {'courseName': '$courseName - $courseCode'},
        );
      },
      child: SizedBox(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          color: BaseColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildCourseImage(),
                  ),
                ),

                // Course Info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(BaseSize.w12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Name - max 2 lines
                        Text(
                          courseName,
                          style: BaseTypography.bodyMedium.toBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        // Course Code - 1 line
                        Text(
                          courseCode,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.primaryInspire,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.h4,
                        // Description - max 1 lines
                        Expanded(
                          child: Text(
                            description,
                            style: BaseTypography.bodySmall.copyWith(
                              color: BaseColor.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dosenName != null) ...[
                          Gap.h4,
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: BaseColor.grey,
                              ),
                              Gap.w4,
                              Expanded(
                                child: Text(
                                  dosenName,
                                  style: BaseTypography.bodySmall.copyWith(
                                    color: BaseColor.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    return Container(
      width: double.infinity,
      color: BaseColor.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 40, color: BaseColor.grey[400]),
          Gap.h8,
          Text(
            'Course Image',
            style: TextStyle(fontSize: 12, color: BaseColor.grey[500]),
          ),
        ],
      ),
    );
  }
}
