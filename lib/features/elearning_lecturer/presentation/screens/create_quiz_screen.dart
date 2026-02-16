import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../core/models/models.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  final List<SessionModel> sessions;
  final int kelasId;

  const CreateQuizScreen({
    super.key,
    required this.sessions,
    required this.kelasId,
  });

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedSessionId;
  DateTime? _startTime;
  DateTime? _endTime;
  String _gradingMethod = 'LATEST';
  bool _hideGrades = false;
  bool _hideUntilDeadline = false;

  final List<QuestionData> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionData());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih sesi terlebih dahulu')),
      );
      return;
    }
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih waktu mulai dan selesai')),
      );
      return;
    }
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 soal')),
      );
      return;
    }

    // Validate all questions
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (!question.isValid()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soal ${i + 1} belum lengkap')),
        );
        return;
      }
    }

    final questionsData =
        _questions.map((q) => q.toJson()).toList();

    try {
      await ref.read(elearningLecturerControllerProvider.notifier).createQuiz(
            title: _titleController.text,
            duration: int.parse(_durationController.text),
            startTime: _startTime!,
            endTime: _endTime!,
            gradingMethod: _gradingMethod,
            sessionId: _selectedSessionId!,
            questions: questionsData,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kuis berhasil dibuat')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat kuis: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(title: 'Buat Kuis'),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Session Selection
            DropdownButtonFormField<String>(
              value: _selectedSessionId,
              decoration: const InputDecoration(
                labelText: 'Pilih Sesi',
                border: OutlineInputBorder(),
              ),
              items: widget.sessions.map((session) {
                return DropdownMenuItem(
                  value: session.id,
                  child: Text('Minggu ${session.weekNumber}: ${session.title}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSessionId = value;
                });
              },
              validator: (value) => value == null ? 'Pilih sesi' : null,
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Kuis',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Judul harus diisi' : null,
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Durasi (menit)',
                border: OutlineInputBorder(),
                suffixText: 'menit',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Durasi harus diisi';
                if (int.tryParse(value!) == null) return 'Durasi harus angka';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Start Time
            InkWell(
              onTap: () => _pickDateTime(true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Waktu Mulai',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startTime == null
                          ? 'Pilih waktu mulai'
                          : Jiffy.parseFromDateTime(_startTime!)
                              .format(pattern: 'dd MMM yyyy, HH:mm'),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Time
            InkWell(
              onTap: () => _pickDateTime(false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Waktu Selesai',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endTime == null
                          ? 'Pilih waktu selesai'
                          : Jiffy.parseFromDateTime(_endTime!)
                              .format(pattern: 'dd MMM yyyy, HH:mm'),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grading Method
            DropdownButtonFormField<String>(
              value: _gradingMethod,
              decoration: const InputDecoration(
                labelText: 'Metode Penilaian',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'LATEST', child: Text('Nilai Terakhir')),
                DropdownMenuItem(value: 'HIGHEST', child: Text('Nilai Tertinggi')),
                DropdownMenuItem(value: 'AVERAGE', child: Text('Rata-rata')),
              ],
              onChanged: (value) {
                setState(() {
                  _gradingMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Settings
            const Text(
              'Pengaturan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Sembunyikan Nilai dari Mahasiswa'),
              value: _hideGrades,
              onChanged: (value) {
                setState(() {
                  _hideGrades = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Sembunyikan Sampai Deadline'),
              value: _hideUntilDeadline,
              onChanged: (value) {
                setState(() {
                  _hideUntilDeadline = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),

            // Questions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Soal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Soal'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Questions List
            if (_questions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada soal\nTambahkan soal dengan tombol di atas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return _QuestionCard(
                  index: index,
                  question: question,
                  onDelete: () => _removeQuestion(index),
                );
              }),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primaryInspire,
                ),
                onPressed: _submitQuiz,
                child: const Text(
                  'Buat Kuis',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class QuestionData {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  String type = 'MULTIPLE_CHOICE';
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  String correctAnswer = '';

  QuestionData() {
    pointsController.text = '10';
  }

  void dispose() {
    questionController.dispose();
    pointsController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
  }

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    }
  }

  bool isValid() {
    if (questionController.text.isEmpty) return false;
    if (pointsController.text.isEmpty || int.tryParse(pointsController.text) == null) {
      return false;
    }
    
    if (type == 'MULTIPLE_CHOICE' || type == 'TRUE_FALSE') {
      // Check if all options are filled
      for (var controller in optionControllers) {
        if (controller.text.isEmpty) return false;
      }
      // Check if correct answer is selected
      if (correctAnswer.isEmpty) return false;
    }
    
    return true;
  }

  Map<String, dynamic> toJson() {
    final options = <String>[];
    for (var controller in optionControllers) {
      options.add(controller.text);
    }

    return {
      'question': questionController.text,
      'type': type,
      'points': int.parse(pointsController.text),
      if (type != 'ESSAY') 'options': options,
      if (type != 'ESSAY') 'correctAnswer': correctAnswer,
    };
  }
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final QuestionData question;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onDelete,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soal ${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Points
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: widget.question.pointsController,
                        decoration: const InputDecoration(
                          labelText: 'Poin',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Type
            DropdownButtonFormField<String>(
              value: widget.question.type,
              decoration: const InputDecoration(
                labelText: 'Tipe Soal',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'MULTIPLE_CHOICE', child: Text('Pilihan Ganda')),
                DropdownMenuItem(value: 'TRUE_FALSE', child: Text('Benar/Salah')),
                DropdownMenuItem(value: 'ESSAY', child: Text('Essay')),
              ],
              onChanged: (value) {
                setState(() {
                  widget.question.type = value!;
                  widget.question.correctAnswer = '';

                  // For TRUE_FALSE, set predefined options
                  if (value == 'TRUE_FALSE') {
                    widget.question.optionControllers.clear();
                    widget.question.optionControllers.add(
                      TextEditingController(text: 'Benar'),
                    );
                    widget.question.optionControllers.add(
                      TextEditingController(text: 'Salah'),
                    );
                  }
                  // For ESSAY, clear options
                  else if (value == 'ESSAY') {
                    for (var controller in widget.question.optionControllers) {
                      controller.dispose();
                    }
                    widget.question.optionControllers.clear();
                  }
                  // For MULTIPLE_CHOICE, ensure at least 2 options
                  else if (value == 'MULTIPLE_CHOICE' &&
                      widget.question.optionControllers.length < 2) {
                    widget.question.optionControllers.clear();
                    widget.question.optionControllers.add(TextEditingController());
                    widget.question.optionControllers.add(TextEditingController());
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Question Text
            TextFormField(
              controller: widget.question.questionController,
              decoration: const InputDecoration(
                labelText: 'Pertanyaan',
                border: OutlineInputBorder(),
                hintText: 'Tulis pertanyaan di sini...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Options (for MULTIPLE_CHOICE and TRUE_FALSE)
            if (widget.question.type != 'ESSAY') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilihan Jawaban',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (widget.question.type == 'MULTIPLE_CHOICE')
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.question.addOption();
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah Opsi'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.question.optionControllers.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final controller = entry.value;
                final optionLabel =
                    String.fromCharCode(65 + optionIndex); // A, B, C, D...

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: controller.text,
                        groupValue: widget.question.correctAnswer,
                        onChanged: (value) {
                          setState(() {
                            widget.question.correctAnswer = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Opsi $optionLabel',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            // Update correct answer if this option was previously selected
                            if (widget.question.correctAnswer ==
                                controller.text) {
                              setState(() {
                                widget.question.correctAnswer = value;
                              });
                            }
                          },
                          readOnly: widget.question.type == 'TRUE_FALSE',
                        ),
                      ),
                      if (widget.question.type == 'MULTIPLE_CHOICE' &&
                          widget.question.optionControllers.length > 2)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.question.removeOption(optionIndex);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
              if (widget.question.correctAnswer.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Jawaban benar: ${widget.question.correctAnswer}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],

            // Essay note
            if (widget.question.type == 'ESSAY')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Essay akan dinilai secara manual oleh dosen',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
