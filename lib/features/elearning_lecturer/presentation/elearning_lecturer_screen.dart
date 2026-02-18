import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../presentation.dart';

class ElearningLecturerScreen extends ConsumerStatefulWidget {
  const ElearningLecturerScreen({super.key});

  @override
  ConsumerState<ElearningLecturerScreen> createState() =>
      _ElearningLecturerScreenState();
}

class _ElearningLecturerScreenState
    extends ConsumerState<ElearningLecturerScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadLecturerCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(elearningLecturerControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        title: 'E-Learning Dosen',
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            profileState.maybeWhen(
              loaded: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${user.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BaseColor.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NIP: ${user.nip ?? "-"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: BaseColor.primaryText.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),

            // Title
            const Text(
              'Kelas yang Anda Ampu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BaseColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Course List
            _buildContent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ElearningLecturerState state) {
    if (state is ElearningLecturerLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ElearningLecturerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .loadLecturerCourses();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is CourseListLoaded) {
      if (state.courses.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Anda belum mengampu kelas',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          return _CourseCard(course: course);
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseManagementScreen(
              kelasId: course.id as int,
              courseName: (course.mataKuliah?.name ?? course.nama) as String,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color header
            Container(
              height: 8,
              decoration: const BoxDecoration(
                color: BaseColor.primaryInspire,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.kode,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: BaseColor.primaryInspire,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Course name
                    Expanded(
                      child: Text(
                        course.mataKuliah?.name ?? course.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: BaseColor.primaryText,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Class info
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${course.kapasitas ?? 0} mhs',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (course.ruangan != null)
                      Row(
                        children: [
                          const Icon(Icons.room, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.ruangan!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
