import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';

import '../../../presentation.dart';

class QuizAttemptsScreen extends ConsumerStatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizAttemptsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  ConsumerState<QuizAttemptsScreen> createState() => _QuizAttemptsScreenState();
}

class _QuizAttemptsScreenState extends ConsumerState<QuizAttemptsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadQuizAttempts(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(elearningLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(title:'Hasil Kuis: ${widget.quizTitle}'),
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
                    .loadQuizAttempts(widget.quizId);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state is QuizAttemptsLoaded) {
      final attempts = state.attempts;

      if (attempts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('Belum ada attempt'),
            ],
          ),
        );
      }

      // Calculate statistics
        final int totalAttempts = attempts.length;
        final double averageScore = attempts.isNotEmpty
          ? attempts
              .map((attempt) => attempt.score.toDouble())
              .reduce((sum, score) => sum + score) /
            totalAttempts
          : 0;
        final double highestScore = attempts.isNotEmpty
          ? attempts
            .map((attempt) => attempt.score.toDouble())
            .reduce((a, b) => a > b ? a : b)
          : 0;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics
            Text(
              'Statistik',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BaseColor.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard('Total', totalAttempts.toString(), Colors.blue),
                _buildStatCard('Rata-rata',
                    averageScore.toStringAsFixed(1), Colors.green),
                _buildStatCard('Tertinggi', highestScore.toString(), Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            // Attempts List
            Text(
              'Detail Attempts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BaseColor.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return _buildAttemptCard(attempt, index);
              },
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptCard(dynamic attempt, int index) {
    final score = attempt.score;
    final maxScore = 100; // Assuming max score is 100
    final percentage = (score / maxScore) * 100;
    final statusColor = percentage >= 75
        ? Colors.green
        : percentage >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mahasiswa #${attempt.studentId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waktu Selesai: ${attempt.finishedAt?.toString().split('.')[0] ?? '-'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BaseColor.primaryText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              Text(
                percentage >= 75
                    ? 'Lulus'
                    : percentage >= 50
                        ? 'Cukup'
                        : 'Tidak Lulus',
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
