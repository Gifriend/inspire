import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/elearning/quiz_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class QuizTakingScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizTakingScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends ConsumerState<QuizTakingScreen> {
  Timer? _timer;
  late Duration _remainingTime;
  int _currentQuestionIndex = 0;
  final Map<String, String> _answers = {};
  final Map<String, TextEditingController> _essayControllers = {};

  @override
  void initState() {
    super.initState();

    if (widget.quiz.attempts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Quiz Sudah Dikerjakan'),
              content: const Text('Anda telah mengerjakan quiz ini.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (mounted) {
            context.pop(); // Navigate back
          }
        }
      });
      return;
    }

    _remainingTime = Duration(minutes: widget.quiz.duration);

    if (widget.quiz.questions.isEmpty) return;

    _startTimer();

    // Initialize essay controllers
    for (final q in widget.quiz.questions) {
      if (q.type == QuestionType.essay) {
        _essayControllers[q.id] = TextEditingController();
      }
    }

    // Initialize quiz state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(quizControllerProvider.notifier)
            .setAnswer(widget.quiz.questions[0].id, '', widget.quiz);
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _essayControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitQuiz() async {
    final answers = _answers.entries.map((entry) {
      return {
        'questionId':
            entry.key, // Convert question.id to number (adjust if not a string)
        'answer': entry.value,
      };
    }).toList();

    // Build the payload to match SubmitQuizDto
    final payload = {
      'quizId':
          widget.quiz.id, // Convert quiz.id to number (adjust if not a string)
      'answers': answers,
    };

    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kirim Jawaban?'),
        content: Text(
          'Anda telah menjawab ${_answers.length} dari ${widget.quiz.questions.length} soal.\n\nApakah Anda yakin ingin mengirim jawaban?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: BaseColor.primaryInspire,
            ),
            child: Text('Kirim', style: TextStyle(color: BaseColor.white)),
          ),
        ],
      ),
    );

    if (shouldSubmit == true && mounted) {
      await ref.read(quizControllerProvider.notifier).submitQuiz(payload);

      if (mounted) {
        final state = ref.read(quizControllerProvider);
        final isError = state.maybeWhen(
          error: (_) => true,
          orElse: () => false,
        );

        if (!isError) {
          await ref
              .read(quizControllerProvider.notifier)
              .loadQuizDetail(widget.quiz.id);
        }

        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isError ? 'Gagal mengirim jawaban' : 'Jawaban berhasil dikirim',
            ),
            backgroundColor: isError ? Colors.red : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          backgroundColor: BaseColor.primaryInspire,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Quiz ini belum memiliki soal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final quizState = ref.watch(quizControllerProvider);
    final question = widget.quiz.questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar dari Kuis?'),
            content: const Text(
              'Progres Anda akan hilang jika keluar sekarang.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );

        if (shouldExit == true && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          automaticallyImplyLeading: false,
          backgroundColor: BaseColor.primaryInspire,
          foregroundColor: Colors.white,
          actions: [
            Center(
              child: Container(
                margin: EdgeInsets.only(right: BaseSize.w16),
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w12,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: _remainingTime.inMinutes < 5
                      ? Colors.red
                      : Colors.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: _remainingTime.inMinutes < 5
                          ? Colors.white
                          : BaseColor.primaryInspire,
                    ),
                    Gap.w4,
                    Text(
                      _formatDuration(_remainingTime),
                      style: BaseTypography.bodyMedium.toBold.copyWith(
                        color: _remainingTime.inMinutes < 5
                            ? Colors.white
                            : BaseColor.primaryInspire,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: quizState.maybeWhen(
          submitting: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mengirim jawaban...'),
              ],
            ),
          ),

          submitted: (attempt) => Center(
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Jawaban berhasil dikirim!',
                    style: BaseTypography.titleLarge.toBold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  // Optionally display attempt details, e.g., score
                  // Text('Skor: ${attempt.score ?? 'N/A'}'),
                  ElevatedButton(
                    onPressed: () => context.pop(), // Navigate back
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),

          orElse: () => Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value:
                    (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  BaseColor.primaryInspire,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(BaseSize.w16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Soal ${_currentQuestionIndex + 1} dari ${widget.quiz.questions.length}',
                            style: BaseTypography.titleMedium.toBold.copyWith(
                              color: BaseColor.primaryInspire,
                            ),
                          ),
                          Text(
                            '${question.points.toStringAsFixed(0)} poin',
                            style: BaseTypography.bodyMedium.toGrey,
                          ),
                        ],
                      ),
                      Gap.h16,

                      // Question Text
                      Text(question.text, style: BaseTypography.bodyLarge),
                      Gap.h24,

                      // Answer Options
                      if (question.type == QuestionType.multipleChoice)
                        ...question.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final optionLabel = String.fromCharCode(
                            65 + index,
                          ); // A, B, C, D...
                          final isSelected = _answers[question.id] == option;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _answers[question.id] = option;
                              });
                              ref
                                  .read(quizControllerProvider.notifier)
                                  .setAnswer(question.id, option, widget.quiz);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: BaseSize.h12),
                              padding: EdgeInsets.all(BaseSize.w16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? BaseColor.primaryInspire
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  BaseSize.radiusMd,
                                ),
                                color: isSelected
                                    ? BaseColor.primaryInspire.withValues(alpha: 0.05)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? BaseColor.primaryInspire
                                          : Colors.grey[200],
                                    ),
                                    child: Center(
                                      child: Text(
                                        optionLabel,
                                        style: BaseTypography.bodyMedium.toBold
                                            .copyWith(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Gap.w12,
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: BaseTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      else if (question.type == QuestionType.trueFalse)
                        Column(
                          children: [
                            _TrueFalseOption(
                              label: 'Benar',
                              value: 'true',
                              isSelected: _answers[question.id] == 'true',
                              onTap: () {
                                setState(() {
                                  _answers[question.id] = 'true';
                                });
                                ref
                                    .read(quizControllerProvider.notifier)
                                    .setAnswer(
                                      question.id,
                                      'true',
                                      widget.quiz,
                                    );
                              },
                            ),
                            Gap.h12,
                            _TrueFalseOption(
                              label: 'Salah',
                              value: 'false',
                              isSelected: _answers[question.id] == 'false',
                              onTap: () {
                                setState(() {
                                  _answers[question.id] = 'false';
                                });
                                ref
                                    .read(quizControllerProvider.notifier)
                                    .setAnswer(
                                      question.id,
                                      'false',
                                      widget.quiz,
                                    );
                              },
                            ),
                          ],
                        )
                      else if (question.type == QuestionType.essay)
                        TextField(
                          controller: _essayControllers[question.id],
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Tulis jawaban Anda di sini...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                BaseSize.radiusMd,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            _answers[question.id] = value;
                            ref
                                .read(quizControllerProvider.notifier)
                                .setAnswer(question.id, value, widget.quiz);
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Navigation Buttons
              Container(
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: ButtonWidget.outlined(
                          text: 'Sebelumnya',
                          padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                          onTap: _previousQuestion,
                        ),
                      ),
                    if (_currentQuestionIndex > 0) Gap.w12,
                    Expanded(
                      flex: 2,
                      child:
                          _currentQuestionIndex <
                              widget.quiz.questions.length - 1
                          ? ButtonWidget.primary(
                              text: 'Selanjutnya',
                              padding: EdgeInsets.symmetric(
                                vertical: BaseSize.h12,
                              ),
                              onTap: _nextQuestion,
                            )
                          : ButtonWidget.primary(
                              text: 'Kirim Jawaban',
                              onTap: _submitQuiz,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}

class _TrueFalseOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TrueFalseOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? BaseColor.primaryInspire : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          color: isSelected ? BaseColor.primaryInspire.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? BaseColor.primaryInspire : Colors.grey,
            ),
            Gap.w12,
            Text(
              label,
              style: BaseTypography.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
