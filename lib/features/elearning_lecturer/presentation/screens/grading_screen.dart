import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/elearning_lecturer/presentation/elearning_lecturer_controller.dart';

import '../../../presentation.dart';

class GradingScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  final String assignmentTitle;

  const GradingScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  @override
  ConsumerState<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends ConsumerState<GradingScreen> {
  late TextEditingController _feedbackController;
  late TextEditingController _gradeController;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _gradeController = TextEditingController();

    // Load submissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadSubmissions(widget.assignmentId);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(elearningLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(title: 'Penilaian: ${widget.assignmentTitle}'),
      child: state is ElearningLecturerLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(state),
    );
  }

  Widget _buildContent(dynamic state) {
    if (state is ElearningLecturerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .loadSubmissions(widget.assignmentId);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is SubmissionsLoaded) {
      final submissions = state.submissions;

      if (submissions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Belum ada submission'),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];
          return _buildSubmissionCard(submission, index);
        },
      );
    }

    return const SizedBox();
  }

  Widget _buildSubmissionCard(dynamic submission, int index) {
    final isGraded = submission.grade != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGraded
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isGraded ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isGraded ? Icons.check_circle : Icons.pending,
                  color: isGraded ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.student?.name ?? 'Mahasiswa ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dikumpul: ${submission.submittedAt.toString().split('.')[0]}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaseColor.primaryText.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isGraded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    submission.grade ?? '-',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Submission Content
          Text(
            'Konten Submission:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: BaseColor.primaryText.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BaseColor.primaryText.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (submission.textContent != null) ...[
                  Text(
                    submission.textContent ?? '-',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
                if (submission.fileUrl != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.attachment, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          submission.fileUrl ?? 'File',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (submission.feedback != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    submission.feedback ?? '-',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Grade Form
          if (!isGraded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berikan Penilaian:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BaseColor.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _gradeController,
                  decoration: InputDecoration(
                    hintText: 'Nilai (0-100)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    hintText: 'Feedback (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _gradeController.clear();
                        _feedbackController.clear();
                      },
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _submitGrade(submission.id),
                      child: const Text('Simpan Nilai'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _submitGrade(String submissionId) {
    final grade = _gradeController.text.trim();
    final feedback = _feedbackController.text.trim();

    if (grade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai tidak boleh kosong')),
      );
      return;
    }

    ref.read(elearningLecturerControllerProvider.notifier).gradeSubmission(
          submissionId: submissionId,
          grade: grade,
          feedback: feedback,
        );

    _gradeController.clear();
    _feedbackController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Penilaian berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
