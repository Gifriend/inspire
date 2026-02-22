import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart' hide MaterialType;
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:go_router/go_router.dart';

class CourseManagementScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String courseName;

  const CourseManagementScreen({
    super.key,
    required this.kelasId,
    required this.courseName,
  });

  @override
  ConsumerState<CourseManagementScreen> createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState extends ConsumerState<CourseManagementScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadCourseDetail(widget.kelasId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen<ElearningLecturerState>(elearningLecturerControllerProvider, (
      previous,
      next,
    ) {
      if (!mounted) {
        return;
      }

      if (next is MaterialCreated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Materi berhasil dibuat')));
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is AssignmentCreated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tugas berhasil dibuat')));
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is QuizCreated) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kuis berhasil dibuat')));
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }
    });

    final state = ref.watch(elearningLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        title: widget.courseName,
      ),
      disableSingleChildScrollView: true,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('Materi', 0),
                  _buildTab('Tugas', 1),
                  _buildTab('Kuis', 2),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent(state)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? BaseColor.primaryInspire : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? BaseColor.primaryInspire
                : BaseColor.primaryText.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ElearningLecturerState state) {
    if (state is ElearningLecturerLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ElearningLecturerError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 54),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(elearningLecturerControllerProvider.notifier)
                      .loadCourseDetail(widget.kelasId);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! CourseDetailLoaded) {
      return const SizedBox.shrink();
    }

    final sessions = state.sessions;

    switch (_selectedTabIndex) {
      case 0:
        return _buildMaterialTab(sessions);
      case 1:
        return _buildAssignmentTab(sessions);
      case 2:
        return _buildQuizTab(sessions);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMaterialTab(List<SessionModel> sessions) {
    final materialsBySession = <_SessionMaterial>[];
    for (final session in sessions) {
      for (final material in session.materials) {
        materialsBySession.add(
          _SessionMaterial(session: session, material: material),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: sessions.isEmpty
              ? null
              : () => _showMaterialForm(sessions),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Materi'),
        ),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          _buildEmpty('Belum ada sesi pembelajaran di kelas ini')
        else if (materialsBySession.isEmpty)
          _buildEmpty('Belum ada materi pada semua sesi')
        else
          ...materialsBySession.map((item) => _buildMaterialCard(item)),
      ],
    );
  }

  Widget _buildMaterialCard(_SessionMaterial item) {
    final MaterialModel material = item.material;
    final SessionModel session = item.session;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  material.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  material.type.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          if ((material.content ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              material.content!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: BaseColor.primaryText.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignmentTab(List<SessionModel> sessions) {
    final assignmentsBySession = <_SessionAssignment>[];
    for (final session in sessions) {
      for (final assignment in session.assignments) {
        assignmentsBySession.add(
          _SessionAssignment(session: session, assignment: assignment),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: sessions.isEmpty
              ? null
              : () => _showAssignmentForm(sessions),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Tugas'),
        ),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          _buildEmpty('Belum ada sesi pembelajaran di kelas ini')
        else if (assignmentsBySession.isEmpty)
          _buildEmpty('Belum ada tugas pada semua sesi')
        else
          ...assignmentsBySession.map((item) => _buildAssignmentCard(item)),
      ],
    );
  }

  Widget _buildAssignmentCard(_SessionAssignment item) {
    final assignment = item.assignment;
    final session = item.session;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Deadline: ${_formatDateTime(assignment.deadline)}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.7),
            ),
          ),
          if ((assignment.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assignment.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: BaseColor.primaryText.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GradingScreen(
                      assignmentId: assignment.id,
                      assignmentTitle: assignment.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.grade),
              label: const Text('Nilai Tugas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab(List<SessionModel> sessions) {
    final quizzesBySession = <_SessionQuiz>[];
    for (final session in sessions) {
      for (final quiz in session.quizzes) {
        quizzesBySession.add(_SessionQuiz(session: session, quiz: quiz));
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: sessions.isEmpty
              ? null
              : () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateQuizScreen(
                        sessions: sessions,
                        kelasId: widget.kelasId,
                      ),
                    ),
                  );
                  if (!mounted) {
                    return;
                  }
                  ref
                      .read(elearningLecturerControllerProvider.notifier)
                      .loadCourseDetail(widget.kelasId);
                },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kuis'),
        ),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          _buildEmpty('Belum ada sesi pembelajaran di kelas ini')
        else if (quizzesBySession.isEmpty)
          _buildEmpty('Belum ada kuis pada semua sesi')
        else
          ...quizzesBySession.map((item) => _buildQuizCard(item)),
      ],
    );
  }

  Widget _buildQuizCard(_SessionQuiz item) {
    final quiz = item.quiz;
    final session = item.session;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quiz.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${quiz.duration} menit',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${quiz.questions.length} soal • ${_formatDateTime(quiz.startTime)} - ${_formatDateTime(quiz.endTime)}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizAttemptsScreen(
                      quizId: quiz.id,
                      quizTitle: quiz.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('Lihat Nilai Quiz'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: BaseColor.primaryText.withValues(alpha: 0.6)),
        ),
      ),
    );
  }

  Future<void> _showMaterialForm(List<SessionModel> sessions) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final fileUrlController = TextEditingController();

    String selectedSessionId = sessions.first.id;
    MaterialType selectedType = MaterialType.text;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool showContent =
                selectedType == MaterialType.text ||
                selectedType == MaterialType.hybrid;
            final bool showFile =
                selectedType == MaterialType.file ||
                selectedType == MaterialType.hybrid;

            return AlertDialog(
              title: const Text('Tambah Materi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownWidget<String>(
                      labelText: 'Sesi',
                      hintText: 'Pilih Sesi',
                      value: selectedSessionId,
                      items: sessions.map((s) => s.id).toList(),
                      itemLabelBuilder: (id) {
                        final session = sessions.firstWhere((s) => s.id == id);
                        return 'Minggu ${session.weekNumber}: ${session.title}';
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedSessionId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Materi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownWidget<MaterialType>(
                      labelText: 'Tipe Materi',
                      hintText: 'Pilih Tipe',
                      value: selectedType,
                      items: const [
                        MaterialType.text,
                        MaterialType.file,
                        MaterialType.hybrid,
                      ],
                      itemLabelBuilder: (type) => type.name.toUpperCase(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    if (showContent) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: contentController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Konten Materi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    if (showFile) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: fileUrlController,
                        decoration: const InputDecoration(
                          labelText: 'File URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    final fileUrl = fileUrlController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul materi wajib diisi'),
                        ),
                      );
                      return;
                    }

                    if ((selectedType == MaterialType.text ||
                            selectedType == MaterialType.hybrid) &&
                        content.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Konten materi wajib diisi'),
                        ),
                      );
                      return;
                    }

                    if ((selectedType == MaterialType.file ||
                            selectedType == MaterialType.hybrid) &&
                        fileUrl.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('File URL wajib diisi')),
                      );
                      return;
                    }

                    ref
                        .read(elearningLecturerControllerProvider.notifier)
                        .createMaterial(
                          title: title,
                          type: selectedType.name.toUpperCase(),
                          content: content.isEmpty ? null : content,
                          fileUrl: fileUrl.isEmpty ? null : fileUrl,
                          sessionId: selectedSessionId,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
    fileUrlController.dispose();
  }

  Future<void> _showAssignmentForm(List<SessionModel> sessions) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedSessionId = sessions.first.id;
    DateTime? selectedDeadline;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Tugas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownWidget<String>(
                      labelText: 'Sesi',
                      hintText: 'Pilih Sesi',
                      value: selectedSessionId,
                      items: sessions.map((s) => s.id).toList(),
                      itemLabelBuilder: (id) {
                        final session = sessions.firstWhere((s) => s.id == id);
                        return 'Minggu ${session.weekNumber}: ${session.title}';
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedSessionId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Tugas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (pickedDate == null || !mounted) {
                          return;
                        }

                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedDeadline = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        selectedDeadline == null
                            ? 'Pilih Deadline'
                            : _formatDateTime(selectedDeadline!),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul tugas wajib diisi'),
                        ),
                      );
                      return;
                    }

                    if (description.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Deskripsi tugas wajib diisi'),
                        ),
                      );
                      return;
                    }

                    if (selectedDeadline == null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Deadline wajib dipilih')),
                      );
                      return;
                    }

                    ref
                        .read(elearningLecturerControllerProvider.notifier)
                        .createAssignment(
                          title: title,
                          description: description,
                          deadline: selectedDeadline!,
                          sessionId: selectedSessionId,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Buat'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _SessionMaterial {
  final SessionModel session;
  final MaterialModel material;

  _SessionMaterial({required this.session, required this.material});
}

class _SessionAssignment {
  final SessionModel session;
  final AssignmentModel assignment;

  _SessionAssignment({required this.session, required this.assignment});
}

class _SessionQuiz {
  final SessionModel session;
  final QuizModel quiz;

  _SessionQuiz({required this.session, required this.quiz});
}