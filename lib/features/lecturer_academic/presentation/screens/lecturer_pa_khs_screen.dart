import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/lecturer_academic/presentation/controllers/lecturer_academic_controller.dart';
import 'package:inspire/features/lecturer_academic/presentation/states/lecturer_academic_state.dart';
import 'package:path_provider/path_provider.dart';

/// Screen untuk melihat KHS mahasiswa bimbingan.
/// Menampilkan daftar semester, lalu detail nilai per semester.
class LecturerPaKhsScreen extends ConsumerStatefulWidget {
  final int mahasiswaId;
  final String namaMahasiswa;

  const LecturerPaKhsScreen({
    super.key,
    required this.mahasiswaId,
    required this.namaMahasiswa,
  });

  @override
  ConsumerState<LecturerPaKhsScreen> createState() =>
      _LecturerPaKhsScreenState();
}

class _LecturerPaKhsScreenState extends ConsumerState<LecturerPaKhsScreen> {
  String? _selectedSemester;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paSemesterListControllerProvider(widget.mahasiswaId).notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final semState =
        ref.watch(paSemesterListControllerProvider(widget.mahasiswaId));

    return Scaffold(
      backgroundColor: BaseColor.neutral[10],
      appBar: AppBarWidget(
        title: 'KHS – ${widget.namaMahasiswa}',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Semester picker
            _buildSemesterPicker(semState),
            // KHS content
            Expanded(child: _buildKhsArea()),
          ],
        ),
      ),
    );
  }

  // ─── Semester picker ────────────────────────────────────────────────────

  Widget _buildSemesterPicker(PaSemesterListState state) {
    List<String> semesters = [];
    if (state is PaSemesterListLoaded) semesters = state.semesters;

    return Container(
      margin: EdgeInsets.all(BaseSize.w16),
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
          Text('Pilih Semester',
              style: BaseTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          Gap.h8,
          if (state is PaSemesterListLoading ||
              state is PaSemesterListInitial)
            const LinearProgressIndicator()
          else if (state is PaSemesterListError)
            Text('Gagal memuat semester',
                style: BaseTypography.bodySmall
                    .copyWith(color: Colors.red))
          else
            DropdownButtonFormField<String>(
              value: _selectedSemester,
              hint: const Text('Pilih semester'),
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: semesters
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() => _selectedSemester = val);
                ref
                    .read(paKhsControllerProvider((
                      mahasiswaId: widget.mahasiswaId,
                      semester: val,
                    )).notifier)
                    .load();
              },
            ),
        ],
      ),
    );
  }

  // ─── KHS area ────────────────────────────────────────────────────────────

  Widget _buildKhsArea() {
    if (_selectedSemester == null) {
      return Center(
        child: Text(
          'Pilih semester untuk melihat KHS',
          style: BaseTypography.bodyMedium.toGrey,
        ),
      );
    }

    final khsState = ref.watch(paKhsControllerProvider((
      mahasiswaId: widget.mahasiswaId,
      semester: _selectedSemester!,
    )));

    if (khsState is PaKhsLoading || khsState is PaKhsInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (khsState is PaKhsError) {
      return Center(
        child: Text(khsState.message,
            style: BaseTypography.bodySmall.copyWith(color: Colors.red)),
      );
    }
    if (khsState is PaKhsLoaded) {
      return _buildKhsContent(khsState.data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildKhsContent(KhsModel khs) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMahasiswaInfo(khs.mahasiswa),
          Gap.h12,
          _buildStatistik(khs.statistik),
          Gap.h12,
          _buildNilaiTable(khs.nilai),
          Gap.h16,
          _buildDownloadButton(khs),
          Gap.h32,
        ],
      ),
    );
  }

  Widget _buildMahasiswaInfo(KhsMahasiswaModel mhs) {
    return _InfoCard(
      children: [
        _InfoRow('Nama', mhs.nama),
        _InfoRow('NIM', mhs.nim),
        _InfoRow('Angkatan', mhs.angkatan),
        _InfoRow('Program Studi', mhs.prodi),
        if (mhs.pembimbingAkademik != null)
          _InfoRow('Pembimbing Akademik', mhs.pembimbingAkademik!),
      ],
    );
  }

  Widget _buildStatistik(KhsStatistikModel stat) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'IPS', value: stat.ips.toStringAsFixed(2))),
        Gap.w8,
        Expanded(
            child: _StatCard(
                label: 'IPK', value: stat.ipk.toStringAsFixed(2))),
        Gap.w8,
        Expanded(
            child: _StatCard(
                label: 'Total SKS', value: stat.totalSks.toString())),
        Gap.w8,
        Expanded(
            child: _StatCard(
                label: 'Maks SKS',
                value: stat.maksBebaSksBerikutnya.toString())),
      ],
    );
  }

  Widget _buildNilaiTable(List<KhsNilaiItemModel> nilaiList) {
    return Container(
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
          Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Text('Daftar Nilai',
                style: BaseTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          // Header
          _buildTableHeader(),
          // Rows
          ...nilaiList.asMap().entries.map((e) {
            final isOdd = e.key % 2 == 1;
            return _buildTableRow(e.value, isOdd);
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: BaseColor.primaryInspire.withValues(alpha: 0.08),
      padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16, vertical: BaseSize.customWidth(8)),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
              child: Text('Mata Kuliah',
                  style: BaseTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w700))),
          SizedBox(
              width: 40,
              child: Text('SKS',
                  textAlign: TextAlign.center,
                  style: BaseTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w700))),
          SizedBox(
              width: 40,
              child: Text('Nilai',
                  textAlign: TextAlign.center,
                  style: BaseTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w700))),
          SizedBox(
              width: 40,
              child: Text('Indeks',
                  textAlign: TextAlign.center,
                  style: BaseTypography.labelSmall
                      .copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Widget _buildTableRow(KhsNilaiItemModel item, bool isOdd) {
    return Container(
      color: isOdd
          ? Colors.grey.shade50
          : Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16, vertical: BaseSize.customWidth(10)),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text('${item.no}',
                  style: BaseTypography.labelSmall.toGrey)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.namaMk,
                    style: BaseTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(item.kodeMk,
                    style: BaseTypography.labelSmall.toGrey),
              ],
            ),
          ),
          SizedBox(
              width: 40,
              child: Text('${item.sks}',
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodySmall)),
          SizedBox(
              width: 40,
              child: Text(item.nilaiHuruf,
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _gradeColor(item.nilaiHuruf)))),
          SizedBox(
              width: 40,
              child: Text(item.indeks.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: BaseTypography.bodySmall)),
        ],
      ),
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

  Widget _buildDownloadButton(KhsModel khs) {
    return SizedBox(
      width: double.infinity,
      child: _DownloadKhsButton(
        mahasiswaId: widget.mahasiswaId,
        semester: khs.semester,
        nim: khs.mahasiswa.nim,
      ),
    );
  }
}

// ─── Download KHS Button ─────────────────────────────────────────────────────

class _DownloadKhsButton extends ConsumerStatefulWidget {
  final int mahasiswaId;
  final String semester;
  final String nim;

  const _DownloadKhsButton({
    required this.mahasiswaId,
    required this.semester,
    required this.nim,
  });

  @override
  ConsumerState<_DownloadKhsButton> createState() =>
      _DownloadKhsButtonState();
}

class _DownloadKhsButtonState extends ConsumerState<_DownloadKhsButton> {
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
          .read(paKhsControllerProvider((
            mahasiswaId: widget.mahasiswaId,
            semester: widget.semester,
          )).notifier)
          .downloadPdf();

      final safeSem = widget.semester
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final filename =
          'KHS_${widget.nim}_${safeSem}_${DateTime.now().millisecondsSinceEpoch}.pdf';

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
              content: Text('KHS disimpan: $res'),
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
              content: Text('KHS disimpan: ${file.path}'),
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
      label: Text(_loading ? 'Mengunduh...' : 'Unduh KHS PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: BaseColor.primaryInspire,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ─── Shared Small Widgets ─────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
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
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label,
                style: BaseTypography.bodySmall
                    .copyWith(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value, style: BaseTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style: BaseTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BaseColor.primaryInspire)),
          const SizedBox(height: 2),
          Text(label,
              style: BaseTypography.labelSmall.toGrey,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
