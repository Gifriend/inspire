import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

import '../../../../core/assets/assets.dart';

class KhsDetailScreen extends ConsumerStatefulWidget {
  final String semester;

  const KhsDetailScreen({super.key, required this.semester});

  @override
  ConsumerState<KhsDetailScreen> createState() => _KhsDetailScreenState();
}

class _KhsDetailScreenState extends ConsumerState<KhsDetailScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(khsControllerProvider(widget.semester).notifier).loadKhs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(khsControllerProvider(widget.semester));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Kartu Hasil Studi',
        leadIcon: Assets.icons.fill.arrowBack,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h12,
          _buildSemesterInfo(),
          Gap.h20,
          Expanded(
            child: state.when(
              initial: () => const Center(child: Text('Memuat...')),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (khs) => _buildKhsContent(khs),
              error: (message) => _buildErrorState(message),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterInfo() {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: BaseColor.primaryInspire, size: 20),
          Gap.w12,
          Text(
            widget.semester,
            style: BaseTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKhsContent(KhsModel khs) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMahasiswaInfo(khs.mahasiswa),
          Gap.h16,
          _buildStatistikCard(khs),
          Gap.h20,
          _buildNilaiSection(khs.nilai),
          Gap.h20,
          _buildDownloadButton(),
          Gap.h20,
        ],
      ),
    );
  }

  Widget _buildMahasiswaInfo(KhsMahasiswaModel mahasiswa) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Nama', mahasiswa.nama),
          Gap.h8,
          _buildInfoRow('NIM', mahasiswa.nim),
          Gap.h8,
          _buildInfoRow('Angkatan', mahasiswa.angkatan),
          Gap.h8,
          _buildInfoRow('Program Studi', mahasiswa.prodi),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: BaseTypography.bodyMedium.toGrey),
        ),
        Text(': ', style: BaseTypography.bodyMedium.toGrey),
        Expanded(
          child: Text(
            value,
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistikCard(KhsModel khs) {
    final stat = khs.statistik;
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BaseColor.primaryInspire,
            BaseColor.primaryInspire.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BaseColor.primaryInspire.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total SKS', stat.totalSks.toString()),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(
                child: _buildStatItem(
                  'Total Bobot',
                  stat.totalNilaiSks.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          Gap.h16,
          Divider(color: Colors.white30),
          Gap.h16,
          Row(
            children: [
              Expanded(
                child: _buildStatItem('IPS', stat.ips.toStringAsFixed(2)),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(
                child: _buildStatItem('IPK', stat.ipk.toStringAsFixed(2)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: BaseTypography.bodySmall.copyWith(color: Colors.white70),
        ),
        Gap.h4,
        Text(
          value,
          style: BaseTypography.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNilaiSection(List<KhsNilaiItemModel> nilaiList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Nilai',
          style: BaseTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap.h12,
        if (nilaiList.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSize.h32),
              child: Text(
                'Belum ada nilai',
                style: BaseTypography.bodyMedium.toGrey,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nilaiList.length,
            separatorBuilder: (context, index) => Gap.h12,
            itemBuilder: (context, index) {
              final nilai = nilaiList[index];
              return _buildNilaiCard(nilai, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildNilaiCard(KhsNilaiItemModel nilai, int no) {
    Color gradeColor = _getGradeColor(nilai.nilaiHuruf);

    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '$no',
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.primaryInspire,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nilai.namaMk,
                      style: BaseTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(nilai.kodeMk, style: BaseTypography.bodySmall.toGrey),
                  ],
                ),
              ),
              Gap.w12,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w12,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  nilai.nilaiHuruf,
                  style: BaseTypography.titleMedium.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Gap.h12,
          Divider(color: Colors.grey.shade200),
          Gap.h8,
          Row(
            children: [
              _buildDetailItem('SKS', nilai.sks.toString()),
              Gap.w20,
              _buildDetailItem('Indeks', nilai.indeks.toStringAsFixed(1)),
              Gap.w20,
              _buildDetailItem('Mutu', nilai.nilaiSks.toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: BaseTypography.bodySmall.toGrey),
        Text(
          value,
          style: BaseTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen;
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

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isDownloading ? null : _handleDownload,
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
          padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownload() async {
    // 1. Minta Izin Dulu
    final hasPermission = await PermissionUtil.requestStorageForDownload();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin penyimpanan diperlukan untuk mengunduh KHS.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // Hentikan proses jika izin ditolak
    }

    setState(() => _isDownloading = true);
    try {
      final bytes = await ref
          .read(khsControllerProvider(widget.semester).notifier)
          .downloadKhsPdf();

      if (bytes.isEmpty || bytes.length < 500) {
        throw Exception('File PDF kosong atau data tidak valid.');
      }

      // 2. Bersihkan nama file & tambahkan timestamp agar Android 11+ tidak memblokir (Permission Denied)
      final safe = widget.semester
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'KHS_${safe}_$timestamp.pdf';

      // 3. Tentukan Target (Wajib Folder Download Publik)
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
            content: Text('KHS BARU disimpan di: $filePath'),
            backgroundColor: Colors
                .blue, // Sengaja BIRU untuk memastikan kode ini yang jalan
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR KHS: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          Gap.h16,
          Text('Gagal memuat KHS', style: BaseTypography.bodyLarge),
          Gap.h8,
          Text(
            message,
            style: BaseTypography.bodySmall.toGrey,
            textAlign: TextAlign.center,
          ),
          Gap.h16,
          ElevatedButton(
            onPressed: () {
              ref
                  .read(khsControllerProvider(widget.semester).notifier)
                  .loadKhs();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
