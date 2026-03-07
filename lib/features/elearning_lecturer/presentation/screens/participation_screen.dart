import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:go_router/go_router.dart';

class ParticipationScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String courseName;

  const ParticipationScreen({
    super.key,
    required this.kelasId,
    required this.courseName,
  });

  @override
  ConsumerState<ParticipationScreen> createState() =>
      _ParticipationScreenState();
}

class _ParticipationScreenState extends ConsumerState<ParticipationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadParticipation(widget.kelasId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(elearningLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        title: 'Partisipasi – ${widget.courseName}',
      ),
      disableSingleChildScrollView: true,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: BaseColor.primaryInspire,
              unselectedLabelColor:
                  BaseColor.primaryText.withValues(alpha: 0.5),
              indicatorColor: BaseColor.primaryInspire,
              tabs: const [
                Tab(text: 'Tugas'),
                Tab(text: 'Kuis'),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ElearningLecturerState state) {
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
              Text(state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              Gap.h12,
              ElevatedButton(
                onPressed: () => ref
                    .read(elearningLecturerControllerProvider.notifier)
                    .loadParticipation(widget.kelasId),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (state is! ParticipationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = state.data;

    return TabBarView(
      controller: _tabController,
      children: [
        _AssignmentParticipationTab(items: data.tugas),
        _QuizParticipationTab(items: data.kuis),
      ],
    );
  }
}

// =============================================================================
// ASSIGNMENT PARTICIPATION TAB
// =============================================================================

class _AssignmentParticipationTab extends StatelessWidget {
  final List<AssignmentParticipation> items;

  const _AssignmentParticipationTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada tugas di kelas ini.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => Gap.h12,
      itemBuilder: (_, i) => _AssignmentParticipationCard(item: items[i]),
    );
  }
}

class _AssignmentParticipationCard extends StatelessWidget {
  final AssignmentParticipation item;

  const _AssignmentParticipationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rate = item.totalMahasiswaTerdaftar == 0
        ? 0.0
        : item.totalSubmitted / item.totalMahasiswaTerdaftar;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        leading: const Icon(Icons.assignment, color: Colors.green),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertemuan ${item.pertemuan}  •  ${item.kategori}  •  Bobot ${item.bobot.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11,
                  color: BaseColor.primaryText.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.totalSubmitted}/${item.totalMahasiswaTerdaftar}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Gap.h8,
          _TableHeader(labels: const ['Nama', 'NIM', 'Status', 'Nilai']),
          ...item.partisipasi.map((p) => _AssignmentRow(entry: p)),
        ],
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final ParticipationEntry entry;

  const _AssignmentRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(entry.nama, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: Text(entry.nim, style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (entry.submitted == true ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.submitted == true ? 'Kumpul' : 'Belum',
                style: TextStyle(
                  fontSize: 11,
                  color: entry.submitted == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.nilai != null ? entry.nilai!.toStringAsFixed(1) : '-',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QUIZ PARTICIPATION TAB
// =============================================================================

class _QuizParticipationTab extends StatelessWidget {
  final List<QuizParticipation> items;

  const _QuizParticipationTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada kuis di kelas ini.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => Gap.h12,
      itemBuilder: (_, i) => _QuizParticipationCard(item: items[i]),
    );
  }
}

class _QuizParticipationCard extends StatelessWidget {
  final QuizParticipation item;

  const _QuizParticipationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rate = item.totalMahasiswaTerdaftar == 0
        ? 0.0
        : item.totalAttempted / item.totalMahasiswaTerdaftar;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        leading: const Icon(Icons.quiz, color: Colors.orange),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pertemuan ${item.pertemuan}  •  ${item.kategori}  •  Bobot ${item.bobot.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 11,
                  color: BaseColor.primaryText.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.orange,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.totalAttempted}/${item.totalMahasiswaTerdaftar}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          Gap.h8,
          _TableHeader(labels: const ['Nama', 'NIM', 'Status', 'Skor (%)']),
          ...item.partisipasi.map((p) => _QuizRow(entry: p)),
        ],
      ),
    );
  }
}

class _QuizRow extends StatelessWidget {
  final ParticipationEntry entry;

  const _QuizRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(entry.nama, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: Text(entry.nim, style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (entry.attempted == true ? Colors.orange : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.attempted == true ? 'Ikut' : 'Absen',
                style: TextStyle(
                  fontSize: 11,
                  color: entry.attempted == true ? Colors.orange : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.scorePercentage != null
                  ? '${entry.scorePercentage!.toStringAsFixed(1)}%'
                  : '-',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED HELPERS
// =============================================================================

class _TableHeader extends StatelessWidget {
  final List<String> labels;

  const _TableHeader({required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: labels.asMap().entries.map((e) {
          final flex = e.key == 0 ? 3 : 2;
          return Expanded(
            flex: flex,
            child: Text(
              e.value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          );
        }).toList(),
      ),
    );
  }
}
