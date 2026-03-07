import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart' hide MaterialType;
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// MAIN SCREEN
// =============================================================================

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
  int _selectedTabIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() => ref
      .read(elearningLecturerControllerProvider.notifier)
      .loadCourseDetail(widget.kelasId);

  String _fmtDt(DateTime v) {
    final d = v.day.toString().padLeft(2, '0');
    final mo = v.month.toString().padLeft(2, '0');
    final h = v.hour.toString().padLeft(2, '0');
    final mi = v.minute.toString().padLeft(2, '0');
    return '$d/$mo/${v.year} $h:$mi';
  }

  // --------------------------------------------------------------------------
  // Centralised state listener – keeps build() clean
  // --------------------------------------------------------------------------

  void _onStateChange(
    ElearningLecturerState? _,
    ElearningLecturerState next,
  ) {
    if (!mounted) return;

    void notify(String msg) =>
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSuccessAlertDialogWidget(context, title: msg);
        });

    void showError(String msg) =>
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg.replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        });

    if (next is MaterialCreated) {
      notify('Materi berhasil dibuat');
      _reload();
    } else if (next is AssignmentCreated) {
      notify('Tugas berhasil dibuat');
      _reload();
    } else if (next is QuizCreated) {
      notify('Kuis berhasil dibuat');
      _reload();
    } else if (next is SetupClassSaved) {
      notify(next.message);
      _reload();
    } else if (next is MergeClassesSaved) {
      notify(next.message);
      _reload();
    } else if (next is UnmergeClassSaved) {
      notify('Kelas berhasil dipisahkan dari gabungan');
      _reload();
    } else if (next is VisibilityUpdated) {
      notify('Visibilitas konten berhasil diperbarui');
      _reload();
    } else if (next is ElearningLecturerError) {
      showError(next.message);
    }
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ref.listen<ElearningLecturerState>(
      elearningLecturerControllerProvider,
      _onStateChange,
    );

    final state = ref.watch(elearningLecturerControllerProvider);
    final loaded = state is CourseDetailLoaded ? state : null;
    final hasStarted = loaded != null && loaded.sessions.isNotEmpty;

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
          if (loaded != null && !hasStarted)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _PreClassSetupCard(
                loaded: loaded,
                onTapSetup: () => _showSetupSheet(loaded),
              ),
            )
          else
            _TabBar(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (i) => setState(() => _selectedTabIndex = i),
            ),
          const Divider(height: 1),
          Expanded(child: _buildBody(state, loaded, hasStarted)),
        ],
      ),
    );
  }

  Widget _buildBody(
    ElearningLecturerState state,
    CourseDetailLoaded? loaded,
    bool hasStarted,
  ) {
    if (state is ElearningLecturerLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ElearningLecturerError) {
      return _ErrorBody(message: state.message, onRetry: _reload);
    }

    if (loaded == null || !hasStarted) {
      return const _PreClassSetupBody();
    }

    return switch (_selectedTabIndex) {
      0 => _MaterialTabBody(
          sessions: loaded.sessions,
          onAdd: () => _showMaterialSheet(loaded.sessions),
        ),
      1 => _AssignmentTabBody(
          sessions: loaded.sessions,
          onAdd: () => _showAssignmentSheet(loaded.sessions),
        ),
      2 => _QuizTabBody(
          sessions: loaded.sessions,
          kelasId: widget.kelasId,
          onReload: _reload,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  // --------------------------------------------------------------------------
  // Bottom sheets
  // --------------------------------------------------------------------------

  Future<void> _showMaterialSheet(List<SessionModel> sessions) =>
      showDialogCustomWidget<void>(
        context: context,
        title: 'Tambah Materi',
        content: _MaterialFormContent(sessions: sessions),
      );

  Future<void> _showAssignmentSheet(List<SessionModel> sessions) =>
      showDialogCustomWidget<void>(
        context: context,
        title: 'Tambah Tugas',
        content: _AssignmentFormContent(
          sessions: sessions,
          formatDateTime: _fmtDt,
        ),
      );

  Future<void> _showSetupSheet(CourseDetailLoaded loaded) async {
    final sourceCandidates = loaded.lecturerCourses
        .where(
          (c) =>
              c.mataKuliahId == loaded.courseDetail.mataKuliahId &&
              c.id != widget.kelasId,
        )
        .toList();

    await showDialogCustomWidget<void>(
      context: context,
      title: 'Pengaturan E-Learning Kelas',
      content: _SetupSheetContent(
        loaded: loaded,
        sourceCandidates: sourceCandidates,
        kelasId: widget.kelasId,
      ),
    );
  }
}

// =============================================================================
// TAB BAR
// =============================================================================

class _TabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _TabBar({required this.selectedIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabItem(label: 'Materi', index: 0, selectedIndex: selectedIndex, onTap: onTabChanged),
            _TabItem(label: 'Tugas', index: 1, selectedIndex: selectedIndex, onTap: onTabChanged),
            _TabItem(label: 'Kuis', index: 2, selectedIndex: selectedIndex, onTap: onTabChanged),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
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
}

// =============================================================================
// TAB BODY WIDGETS
// =============================================================================

class _MaterialTabBody extends ConsumerWidget {
  final List<SessionModel> sessions;
  final VoidCallback onAdd;

  const _MaterialTabBody({required this.sessions, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      for (final s in sessions)
        for (final m in s.materials) (session: s, material: m),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: sessions.isEmpty ? null : onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Materi'),
        ),
        Gap.h16,
        if (sessions.isEmpty)
          const _EmptyState('Belum ada sesi pembelajaran di kelas ini')
        else if (items.isEmpty)
          const _EmptyState('Belum ada materi pada semua sesi')
        else
          for (final item in items)
            _MaterialCard(session: item.session, material: item.material),
      ],
    );
  }
}

class _AssignmentTabBody extends ConsumerWidget {
  final List<SessionModel> sessions;
  final VoidCallback onAdd;

  const _AssignmentTabBody({required this.sessions, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      for (final s in sessions)
        for (final a in s.assignments) (session: s, assignment: a),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: sessions.isEmpty ? null : onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Tambah Tugas'),
        ),
        Gap.h16,
        if (sessions.isEmpty)
          const _EmptyState('Belum ada sesi pembelajaran di kelas ini')
        else if (items.isEmpty)
          const _EmptyState('Belum ada tugas pada semua sesi')
        else
          for (final item in items)
            _AssignmentCard(session: item.session, assignment: item.assignment),
      ],
    );
  }
}

class _QuizTabBody extends ConsumerWidget {
  final List<SessionModel> sessions;
  final int kelasId;
  final VoidCallback onReload;

  const _QuizTabBody({
    required this.sessions,
    required this.kelasId,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      for (final s in sessions)
        for (final q in s.quizzes) (session: s, quiz: q),
    ];

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
                        kelasId: kelasId,
                      ),
                    ),
                  );
                  onReload();
                },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kuis'),
        ),
        Gap.h16,
        if (sessions.isEmpty)
          const _EmptyState('Belum ada sesi pembelajaran di kelas ini')
        else if (items.isEmpty)
          const _EmptyState('Belum ada kuis pada semua sesi')
        else
          for (final item in items)
            _QuizCard(session: item.session, quiz: item.quiz),
      ],
    );
  }
}

// =============================================================================
// CARD WIDGETS  (one per content type)
// =============================================================================

class _MaterialCard extends ConsumerWidget {
  final SessionModel session;
  final MaterialModel material;

  const _MaterialCard({required this.session, required this.material});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ContentCard(
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
              _TypeBadge(label: material.type.name.toUpperCase(), color: Colors.blue),
            ],
          ),
          Gap.h8,
          _SessionLabel(session: session),
          if ((material.content ?? '').isNotEmpty) ...[
            Gap.h8,
            Text(
              material.content!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.8)),
            ),
          ],
          Gap.h8,
          Align(
            alignment: Alignment.centerRight,
            child: _VisibilityButton(
              isHidden: material.isHidden,
              onTap: () => ref
                  .read(elearningLecturerControllerProvider.notifier)
                  .toggleVisibility(
                    entityType: ElearningEntityType.material,
                    entityId: material.id,
                    isHidden: !material.isHidden,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final SessionModel session;
  final AssignmentModel assignment;

  const _AssignmentCard({required this.session, required this.assignment});

  String _fmt(DateTime v) {
    final d = v.day.toString().padLeft(2, '0');
    final mo = v.month.toString().padLeft(2, '0');
    final h = v.hour.toString().padLeft(2, '0');
    final mi = v.minute.toString().padLeft(2, '0');
    return '$d/$mo/${v.year} $h:$mi';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ContentCard(
      margin: EdgeInsets.only(bottom: BaseSize.customHeight(12.0)),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customHeight(8.0),
        vertical: BaseSize.customWidth(8.0),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          Gap.h8,
          _SessionLabel(session: session),
          Gap.h4,
          Text(
            'Deadline: ${_fmt(assignment.deadline)}',
            style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.7)),
          ),
          if ((assignment.description ?? '').isNotEmpty) ...[
            Gap.h8,
            Text(
              assignment.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.8)),
            ),
          ],
          Gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _VisibilityButton(
                isHidden: assignment.isHidden,
                onTap: () => ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .toggleVisibility(
                      entityType: ElearningEntityType.assignment,
                      entityId: assignment.id,
                      isHidden: !assignment.isHidden,
                    ),
              ),
              Gap.w8,
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GradingScreen(
                      assignmentId: assignment.id,
                      assignmentTitle: assignment.title,
                    ),
                  ),
                ),
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
}

class _QuizCard extends ConsumerWidget {
  final SessionModel session;
  final QuizModel quiz;

  const _QuizCard({required this.session, required this.quiz});

  String _fmt(DateTime v) {
    final d = v.day.toString().padLeft(2, '0');
    final mo = v.month.toString().padLeft(2, '0');
    final h = v.hour.toString().padLeft(2, '0');
    final mi = v.minute.toString().padLeft(2, '0');
    return '$d/$mo/${v.year} $h:$mi';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ContentCard(
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              _TypeBadge(label: '${quiz.duration} menit', color: Colors.orange),
            ],
          ),
          Gap.h8,
          _SessionLabel(session: session),
          Gap.h4,
          Text(
            '${quiz.questions.length} soal  •  ${_fmt(quiz.startTime)} – ${_fmt(quiz.endTime)}',
            style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.7)),
          ),
          Gap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _VisibilityButton(
                isHidden: quiz.isHidden,
                onTap: () => ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .toggleVisibility(
                      entityType: ElearningEntityType.quiz,
                      entityId: quiz.id,
                      isHidden: !quiz.isHidden,
                    ),
              ),
              Gap.w8,
              ButtonWidget.outlined(
                buttonSize: ButtonSize.small,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizAttemptsScreen(
                      quizId: quiz.id,
                      quizTitle: quiz.title,
                    ),
                  ),
                ),
                icon: Assets.icons.fill.checkBadge.svg(width: BaseSize.customWidth(10.0), height: BaseSize.customHeight(10.0)),
                text: 'Lihat Nilai',
                isShrink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED SMALL WIDGETS
// =============================================================================

/// White rounded card with a subtle shadow – shared by all content cards.
class _ContentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _ContentCard({required this.child, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

/// Small coloured pill badge (e.g. "TEXT", "30 menit").
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// "Minggu X: title" subtitle used in every content card.
class _SessionLabel extends StatelessWidget {
  final SessionModel session;

  const _SessionLabel({required this.session});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Minggu ${session.weekNumber}: ${session.title}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.6)),
    );
  }
}

/// Show / Hide toggle button shared by all content types.
class _VisibilityButton extends StatelessWidget {
  final bool isHidden;
  final VoidCallback onTap;

  const _VisibilityButton({required this.isHidden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ButtonWidget.outlined(
      buttonSize: ButtonSize.small,
      onTap: onTap,
      icon: isHidden
          ? Assets.icons.fill.eyeOff
              .svg(width: BaseSize.customWidth(10.0), height: BaseSize.customHeight(10.0))
          : Assets.icons.fill.eyeOn
              .svg(width: BaseSize.customWidth(10.0), height: BaseSize.customHeight(10.0)),
      text: isHidden ? 'Tampilkan' : 'Sembunyikan',
      isShrink: true,
    );
  }
}

/// Empty / placeholder state widget.
class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
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
}

/// Full-page error with retry button.
class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 54),
            Gap.h12,
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            Gap.h12,
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PRE-CLASS SETUP
// =============================================================================

class _PreClassSetupCard extends StatelessWidget {
  final CourseDetailLoaded loaded;
  final VoidCallback onTapSetup;

  const _PreClassSetupCard({required this.loaded, required this.onTapSetup});

  @override
  Widget build(BuildContext context) {
    final mode = loaded.setupConfig?.setupMode;
    final modeLabel = mode == ElearningSetupMode.existing ? 'EXISTING' : 'NEW';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan Awal E-Learning',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Gap.h6,
        Text(
          'Perkuliahan belum dimulai. Pilih membuat e-learning baru atau gunakan '
          'e-learning yang sudah ada sebelum kelas berjalan.',
          style: TextStyle(fontSize: 12, color: BaseColor.primaryText.withValues(alpha: 0.7)),
        ),
        Gap.h8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: BaseColor.primaryInspire.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Mode saat ini: $modeLabel',
            style: const TextStyle(color: BaseColor.primaryInspire, fontWeight: FontWeight.w600),
          ),
        ),
        Gap.h12,
        ElevatedButton.icon(
          onPressed: onTapSetup,
          icon: const Icon(Icons.settings),
          label: const Text('Atur E-Learning Kelas'),
        ),
      ],
    );
  }
}

class _PreClassSetupBody extends StatelessWidget {
  const _PreClassSetupBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        _EmptyState(
          'Perkuliahan belum dimulai. Silakan lakukan pengaturan awal e-learning terlebih dahulu.',
        ),
      ],
    );
  }
}

// =============================================================================
// SETUP SHEET CONTENT  (ConsumerStatefulWidget to manage local dialog state)
// =============================================================================

class _SetupSheetContent extends ConsumerStatefulWidget {
  final CourseDetailLoaded loaded;
  final List<CourseListModel> sourceCandidates;
  final int kelasId;

  const _SetupSheetContent({
    required this.loaded,
    required this.sourceCandidates,
    required this.kelasId,
  });

  @override
  ConsumerState<_SetupSheetContent> createState() => _SetupSheetContentState();
}

class _SetupSheetContentState extends ConsumerState<_SetupSheetContent> {
  late ElearningSetupMode _setupMode;
  int? _sourceKelasId;
  bool _cloneHidden = true;
  final Set<int> _mergedMembers = {};

  @override
  void initState() {
    super.initState();
    _setupMode =
        widget.loaded.setupConfig?.setupMode ?? ElearningSetupMode.newClass;
    _sourceKelasId = widget.loaded.setupConfig?.sourceKelasPerkuliahanId;
  }

  void _saveSetup() {
    if (_setupMode == ElearningSetupMode.existing && _sourceKelasId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kelas sumber wajib dipilih untuk mode EXISTING')),
      );
      return;
    }
    ref.read(elearningLecturerControllerProvider.notifier).setupClass(
          kelasPerkuliahanId: widget.kelasId,
          setupMode: _setupMode,
          sourceKelasPerkuliahanId: _sourceKelasId,
          isMergedClass: false,
          cloneContentAsHidden: _cloneHidden,
        );
    context.pop();
  }

  void _saveMerge() {
    ref.read(elearningLecturerControllerProvider.notifier).mergeClasses(
          masterKelasPerkuliahanId: widget.kelasId,
          memberKelasPerkuliahanIds: _mergedMembers.toList(),
        );
    context.pop();
  }

  void _unmerge() {
    ref.read(elearningLecturerControllerProvider.notifier).unmergeClass(widget.kelasId);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final canChooseSource = _setupMode == ElearningSetupMode.existing;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih mode e-learning sebelum perkuliahan berjalan: buat baru otomatis '
            'untuk kelas ini, atau gunakan konten dari kelas sebelumnya.',
            style: TextStyle(fontSize: 12),
          ),
          Gap.h12,
          // Mode selector
          DropdownWidget<ElearningSetupMode>(
            labelText: 'Mode Setup',
            hintText: 'Pilih Mode Setup',
            value: _setupMode,
            items: const [ElearningSetupMode.newClass, ElearningSetupMode.existing],
            itemLabelBuilder: (m) => m == ElearningSetupMode.newClass
                ? 'NEW (Buat E-Learning Baru)'
                : 'EXISTING (Gunakan Kelas Sebelumnya)',
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _setupMode = v;
                if (_setupMode == ElearningSetupMode.newClass) _sourceKelasId = null;
              });
            },
          ),
          // Source class picker – only for EXISTING mode
          if (canChooseSource) ...[
            Gap.h12,
            DropdownWidget<int>(
              labelText: 'Kelas Sumber',
              hintText: 'Pilih Kelas Sumber',
              value: _sourceKelasId,
              items: widget.sourceCandidates.map((c) => c.id).toList(),
              itemLabelBuilder: (id) {
                final c = widget.sourceCandidates.firstWhere((x) => x.id == id);
                return '${c.kode} - ${c.mataKuliah?.name ?? c.nama}';
              },
              onChanged: (v) => setState(() => _sourceKelasId = v),
            ),
            Gap.h8,
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _cloneHidden,
              title: const Text('Konten hasil clone disembunyikan dulu'),
              onChanged: (v) => setState(() => _cloneHidden = v ?? true),
            ),
          ],
          const Divider(height: 24),
          // Merge section
          const Text('Gabung E-Learning', style: TextStyle(fontWeight: FontWeight.bold)),
          Gap.h6,
          const Text(
            'Pilih kelas dengan mata kuliah yang sama untuk digabung ke kelas ini.',
            style: TextStyle(fontSize: 12),
          ),
          Gap.h8,
          if (widget.sourceCandidates.isEmpty)
            const Text('Tidak ada kelas lain yang bisa digabungkan')
          else
            for (final course in widget.sourceCandidates)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _mergedMembers.contains(course.id),
                onChanged: (checked) => setState(() {
                  if (checked ?? false) {
                    _mergedMembers.add(course.id);
                  } else {
                    _mergedMembers.remove(course.id);
                  }
                }),
                title: Text(
                  '${course.kode} - ${course.mataKuliah?.name ?? course.nama}',
                ),
              ),
          Gap.h12,
          // Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              TextButton(onPressed: () => context.pop(), child: const Text('Tutup')),
              if (widget.loaded.setupConfig?.isMergedClass == true)
                TextButton(onPressed: _unmerge, child: const Text('Lepas Gabungan')),
              ElevatedButton(onPressed: _saveSetup, child: const Text('Simpan Setup')),
              ElevatedButton(
                onPressed: _mergedMembers.isEmpty ? null : _saveMerge,
                child: const Text('Simpan Gabungan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MATERIAL FORM SHEET
// =============================================================================

class _MaterialFormContent extends ConsumerStatefulWidget {
  final List<SessionModel> sessions;

  const _MaterialFormContent({required this.sessions});

  @override
  ConsumerState<_MaterialFormContent> createState() =>
      _MaterialFormContentState();
}

class _MaterialFormContentState extends ConsumerState<_MaterialFormContent> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _fileUrlCtrl;
  late String _sessionId;
  MaterialType _type = MaterialType.text;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _contentCtrl = TextEditingController();
    _fileUrlCtrl = TextEditingController();
    _sessionId = widget.sessions.first.id;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _fileUrlCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    final fileUrl = _fileUrlCtrl.text.trim();

    if (title.isEmpty) { _snack('Judul materi wajib diisi'); return; }
    if ((_type == MaterialType.text || _type == MaterialType.hybrid) && content.isEmpty) {
      _snack('Konten materi wajib diisi');
      return;
    }
    if ((_type == MaterialType.file || _type == MaterialType.hybrid) && fileUrl.isEmpty) {
      _snack('File URL wajib diisi');
      return;
    }

    // Dismiss sheet before triggering async work so controllers remain alive
    context.pop();
    ref.read(elearningLecturerControllerProvider.notifier).createMaterial(
          title: title,
          type: _type.name.toUpperCase(),
          content: content.isEmpty ? null : content,
          fileUrl: fileUrl.isEmpty ? null : fileUrl,
          sessionId: _sessionId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final showContent = _type == MaterialType.text || _type == MaterialType.hybrid;
    final showFile = _type == MaterialType.file || _type == MaterialType.hybrid;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SessionDropdown(
            sessions: widget.sessions,
            value: _sessionId,
            onChanged: (v) => setState(() => _sessionId = v),
          ),
          Gap.h12,
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Judul Materi',
              border: OutlineInputBorder(),
            ),
          ),
          Gap.h12,
          DropdownWidget<MaterialType>(
            labelText: 'Tipe Materi',
            hintText: 'Pilih Tipe',
            value: _type,
            items: const [MaterialType.text, MaterialType.file, MaterialType.hybrid],
            itemLabelBuilder: (t) => t.name.toUpperCase(),
            onChanged: (v) { if (v != null) setState(() => _type = v); },
          ),
          if (showContent) ...[
            Gap.h12,
            TextField(
              controller: _contentCtrl,
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
              controller: _fileUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'File URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          Gap.h12,
          _FormActions(onCancel: () => context.pop(), onSubmit: _submit, submitLabel: 'Simpan'),
        ],
      ),
    );
  }
}

// =============================================================================
// ASSIGNMENT FORM SHEET
// =============================================================================

class _AssignmentFormContent extends ConsumerStatefulWidget {
  final List<SessionModel> sessions;
  final String Function(DateTime) formatDateTime;

  const _AssignmentFormContent({
    required this.sessions,
    required this.formatDateTime,
  });

  @override
  ConsumerState<_AssignmentFormContent> createState() =>
      _AssignmentFormContentState();
}

class _AssignmentFormContentState extends ConsumerState<_AssignmentFormContent> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _sessionId;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _sessionId = widget.sessions.first.id;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null || !mounted) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _submit() {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) { _snack('Judul tugas wajib diisi'); return; }
    if (desc.isEmpty) { _snack('Deskripsi tugas wajib diisi'); return; }
    if (_deadline == null) { _snack('Deadline wajib dipilih'); return; }

    context.pop();
    ref.read(elearningLecturerControllerProvider.notifier).createAssignment(
          title: title,
          description: desc,
          deadline: _deadline!,
          sessionId: _sessionId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SessionDropdown(
            sessions: widget.sessions,
            value: _sessionId,
            onChanged: (v) => setState(() => _sessionId = v),
          ),
          Gap.h12,
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Judul Tugas',
              border: OutlineInputBorder(),
            ),
          ),
          Gap.h12,
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
          ),
          Gap.h12,
          OutlinedButton.icon(
            onPressed: _pickDeadline,
            icon: const Icon(Icons.schedule),
            label: Text(
              _deadline == null ? 'Pilih Deadline' : widget.formatDateTime(_deadline!),
            ),
          ),
          Gap.h12,
          _FormActions(onCancel: () => context.pop(), onSubmit: _submit, submitLabel: 'Buat'),
        ],
      ),
    );
  }
}

// =============================================================================
// REUSABLE FORM HELPERS
// =============================================================================

/// Session dropdown shared by both form sheets.
class _SessionDropdown extends StatelessWidget {
  final List<SessionModel> sessions;
  final String value;
  final ValueChanged<String> onChanged;

  const _SessionDropdown({
    required this.sessions,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownWidget<String>(
      labelText: 'Sesi',
      hintText: 'Pilih Sesi',
      value: value,
      items: sessions.map((s) => s.id).toList(),
      itemLabelBuilder: (id) {
        final s = sessions.firstWhere((x) => x.id == id);
        return 'Minggu ${s.weekNumber}: ${s.title}';
      },
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}

/// Cancel / submit button row used at the bottom of every form sheet.
class _FormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitLabel;

  const _FormActions({
    required this.onCancel,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Batal')),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: onSubmit, child: Text(submitLabel)),
      ],
    );
  }
}
