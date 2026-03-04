import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/classroom/presentation/controllers/classroom_controllers.dart';
import 'package:inspire/features/classroom/presentation/states/classroom_states.dart';

/// Layar untuk Dosen melihat daftar mahasiswa di satu kelas Google Classroom.
class ClassroomStudentsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final String accessToken;

  const ClassroomStudentsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.accessToken,
  });

  @override
  ConsumerState<ClassroomStudentsScreen> createState() =>
      _ClassroomStudentsScreenState();
}

class _ClassroomStudentsScreenState
    extends ConsumerState<ClassroomStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(classroomStudentsControllerProvider(widget.courseId).notifier)
          .loadStudents(widget.accessToken, widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(classroomStudentsControllerProvider(widget.courseId));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Mahasiswa – ${widget.courseName}',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      disableSingleChildScrollView: true,
      child: _buildContent(state),
    );
  }

  Widget _buildContent(ClassroomStudentsState state) {
    if (state is ClassroomStudentsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
      );
    }

    if (state is ClassroomStudentsError) {
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
                    .read(classroomStudentsControllerProvider(widget.courseId)
                        .notifier)
                    .loadStudents(widget.accessToken, widget.courseId),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ClassroomStudentsLoaded) {
      return Column(
        children: [
          // Header jumlah mahasiswa
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
                horizontal: BaseSize.w16, vertical: BaseSize.h12),
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: const Color(0xFF34A853).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                  color: const Color(0xFF34A853).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF34A853), size: 24),
                Gap.w12,
                Text(
                  '${state.students.length} Mahasiswa terdaftar',
                  style: BaseTypography.bodyMedium.toBold,
                ),
              ],
            ),
          ),

          // Daftar mahasiswa
          Expanded(
            child: state.students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off,
                            size: 56, color: BaseColor.grey),
                        Gap.h16,
                        Text('Belum ada mahasiswa terdaftar',
                            style: BaseTypography.bodyLarge.toGrey),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
                    itemCount: state.students.length,
                    itemBuilder: (context, index) {
                      final student = state.students[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: BaseSize.h8),
                        elevation: 1,
                        color: BaseColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BaseSize.radiusMd),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: BaseSize.w16,
                            vertical: BaseSize.h8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _avatarColor(student.fullName),
                            backgroundImage: student.photoUrl != null
                                ? NetworkImage(student.photoUrl!)
                                : null,
                            child: student.photoUrl == null
                                ? Text(
                                    student.fullName.isNotEmpty
                                        ? student.fullName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            student.fullName,
                            style: BaseTypography.bodyMedium.toBold,
                          ),
                          subtitle: Text(
                            student.emailAddress,
                            style: BaseTypography.bodySmall.toGrey,
                          ),
                          trailing: Text(
                            '#${index + 1}',
                            style: BaseTypography.bodySmall.toGrey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFF188038),
      const Color(0xFFD93025),
      const Color(0xFFF29900),
      const Color(0xFF9334E6),
      const Color(0xFF00897B),
    ];
    if (name.isEmpty) return colors[0];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}
