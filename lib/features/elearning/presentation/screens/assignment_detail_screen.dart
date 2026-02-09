import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart'; // SkeletonLoading
import 'package:inspire/features/elearning/presentation/controllers/assignment_controller.dart';
import 'package:inspire/features/elearning/presentation/states/assignment_state.dart';

class AssignmentDetailScreen extends ConsumerStatefulWidget {
  final String assignmentId;

  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends ConsumerState<AssignmentDetailScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assignmentControllerProvider.notifier).loadAssignmentDetail(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assignmentControllerProvider);

    return ScaffoldWidget(
      appBar: const AppBarWidget(title: 'Detail Tugas'),
      child: state.maybeWhen(
        loading: () => _buildSkeleton(),
        loaded: (assignment) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.title, style: BaseTypography.headlineSmall),
            Gap.h8,
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.red),
                Gap.w4,
                Text(
                  'Deadline: ${assignment.deadline}', // Gunakan formatter date Anda
                  style: BaseTypography.bodySmall.copyWith(color: Colors.red),
                ),
              ],
            ),
            Gap.h16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BaseColor.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                assignment.description ?? 'Tidak ada deskripsi',
                style: BaseTypography.bodyMedium,
              ),
            ),
            Gap.h24,
            
            // Status Submission
            Text('Pengumpulan Tugas', style: BaseTypography.titleMedium.toBold),
            Gap.h12,
            if (assignment.submission != null) 
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    Gap.w8,
                    Expanded(
                        child: Text(
                            'Sudah dikumpulkan pada ${assignment.submission!.submittedAt}')),
                  ],
                ),
              )
            else
              _buildSubmissionForm(assignment.id),
          ],
        ),
        // Handle state submitting (saat tombol kirim ditekan)
        submitting: () => const Center(child: CircularProgressIndicator()),
        submitted: (submission) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
               Gap.h16,
               const Text("Berhasil Dikirim!"),
               Gap.h16,
               ButtonWidget.primary(
                 text: "Kembali", 
                 onTap: () => ref.read(assignmentControllerProvider.notifier).loadAssignmentDetail(widget.assignmentId)
               )
            ],
          ),
        ),
        error: (msg) => Center(child: Text(msg)),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSubmissionForm(String id) {
    return Column(
      children: [
        InputWidget.text(
          controller: _urlController,
          label: 'Link File Tugas (Gdrive/Github)',
          hint: 'https://...',
        ),
        Gap.h12,
        InputWidget.text(
          controller: _textController,
          label: 'Catatan Tambahan',
          maxLines: 3,
        ),
        Gap.h24,
        ButtonWidget.primary(
          text: 'Kirim Tugas',
          onTap: () {
            ref.read(assignmentControllerProvider.notifier).submitAssignment(
              assignmentId: int.parse(id), // Pastikan tipe data sesuai (int/string)
              fileUrl: _urlController.text,
              textContent: _textController.text,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoading(height: 32, width: 200),
        Gap.h12,
        const SkeletonLoading(height: 100, width: double.infinity),
        Gap.h24,
        const SkeletonLoading(height: 24, width: 150),
        Gap.h12,
        const SkeletonLoading(height: 50, width: double.infinity),
      ],
    );
  }
}