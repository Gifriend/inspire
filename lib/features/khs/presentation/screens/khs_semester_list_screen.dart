import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class KhsSemesterListScreen extends ConsumerStatefulWidget {
  const KhsSemesterListScreen({super.key});

  @override
  ConsumerState<KhsSemesterListScreen> createState() =>
      _KhsSemesterListScreenState();
}

class _KhsSemesterListScreenState extends ConsumerState<KhsSemesterListScreen> {
  String? _selectedSemester;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(semesterListControllerProvider.notifier).loadSemesters();
    });
  }

  void _onLihatKhs() {
    if (_selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih semester terlebih dahulu')),
      );
      return;
    }
    ref.read(khsControllerProvider(_selectedSemester!).notifier).loadKhs();
  }

  Future<void> _onCetakKhs() async {
    if (_selectedSemester == null) return;

    // 1. Minta Izin Dulu menggunakan utilitas Anda
    final hasPermission = await PermissionUtil.requestStorageForDownload();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin penyimpanan diperlukan untuk mencetak KHS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final bytes = await ref
          .read(khsControllerProvider(_selectedSemester!).notifier)
          .downloadKhsPdf();

      if (bytes.isEmpty || bytes.length < 500) {
        throw Exception('File PDF kosong atau data tidak valid');
      }

      // 2. Bersihkan nama file & tambahkan timestamp agar selalu unik di Scoped Storage
      final safeName = _selectedSemester!
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'KHS_${safeName}_$timestamp.pdf';

      // 3. Paksa Target ke Folder Download Publik
      final saveDir = Directory('/storage/emulated/0/Download');
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }

      final filePath = '${saveDir.path}/$filename';
      final file = File(filePath);

      // 4. Tulis File
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ KHS disimpan di: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesterState = ref.watch(semesterListControllerProvider);
    final khsState = _selectedSemester != null
        ? ref.watch(khsControllerProvider(_selectedSemester!))
        : null;

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: "Kartu Hasil Studi",
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap.h12,
            _buildInfoCard(),
            Gap.h20,

            // ── Semester Dropdown ──
            Text(
              'Semester',
              style: BaseTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap.h8,
            semesterState.when(
              initial: () => const SizedBox.shrink(),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (semesters) => _buildDropdown(semesters),
              error: (message) => _buildSemesterError(message),
            ),
            Gap.h16,

            // ── LIHAT KHS Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onLihatKhs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseColor.primaryInspire,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                ),
                child: const Text(
                  'LIHAT KHS',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // ── KHS Result ──
            if (khsState != null) ...[
              Gap.h24,
              khsState.when(
                initial: () => const SizedBox.shrink(),
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h32),
                    child: CircularProgressIndicator(
                      color: BaseColor.primaryInspire,
                    ),
                  ),
                ),
                loaded: (khs) => _buildKhsResult(khs),
                error: (message) => _buildKhsError(message),
              ),
            ],

            Gap.h24,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: BaseColor.primaryInspire, size: 22),
          Gap.w12,
          Expanded(
            child: Text(
              'Kartu Hasil Studi merupakan fasilitas yang dapat digunakan untuk melihat hasil studi mahasiswa per semester. Selain dapat dilihat secara online, hasil studi ini juga dapat dicetak.',
              style: BaseTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> semesters) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedSemester,
          hint: const Text('-- Pilih Semester --'),
          items: semesters
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedSemester = value);
          },
        ),
      ),
    );
  }

  Widget _buildSemesterError(String message) {
    return Column(
      children: [
        Text(
          'Gagal memuat semester',
          style: BaseTypography.bodyMedium.toRed500,
        ),
        Gap.h8,
        TextButton(
          onPressed: () =>
              ref.read(semesterListControllerProvider.notifier).loadSemesters(),
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }

  Widget _buildKhsResult(KhsModel khs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Kartu Hasil Studi',
          style: BaseTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Gap.h4,
        Text(
          'Semester: ${khs.semester}',
          style: BaseTypography.bodyMedium.toGrey,
        ),
        Gap.h16,

        // ── Student Info ──
        _buildInfoCard2(khs.mahasiswa),
        Gap.h16,

        // ── Grade Table ──
        _buildGradeTable(khs.nilai),
        Gap.h16,

        // ── Statistics ──
        _buildStatistik(khs.statistik),
        Gap.h20,

        // ── Download / Cetak Button ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isDownloading ? null : _onCetakKhs,
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print),
            label: Text(_isDownloading ? 'Mengunduh...' : 'Cetak KHS (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BaseColor.primaryInspire,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard2(KhsMahasiswaModel mahasiswa) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Nama', mahasiswa.nama),
      MapEntry('NIM', mahasiswa.nim),
      MapEntry('Angkatan', mahasiswa.angkatan),
      MapEntry('Program Studi', mahasiswa.prodi),
      if (mahasiswa.pembimbingAkademik != null)
        MapEntry('Pembimbing Akademik', mahasiswa.pembimbingAkademik!),
    ];
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: rows.map((e) {
          return Padding(
            padding: EdgeInsets.only(bottom: BaseSize.h8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(e.key, style: BaseTypography.bodySmall.toGrey),
                ),
                Text(': ', style: BaseTypography.bodySmall.toGrey),
                Expanded(
                  child: Text(
                    e.value,
                    style: BaseTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGradeTable(List<KhsNilaiItemModel> nilaiList) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 11,
      color: Colors.white,
    );
    const cellStyle = TextStyle(fontSize: 11);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(30), // No
            1: FixedColumnWidth(72), // Kode
            2: FlexColumnWidth(), // Nama MK
            3: FixedColumnWidth(38), // SKS
            4: FixedColumnWidth(40), // Nilai
            5: FixedColumnWidth(44), // Angka
            6: FixedColumnWidth(52), // Nil.SKS
          },
          border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: BaseColor.primaryInspire),
              children: [
                _tableCell('No', headerStyle, TextAlign.center),
                _tableCell('Kode', headerStyle, TextAlign.center),
                _tableCell('Mata Kuliah', headerStyle, TextAlign.left),
                _tableCell('SKS', headerStyle, TextAlign.center),
                _tableCell('Nilai', headerStyle, TextAlign.center),
                _tableCell('Angka', headerStyle, TextAlign.center),
                _tableCell('Nil.\nSKS', headerStyle, TextAlign.center),
              ],
            ),
            // Data rows
            ...nilaiList.asMap().entries.map((entry) {
              final idx = entry.key;
              final n = entry.value;
              final rowColor = idx.isOdd
                  ? const Color(0xFFF7F7F7)
                  : Colors.white;
              final gradeColor = _gradeColor(n.nilaiHuruf);
              return TableRow(
                decoration: BoxDecoration(color: rowColor),
                children: [
                  _tableCell('${n.no}', cellStyle, TextAlign.center),
                  _tableCell(n.kodeMk, cellStyle, TextAlign.left),
                  _tableCell(n.namaMk, cellStyle, TextAlign.left),
                  _tableCell('${n.sks}', cellStyle, TextAlign.center),
                  _tableCellGrade(n.nilaiHuruf, gradeColor),
                  _tableCell(
                    n.indeks.toStringAsFixed(2),
                    cellStyle,
                    TextAlign.center,
                  ),
                  _tableCell(
                    n.nilaiSks.toStringAsFixed(2),
                    cellStyle,
                    TextAlign.right,
                  ),
                ],
              );
            }),
            // Total row
            TableRow(
              decoration: BoxDecoration(color: const Color(0xFFEEEEEE)),
              children: [
                _tableCell('', cellStyle, TextAlign.center),
                _tableCell('', cellStyle, TextAlign.center),
                _tableCell(
                  'Total',
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  TextAlign.left,
                ),
                _tableCell(
                  '${nilaiList.fold(0, (s, n) => s + n.sks)}',
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  TextAlign.center,
                ),
                _tableCell('', cellStyle, TextAlign.center),
                _tableCell('', cellStyle, TextAlign.center),
                _tableCell(
                  nilaiList
                      .fold(0.0, (s, n) => s + n.nilaiSks)
                      .toStringAsFixed(2),
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text, TextStyle style, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _tableCellGrade(String grade, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            grade,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatistik(KhsStatistikModel stat) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('IP Semester (IPS)', stat.ips.toStringAsFixed(2)),
          Gap.h6,
          _buildStatRow('IP Kumulatif (IPK)', stat.ipk.toStringAsFixed(2)),
          Gap.h6,
          _buildStatRow(
            'Maks. Beban sks semester berikutnya',
            '${stat.maksBebaSksBerikutnya}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: BaseTypography.bodySmall)),
        Text(
          ': $value',
          style: BaseTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildKhsError(String message) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          Gap.h8,
          Text('Gagal memuat KHS', style: BaseTypography.bodyLarge),
          Gap.h4,
          Text(
            message,
            style: BaseTypography.bodySmall.toGrey,
            textAlign: TextAlign.center,
          ),
          Gap.h12,
          ElevatedButton(
            onPressed: () {
              if (_selectedSemester != null) {
                ref
                    .read(khsControllerProvider(_selectedSemester!).notifier)
                    .loadKhs();
              }
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen.shade700;
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
