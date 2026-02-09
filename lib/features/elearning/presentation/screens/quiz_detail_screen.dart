import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/routing/routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

class QuizDetailScreen extends ConsumerStatefulWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends ConsumerState<QuizDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).loadQuizDetail(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);

    return ScaffoldWidget(
      appBar:  AppBarWidget(title: 'Detail Kuis',backgorundColor: BaseColor.primaryInspire, ),
      child: quizState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
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
                onTap: () => ref.read(quizControllerProvider.notifier).loadQuizDetail(widget.quizId),
              ),
            ],
          ),
        ),
        loaded: (quiz) {
          final now = DateTime.now();
          final isBeforeStart = now.isBefore(quiz.startTime);
          final isActive = now.isAfter(quiz.startTime) && now.isBefore(quiz.endTime);
          final isExpired = now.isAfter(quiz.endTime);
          final hasAttempt = quiz.attempts.isNotEmpty;

          return SingleChildScrollView(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(quiz.title, style: BaseTypography.headlineSmall),
                Gap.h8,

                // Status Badge
                if (isBeforeStart)
                  _StatusBadge(text: 'Belum Dimulai', color: Colors.grey)
                else if (isActive)
                  _StatusBadge(text: 'Aktif', color: Colors.green)
                else if (isExpired)
                  _StatusBadge(text: 'Berakhir', color: Colors.red),
                Gap.h16,

                // Description
                if (quiz.description != null && quiz.description!.isNotEmpty) ...[
                  Text('Deskripsi', style: BaseTypography.titleMedium.toBold),
                  Gap.h8,
                  Text(quiz.description!, style: BaseTypography.bodyMedium),
                  Gap.h24,
                ],

                // Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(BaseSize.w16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.access_time,
                          label: 'Durasi',
                          value: '${quiz.duration} menit',
                        ),
                        Gap.h12,
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Mulai',
                          value: Jiffy.parse(quiz.startTime.toString()).yMMMdjm,
                        ),
                        Gap.h12,
                        _InfoRow(
                          icon: Icons.event,
                          label: 'Berakhir',
                          value: Jiffy.parse(quiz.endTime.toString()).yMMMdjm,
                        ),
                        Gap.h12,
                        _InfoRow(
                          icon: Icons.quiz,
                          label: 'Jumlah Soal',
                          value: '${quiz.questions.length} soal',
                        ),
                        Gap.h12,
                        _InfoRow(
                          icon: Icons.grade,
                          label: 'Metode Penilaian',
                          value: _getGradingMethodText(quiz.gradingMethod.name),
                        ),
                      ],
                    ),
                  ),
                ),
                Gap.h24,

                // Attempts History
                if (hasAttempt) ...[
                  Text('Riwayat Percobaan', style: BaseTypography.titleMedium.toBold),
                  Gap.h12,
                  ...quiz.attempts.map((attempt) => Card(
                    margin: EdgeInsets.only(bottom: BaseSize.h8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getScoreColor(attempt.score.toDouble()),
                        child: Text(
                          attempt.score.toStringAsFixed(0),
                          style: BaseTypography.titleSmall.toBold.toWhite,
                        ),
                      ),
                      title: Text('Percobaan ${quiz.attempts.indexOf(attempt) + 1}'),
                      subtitle: Text(
                        'Selesai: ${Jiffy.parse(attempt.finishedAt?.toString() ?? attempt.startedAt.toString()).fromNow()}',
                        style: BaseTypography.bodySmall.toGrey,
                      ),
                      trailing: Text(
                        '${attempt.score.toStringAsFixed(1)}',
                        style: BaseTypography.titleMedium.toBold,
                      ),
                    ),
                  )),
                  Gap.h24,
                ],

                // Start Button
                if (!hasAttempt)
                  SizedBox(
                    width: double.infinity,
                    child: ButtonWidget.primary(
                      color: BaseColor.primaryInspire,
                      text: 'Mulai Kuis',
                      onTap: () {
                        context.pushNamed(
                          AppRoute.quizTaking,
                          pathParameters: {'quizId': widget.quizId},
                          extra: quiz,
                        );
                      },
                    ),
                  )
                  else if (hasAttempt)
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Anda telah menyelesaikan kuis ini.',
                        style: BaseTypography.titleMedium.toBold,
                      ),
                    ),
                  )
                else if (isBeforeStart)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(BaseSize.w16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        Gap.w12,
                        Expanded(
                          child: Text(
                            'Kuis belum dimulai. Silakan tunggu hingga waktu mulai.',
                            style: BaseTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isExpired)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(BaseSize.w16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        Gap.w12,
                        Expanded(
                          child: Text(
                            'Kuis telah berakhir.',
                            style: BaseTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        taking: (quiz, answers) => const SizedBox.shrink(),
        submitting: () => const Center(child: CircularProgressIndicator()),
        submitted: (attempt) => const SizedBox.shrink(),
      ),
    );
  }

  String _getGradingMethodText(String method) {
    switch (method) {
      case 'HIGHEST_GRADE':
        return 'Nilai Tertinggi';
      case 'AVERAGE_GRADE':
        return 'Nilai Rata-rata';
      case 'LATEST_GRADE':
        return 'Nilai Terakhir';
      default:
        return method;
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12, vertical: BaseSize.h4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Text(
        text,
        style: BaseTypography.bodySmall.toBold.copyWith(color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: BaseColor.primaryInspire),
        Gap.w12,
        Expanded(
          child: Text(label, style: BaseTypography.bodyMedium.toGrey),
        ),
        Text(value, style: BaseTypography.bodyMedium.toBold),
      ],
    );
  }
}
