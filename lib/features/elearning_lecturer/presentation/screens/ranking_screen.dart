import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';
import 'package:go_router/go_router.dart';

class RankingScreen extends ConsumerStatefulWidget {
  final int kelasId;
  final String courseName;

  const RankingScreen({
    super.key,
    required this.kelasId,
    required this.courseName,
  });

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(elearningLecturerControllerProvider.notifier)
          .loadRanking(widget.kelasId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(elearningLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
        title: 'Ranking – ${widget.courseName}',
      ),
      disableSingleChildScrollView: true,
      child: _buildBody(state),
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
                    .loadRanking(widget.kelasId),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (state is! RankingLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = state.data;

    return Column(
      children: [
        // Header card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BaseColor.primaryInspire.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: BaseColor.primaryInspire.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.kodeMK} – ${data.namaMK}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Gap.h4,
              Text(data.academicYear,
                  style: TextStyle(
                      fontSize: 12,
                      color: BaseColor.primaryText.withValues(alpha: 0.6))),
              Gap.h8,
              Row(
                children: [
                  _InfoChip(
                    label: 'Total Bobot',
                    value: '${data.totalBobot.toStringAsFixed(0)}%',
                    color: data.totalBobot == 100
                        ? Colors.green
                        : Colors.orange,
                  ),
                  Gap.w8,
                  _InfoChip(
                    label: 'Mahasiswa',
                    value: '${data.ranking.length}',
                    color: BaseColor.primaryInspire,
                  ),
                ],
              ),
              if (data.catatan != null) ...[
                Gap.h8,
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data.catatan!,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Ranking list
        Expanded(
          child: data.ranking.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data ranking.\nPastikan bobot tugas/kuis sudah diatur.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: data.ranking.length,
                  itemBuilder: (_, i) =>
                      _RankingCard(entry: data.ranking[i]),
                ),
        ),
      ],
    );
  }
}

// =============================================================================
// RANKING CARD
// =============================================================================

class _RankingCard extends StatelessWidget {
  final RankingEntry entry;

  const _RankingCard({required this.entry});

  Color get _rankColor {
    if (entry.rank == 1) return const Color(0xFFFFD700); // Gold
    if (entry.rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (entry.rank == 3) return const Color(0xFFCD7F32); // Bronze
    return BaseColor.primaryText.withValues(alpha: 0.4);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: entry.rank <= 3 ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: entry.rank == 1
            ? BorderSide(color: _rankColor, width: 1.5)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 12),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _rankColor.withValues(alpha: 0.15),
            border: Border.all(color: _rankColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _rankColor),
            ),
          ),
        ),
        title: Text(
          entry.nama,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          entry.nim,
          style: TextStyle(
              fontSize: 12,
              color: BaseColor.primaryText.withValues(alpha: 0.6)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.totalNilai.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _rankColor == const Color(0xFFFFD700)
                    ? Colors.amber.shade700
                    : BaseColor.primaryInspire,
              ),
            ),
            const Text('poin', style: TextStyle(fontSize: 10)),
          ],
        ),
        children: [
          const Divider(height: 1),
          Gap.h8,
          if (entry.detailTugas.isNotEmpty) ...[
            const Text('Detail Tugas',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Gap.h6,
            ...entry.detailTugas.map((d) => _DetailRow(
                  title: d.title,
                  kategori: d.kategori,
                  bobot: d.bobot,
                  label: d.nilai != null
                      ? 'Nilai: ${d.nilai!.toStringAsFixed(1)}'
                      : 'Belum dinilai',
                  kontribusi: d.kontribusi,
                )),
            Gap.h8,
          ],
          if (entry.detailKuis.isNotEmpty) ...[
            const Text('Detail Kuis',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Gap.h6,
            ...entry.detailKuis.map((d) => _DetailRow(
                  title: d.title,
                  kategori: d.kategori,
                  bobot: d.bobot,
                  label: d.scorePercentage != null
                      ? 'Skor: ${d.scorePercentage!.toStringAsFixed(1)}%'
                      : 'Belum ikut',
                  kontribusi: d.kontribusi,
                )),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String kategori;
  final double bobot;
  final String label;
  final double kontribusi;

  const _DetailRow({
    required this.title,
    required this.kategori,
    required this.bobot,
    required this.label,
    required this.kontribusi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '$kategori • Bobot ${bobot.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 10,
                      color: BaseColor.primaryText.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: BaseColor.primaryText.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '+${kontribusi.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    kontribusi > 0 ? Colors.green : BaseColor.primaryText,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHARED CHIPS
// =============================================================================

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
