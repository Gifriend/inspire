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
        showSuccessAlertDialogWidget(context, title: 'Materi berhasil dibuat');
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is AssignmentCreated) {
        showSuccessAlertDialogWidget(context, title: 'Tugas berhasil dibuat');
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is QuizCreated) {
        showSuccessAlertDialogWidget(context, title: 'Kuis berhasil dibuat');
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is SetupClassSaved) {
        showSuccessAlertDialogWidget(context, title: next.message);
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is MergeClassesSaved) {
        showSuccessAlertDialogWidget(context, title: next.message);
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is UnmergeClassSaved) {
        showSuccessAlertDialogWidget(
          context,
          title: 'Kelas berhasil dipisahkan dari gabungan',
        );
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }

      if (next is VisibilityUpdated) {
        showSuccessAlertDialogWidget(
          context,
          title: 'Visibilitas konten berhasil diperbarui',
        );
        ref
            .read(elearningLecturerControllerProvider.notifier)
            .loadCourseDetail(widget.kelasId);
      }
    });

    final state = ref.watch(elearningLecturerControllerProvider);
    final loadedState = state is CourseDetailLoaded ? state : null;
    final isClassStarted = loadedState != null
        ? _hasClassStarted(loadedState)
        : false;

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
          if (loadedState != null && !isClassStarted)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildPreClassSetupCard(loadedState),
            )
          else
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
              Gap.h12,
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              Gap.h12,
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

    final loaded = state;

    if (!_hasClassStarted(loaded)) {
      return _buildPreClassSetupBody();
    }

    switch (_selectedTabIndex) {
      case 0:
        return _buildMaterialTab(loaded);
      case 1:
        return _buildAssignmentTab(loaded);
      case 2:
        return _buildQuizTab(loaded);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMaterialTab(CourseDetailLoaded loaded) {
    final sessions = loaded.sessions;
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
        Gap.h16,
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
          Gap.h8,
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          if ((material.content ?? '').isNotEmpty) ...[
            Gap.h8,
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
          Gap.h8,
          Align(
            alignment: Alignment.centerRight,
            child: ButtonWidget.outlined(
              buttonSize: ButtonSize.small,
              onTap: () {
                ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .toggleVisibility(
                      entityType: ElearningEntityType.material,
                      entityId: material.id,
                      isHidden: !material.isHidden,
                    );
              },
              icon: material.isHidden
                  ? Assets.icons.fill.eyeOff.svg(width: BaseSize.customHeight(10.0), height: BaseSize.customHeight(10.0))
                  : Assets.icons.fill.eyeOn.svg(width: BaseSize.customHeight(10.0), height: BaseSize.customHeight(10.0)),
              text: material.isHidden ? 'Tampilkan' : 'Sembunyikan',
              isShrink: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTab(CourseDetailLoaded loaded) {
    final sessions = loaded.sessions;
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
        Gap.h16,
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
      margin: EdgeInsets.only(bottom: BaseSize.customHeight(12.0)),
      padding: EdgeInsets.symmetric(horizontal: BaseSize.customHeight(8.0), vertical: BaseSize.customWidth(8.0)),
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
                  maxLines: 2, // ← tambahan
                  overflow: TextOverflow.ellipsis, // ← tambahan
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Gap.h8,
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            maxLines: 1, // ← tambahan
            overflow: TextOverflow.ellipsis, // ← tambahan
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          Gap.h4,
          Text(
            'Deadline: ${_formatDateTime(assignment.deadline)}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.7),
            ),
          ),
          if ((assignment.description ?? '').isNotEmpty) ...[
            Gap.h8,
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
          Gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () {
                  ref
                      .read(elearningLecturerControllerProvider.notifier)
                      .toggleVisibility(
                        entityType: ElearningEntityType.assignment,
                        entityId: assignment.id,
                        isHidden: !assignment.isHidden,
                      );
                },
                icon: assignment.isHidden
                    ? Assets.icons.fill.eyeOff.svg(
                        width: BaseSize.customWidth(10.0),
                        height: BaseSize.customHeight(10.0),
                      )
                    : Assets.icons.fill.eyeOn.svg(
                        width: BaseSize.customWidth(10.0),
                        height: BaseSize.customHeight(10.0),
                      ),
                text: assignment.isHidden ? 'Tampilkan' : 'Sembunyikan',
                isShrink: true,
              ),
              Gap.w8,
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GradingScreen(
                        assignmentId: assignment.id,
                        assignmentTitle: assignment.title,
                      ),
                    ),
                  );
                },
                icon: Assets.icons.fill.star.svg(
                  height: BaseSize.customHeight(10.0),
                  width: BaseSize.customWidth(10.0),
                ),
                text: 'Nilai Tugas',
                isShrink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab(CourseDetailLoaded loaded) {
    final sessions = loaded.sessions;
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
        Gap.h16,
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
              Gap.w8,
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
          Gap.h8,
          Text(
            'Minggu ${session.weekNumber}: ${session.title}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6),
            ),
          ),
          Gap.h4,
          Text(
            '${quiz.questions.length} soal • ${_formatDateTime(quiz.startTime)} - ${_formatDateTime(quiz.endTime)}',
            style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.7),
            ),
          ),
          Gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () {
                  ref
                      .read(elearningLecturerControllerProvider.notifier)
                      .toggleVisibility(
                        entityType: ElearningEntityType.quiz,
                        entityId: quiz.id,
                        isHidden: !quiz.isHidden,
                      );
                },
                icon: quiz.isHidden
                    ? Assets.icons.fill.eyeOff.svg(width: BaseSize.customHeight(10.0), height: BaseSize.customHeight(10.0))
                    : Assets.icons.fill.eyeOn.svg(width: BaseSize.customHeight(10.0), height: BaseSize.customHeight(10.0)),
                text: quiz.isHidden ? 'Tampilkan' : 'Sembunyikan',
                isShrink: true,
              ),
              const SizedBox(width: 8),
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizAttemptsScreen(
                        quizId: quiz.id,
                        quizTitle: quiz.title,
                      ),
                    ),
                  );
                },
                icon: Assets.icons.fill.checkBadge.svg(),
                text: 'Lihat Nilai Quiz',
                isShrink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasClassStarted(CourseDetailLoaded loaded) {
    return loaded.sessions.isNotEmpty;
  }

  Widget _buildPreClassSetupCard(CourseDetailLoaded loaded) {
    final setupMode = loaded.setupConfig?.setupMode;
    final setupModeLabel = setupMode == ElearningSetupMode.existing
        ? 'EXISTING'
        : 'NEW';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan Awal E-Learning',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Gap.h6,
        Text(
          'Perkuliahan belum dimulai. Pilih membuat e-learning baru atau gunakan e-learning yang sudah ada sebelum kelas berjalan.',
          style: TextStyle(
            fontSize: 12,
            color: BaseColor.primaryText.withValues(alpha: 0.7),
          ),
        ),
        Gap.h8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: BaseColor.primaryInspire.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Mode saat ini: $setupModeLabel',
            style: const TextStyle(
              color: BaseColor.primaryInspire,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gap.h12,
        ElevatedButton.icon(
          onPressed: () => _showSetupDialog(loaded),
          icon: const Icon(Icons.settings),
          label: const Text('Atur E-Learning Kelas'),
        ),
      ],
    );
  }

  Widget _buildPreClassSetupBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEmpty(
          'Perkuliahan belum dimulai. Silakan lakukan pengaturan awal e-learning terlebih dahulu.',
        ),
      ],
    );
  }

  Future<void> _showSetupDialog(CourseDetailLoaded loaded) async {
    final sameCourseClasses = loaded.lecturerCourses
        .where(
          (course) => course.mataKuliahId == loaded.courseDetail.mataKuliahId,
        )
        .toList();
    final sourceCandidates = sameCourseClasses
        .where((course) => course.id != widget.kelasId)
        .toList();

    ElearningSetupMode setupMode =
        loaded.setupConfig?.setupMode ?? ElearningSetupMode.newClass;
    int? sourceKelasPerkuliahanId =
        loaded.setupConfig?.sourceKelasPerkuliahanId;
    bool cloneContentAsHidden = true;
    final Set<int> selectedMergedMembers = <int>{};

    await showDialogCustomWidget<void>(
      context: context,
      title: 'Pengaturan E-Learning Kelas',
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          final canChooseSource = setupMode == ElearningSetupMode.existing;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih mode e-learning sebelum perkuliahan berjalan: buat baru otomatis untuk kelas ini, atau gunakan konten dari kelas sebelumnya.',
                  style: TextStyle(fontSize: 12),
                ),
                Gap.h12,
                DropdownWidget<ElearningSetupMode>(
                  labelText: 'Mode Setup',
                  hintText: 'Pilih Mode Setup',
                  value: setupMode,
                  items: const [
                    ElearningSetupMode.newClass,
                    ElearningSetupMode.existing,
                  ],
                  itemLabelBuilder: (mode) =>
                      mode == ElearningSetupMode.newClass
                      ? 'NEW (Buat E-Learning Baru)'
                      : 'EXISTING (Gunakan Kelas Sebelumnya)',
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      setupMode = value;
                      if (setupMode == ElearningSetupMode.newClass) {
                        sourceKelasPerkuliahanId = null;
                      }
                    });
                  },
                ),
                if (canChooseSource) ...[
                  Gap.h12,
                  DropdownWidget<int>(
                    labelText: 'Kelas Sumber',
                    hintText: 'Pilih Kelas Sumber',
                    value: sourceKelasPerkuliahanId,
                    items: sourceCandidates.map((course) => course.id).toList(),
                    itemLabelBuilder: (id) {
                      final selected = sourceCandidates.firstWhere(
                        (c) => c.id == id,
                      );
                      final mkName = selected.mataKuliah?.name ?? selected.nama;
                      return '${selected.kode} - $mkName';
                    },
                    onChanged: (value) {
                      setDialogState(() {
                        sourceKelasPerkuliahanId = value;
                      });
                    },
                  ),
                  Gap.h8,
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: cloneContentAsHidden,
                    title: const Text('Konten hasil clone disembunyikan dulu'),
                    onChanged: (value) {
                      setDialogState(() {
                        cloneContentAsHidden = value ?? true;
                      });
                    },
                  ),
                ],
                const Divider(height: 24),
                const Text(
                  'Gabung E-Learning',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Gap.h6,
                const Text(
                  'Pilih kelas dengan mata kuliah yang sama untuk digabung ke kelas ini.',
                  style: TextStyle(fontSize: 12),
                ),
                Gap.h8,
                if (sourceCandidates.isEmpty)
                  const Text('Tidak ada kelas lain yang bisa digabungkan')
                else
                  ...sourceCandidates.map(
                    (course) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: selectedMergedMembers.contains(course.id),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked ?? false) {
                            selectedMergedMembers.add(course.id);
                          } else {
                            selectedMergedMembers.remove(course.id);
                          }
                        });
                      },
                      title: Text(
                        '${course.kode} - ${course.mataKuliah?.name ?? course.nama}',
                      ),
                    ),
                  ),
                Gap.h12,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Tutup'),
                    ),
                    if (loaded.setupConfig?.isMergedClass == true)
                      TextButton(
                        onPressed: () {
                          ref
                              .read(
                                elearningLecturerControllerProvider.notifier,
                              )
                              .unmergeClass(widget.kelasId);
                          context.pop();
                        },
                        child: const Text('Lepas Gabungan'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        if (setupMode == ElearningSetupMode.existing &&
                            sourceKelasPerkuliahanId == null) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Kelas sumber wajib dipilih untuk mode EXISTING',
                              ),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(elearningLecturerControllerProvider.notifier)
                            .setupClass(
                              kelasPerkuliahanId: widget.kelasId,
                              setupMode: setupMode,
                              sourceKelasPerkuliahanId:
                                  sourceKelasPerkuliahanId,
                              isMergedClass: false,
                              cloneContentAsHidden: cloneContentAsHidden,
                            );
                        context.pop();
                      },
                      child: const Text('Simpan Setup'),
                    ),
                    ElevatedButton(
                      onPressed: selectedMergedMembers.isEmpty
                          ? null
                          : () {
                              ref
                                  .read(
                                    elearningLecturerControllerProvider
                                        .notifier,
                                  )
                                  .mergeClasses(
                                    masterKelasPerkuliahanId: widget.kelasId,
                                    memberKelasPerkuliahanIds:
                                        selectedMergedMembers.toList(),
                                  );
                              context.pop();
                            },
                      child: const Text('Simpan Gabungan'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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

    await showDialogCustomWidget<void>(
      context: context,
      title: 'Tambah Materi',
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          final bool showContent =
              selectedType == MaterialType.text ||
              selectedType == MaterialType.hybrid;
          final bool showFile =
              selectedType == MaterialType.file ||
              selectedType == MaterialType.hybrid;

          return SingleChildScrollView(
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
                Gap.h12,
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Materi',
                    border: OutlineInputBorder(),
                  ),
                ),
                Gap.h12,
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
                  Gap.h12,
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
                  Gap.h12,
                  TextField(
                    controller: fileUrlController,
                    decoration: const InputDecoration(
                      labelText: 'File URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                Gap.h12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
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
                            const SnackBar(
                              content: Text('File URL wajib diisi'),
                            ),
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
                        context.pop();
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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

    await showDialogCustomWidget<void>(
      context: context,
      title: 'Tambah Tugas',
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return SingleChildScrollView(
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
                Gap.h12,
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    border: OutlineInputBorder(),
                  ),
                ),
                Gap.h12,
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                Gap.h12,
                OutlinedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
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
                Gap.h12,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
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
                            const SnackBar(
                              content: Text('Deadline wajib dipilih'),
                            ),
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
                        context.pop();
                      },
                      child: const Text('Buat'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
