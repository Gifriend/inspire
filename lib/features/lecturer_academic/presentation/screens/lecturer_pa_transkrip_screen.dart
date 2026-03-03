import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/lecturer_academic/presentation/controllers/lecturer_academic_controller.dart';
import 'package:inspire/features/lecturer_academic/presentation/states/lecturer_academic_state.dart';
import 'package:path_provider/path_provider.dart';

/// Screen untuk melihat Transkrip Nilai mahasiswa bimbingan PA.
class LecturerPaTranskripScreen extends ConsumerStatefulWidget {
  final int mahasiswaId;
  final String namaMahasiswa;

  const LecturerPaTranskripScreen({
    super.key,
    required this.mahasiswaId,
    required this.namaMahasiswa,
  });

  @override
  ConsumerState<LecturerPaTranskripScreen> createState() =>
      _LecturerPaTranskripScreenState();
}

class _LecturerPaTranskripScreenState
    extends ConsumerState<LecturerPaTranskripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paTranskripControllerProvider(widget.mahasiswaId).notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(paTranskripControllerProvider(widget.mahasiswaId));

    return Scaffold(
      backgroundColor: BaseColor.neutral[10],
      appBar: AppBarWidget(
        title: 'Transkrip – ${widget.namaMahasiswa}',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(PaTranskripState state) {
    if (state is PaTranskripInitial || state is PaTranskripLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PaTranskripError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            Gap.h12,
            Text('Gagal memuat transkrip',
                style: BaseTypography.bodyLarge),
            Gap.h8,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
              child: Text(state.message,
                  style: BaseTypography.bodySmall
                      .copyWith(color: Colors.grey.shade500),
                  textAlign: TextAlign.center),
            ),
            Gap.h16,
            ElevatedButton(
              onPressed: () => ref
                  .read(paTranskripControllerProvider(widget.mahasiswaId)
                      .notifier)
                  .load(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primaryInspire),
              child: const Text('Coba Lagi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (state is PaTranskripLoaded) {
      return _buildContent(state.data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(TranscriptModel data) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16, vertical: BaseSize.customWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMahasiswaInfo(data.mahasiswa),
          Gap.h12,
          _buildStatistikCard(data.statistik),
          Gap.h16,
          // Semester sections
          ...data.bySemester
              .map((sem) => _buildSemesterSection(sem))
              .toList(),
          Gap.h16,
          _buildDownloadButton(data.mahasiswa.nim),
          Gap.h32,
        ],
      ),
    );
  }

  Widget _buildMahasiswaInfo(TranskripMahasiswaModel mhs) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Mahasiswa',
              style: BaseTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.w700)),
          Gap.h8,
          _InfoPair('Nama', mhs.nama),
          _InfoPair('NIM', mhs.nim),
          _InfoPair('Program Studi', mhs.prodi),
          _InfoPair('Jenjang', mhs.jenjang),
          _InfoPair('Fakultas', mhs.fakultas),
          if (mhs.tanggalLahir != null)
            _InfoPair('Tanggal Lahir', mhs.tanggalLahir!),
          _InfoPair('Tanggal Cetak', mhs.tanggalCetak),
        ],
      ),
    );
  }

  Widget _buildStatistikCard(TranskripStatistikModel stat) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BaseColor.primaryInspire,
            BaseColor.primaryInspire.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ColoredStat(label: 'Total SKS', value: '${stat.totalSKS}'),
          _ColoredStat(label: 'Total MK', value: '${stat.totalMataKuliah}'),
          _ColoredStat(label: 'IPK', value: stat.ipk),
          _ColoredStat(label: 'Predikat', value: stat.predikat),
        ],
      ),
    );
  }

  Widget _buildSemesterSection(TranskripSemesterModel sem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Semester header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.customWidth(10)),
            decoration: BoxDecoration(
              color: BaseColor.primaryInspire.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                topRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sem.label}  •  ${sem.academicYear}',
                  style: BaseTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${sem.subTotal.sks} SKS',
                  style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.primaryInspire,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Table header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.customWidth(6)),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Expanded(
                    child: Text('Mata Kuliah',
                        style: BaseTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700))),
                SizedBox(
                    width: 40,
                    child: Text('SKS',
                        textAlign: TextAlign.center,
                        style: BaseTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w700))),
                SizedBox(
                    width: 44,
                    child: Text('Nilai',
                        textAlign: TextAlign.center,
                        style: BaseTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w700))),
                SizedBox(
                    width: 44,
                    child: Text('Indeks',
                        textAlign: TextAlign.center,
                        style: BaseTypography.labelSmall
                            .copyWith(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          const Divider(height: 1),

          // MK rows
          ...sem.matakuliah.asMap().entries.map((e) {
            final mk = e.value;
            final isOdd = e.key % 2 == 1;
            return Container(
              color: isOdd ? Colors.grey.shade50 : Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w16,
                  vertical: BaseSize.customWidth(8)),
              child: Row(
                children: [
                  SizedBox(
                      width: 30,
                      child: Text('${mk.no}',
                          style: BaseTypography.labelSmall.toGrey)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mk.nama,
                            style: BaseTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text(mk.kode,
                            style: BaseTypography.labelSmall.toGrey),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: 40,
                      child: Text('${mk.sks}',
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodySmall)),
                  SizedBox(
                      width: 44,
                      child: Text(mk.nilaiHuruf,
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _gradeColor(mk.nilaiHuruf)))),
                  SizedBox(
                      width: 44,
                      child: Text(mk.indeks.toStringAsFixed(2),
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodySmall)),
                ],
              ),
            );
          }),

          // Sub-total
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.customWidth(8)),
            decoration: BoxDecoration(
              color: BaseColor.primaryInspire.withValues(alpha: 0.06),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(BaseSize.radiusMd),
                bottomRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Expanded(
                    child: Text('Sub Total',
                        style: BaseTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.w700))),
                SizedBox(
                    width: 40,
                    child: Text('${sem.subTotal.sks}',
                        textAlign: TextAlign.center,
                        style: BaseTypography.bodySmall
                            .copyWith(fontWeight: FontWeight.w700))),
                const SizedBox(width: 88),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String nim) {
    return SizedBox(
      width: double.infinity,
      child: _DownloadTranskripButton(
          mahasiswaId: widget.mahasiswaId, nim: nim),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green.shade700;
      case 'B+':
      case 'B':
        return Colors.blue.shade700;
      case 'C+':
      case 'C':
        return Colors.orange.shade700;
      case 'D':
      case 'E':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }
}

// ─── Download Transkrip Button ────────────────────────────────────────────────

class _DownloadTranskripButton extends ConsumerStatefulWidget {
  final int mahasiswaId;
  final String nim;

  const _DownloadTranskripButton(
      {required this.mahasiswaId, required this.nim});

  @override
  ConsumerState<_DownloadTranskripButton> createState() =>
      _DownloadTranskripButtonState();
}

class _DownloadTranskripButtonState
    extends ConsumerState<_DownloadTranskripButton> {
  bool _loading = false;

  Future<void> _download() async {
    final hasPermission =
        await PermissionUtil.requestStorageForDownload();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin penyimpanan diperlukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final bytes = await ref
          .read(paTranskripControllerProvider(widget.mahasiswaId).notifier)
          .downloadPdf();

      final filename =
          'Transkrip_${widget.nim}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (Platform.isAndroid) {
        final channel = const MethodChannel(
            'com.gifriend.inspire/file_saver');
        final base64Str = base64Encode(bytes);
        final res = await channel.invokeMethod<String>(
          'saveFileToDownloads',
          {'base64': base64Str, 'filename': filename},
        );
        if (mounted && res != null && res.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transkrip disimpan: $res'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transkrip disimpan: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _download,
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.download, size: 18),
      label:
          Text(_loading ? 'Mengunduh...' : 'Unduh Transkrip PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: BaseColor.primaryInspire,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _InfoPair extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPair(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: BaseTypography.bodySmall
                    .copyWith(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(': $value',
                style: BaseTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _ColoredStat extends StatelessWidget {
  final String label;
  final String value;
  const _ColoredStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: BaseTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label,
            style: BaseTypography.labelSmall.copyWith(
                color: Colors.white70),
            textAlign: TextAlign.center),
      ],
    );
  }
}
