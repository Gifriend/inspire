import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/krs/krs_lecturer_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/krs_lecturer/presentation/controllers/krs_lecturer_controller.dart';
import 'package:inspire/features/krs_lecturer/presentation/states/krs_lecturer_state.dart';

class KrsLecturerDetailScreen extends ConsumerStatefulWidget {
  final int krsId;

  const KrsLecturerDetailScreen({super.key, required this.krsId});

  @override
  ConsumerState<KrsLecturerDetailScreen> createState() =>
      _KrsLecturerDetailScreenState();
}

class _KrsLecturerDetailScreenState
    extends ConsumerState<KrsLecturerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(krsLecturerDetailControllerProvider(widget.krsId).notifier)
          .loadDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      krsLecturerDetailControllerProvider(widget.krsId),
    );

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Detail KRS',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: detailState.when(
        initial: () => const Center(child: Text('Memuat...')),
        loading: () => Center(
          child: CircularProgressIndicator(color: BaseColor.primaryInspire),
        ),
        loaded: (krs) => _buildContent(krs),
        error: (message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              Gap.h16,
              Text('Gagal memuat detail KRS', style: BaseTypography.bodyLarge),
              Gap.h8,
              Text(
                message,
                style: BaseTypography.bodySmall.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              ElevatedButton(
                onPressed: () => ref
                    .read(
                      krsLecturerDetailControllerProvider(
                        widget.krsId,
                      ).notifier,
                    )
                    .loadDetail(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(KrsSubmissionModel krs) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentCard(krs),
                Gap.h16,
                _buildKrsSummaryCard(krs),
                Gap.h16,
                if (krs.catatanDosen != null &&
                    krs.catatanDosen!.isNotEmpty) ...[
                  _buildCatatanCard(krs.catatanDosen!),
                  Gap.h16,
                ],
                // Class list header
                Text(
                  'Daftar Mata Kuliah (${krs.kelasPerkuliahan.length})',
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap.h12,

                // Class list
                ...krs.kelasPerkuliahan.map((kelas) => _buildKelasCard(kelas)),
                Gap.h16,
              ],
            ),
          ),
        ),
        _buildBottomActionBar(
          krs,
        ), // Memanggil fungsi Action Bar yang baru dibuat
      ],
    );
  }

  Widget _buildStudentCard(KrsSubmissionModel krs) {
    final student = krs.mahasiswa;
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: BaseColor.primaryInspire.withValues(alpha: 0.1),
            child: Text(
              (student?.nama ?? '?')[0].toUpperCase(),
              style: BaseTypography.titleLarge.copyWith(
                color: BaseColor.primaryInspire,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Gap.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.nama ?? 'Mahasiswa',
                  style: BaseTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap.h4,
                if (student?.nim != null)
                  Text(
                    'NIM: ${student!.nim}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (student?.ipk != null)
                  Text(
                    'IPK: ${student!.ipk}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (student?.totalSksLulus != null)
                  Text(
                    'Total SKS Lulus: ${student!.totalSksLulus}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrsSummaryCard(KrsSubmissionModel krs) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tahun Akademik', style: BaseTypography.bodyMedium),
              Text(
                krs.academicYear,
                style: BaseTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: BaseTypography.bodyMedium),
              _buildStatusChip(krs.status),
            ],
          ),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total SKS', style: BaseTypography.bodyMedium),
              Text(
                '${krs.totalSKS} SKS',
                style: BaseTypography.bodyLarge.copyWith(
                  color: BaseColor.primaryInspire,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jumlah MK', style: BaseTypography.bodyMedium),
              Text(
                '${krs.kelasPerkuliahan.length} mata kuliah',
                style: BaseTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (krs.tanggalPengajuan != null) ...[
            Gap.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tanggal Pengajuan', style: BaseTypography.bodyMedium),
                Text(
                  _formatDate(krs.tanggalPengajuan!),
                  style: BaseTypography.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
          if (krs.tanggalPersetujuan != null) ...[
            Gap.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tanggal Persetujuan', style: BaseTypography.bodyMedium),
                Text(
                  _formatDate(krs.tanggalPersetujuan!),
                  style: BaseTypography.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCatatanCard(String catatan) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 16,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Catatan Dosen',
                style: BaseTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          Gap.h8,
          Text(catatan, style: BaseTypography.bodyMedium),
        ],
      ),
    );
  }

  // Mengubah nama salah satu fungsi agar tidak terjadi method overloading
  Widget _buildKelasCard(KrsKelasDetailItem kelas) {
    return Card(
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kelas.namaMK,
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h4,
            Text(
              '${kelas.kodeMK} • ${kelas.sks} SKS',
              style: BaseTypography.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (kelas.namaKelas != null) ...[
              Gap.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kelas.namaKelas!,
                  style: BaseTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: BaseColor.primaryInspire,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (kelas.dosenPengampu != null) ...[
              Gap.h8,
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      kelas.dosenPengampu!,
                      style: BaseTypography.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Perbaikan struktur Status KRS yang terputus
  Widget _buildStatusChip(StatusKRS status) {
    Color color;
    String text;

    switch (status) {
      case StatusKRS.diajukan: // Sesuaikan enum ini dengan milik Anda
        color = Colors.blue;
        text = 'Diajukan';
        break;
      case StatusKRS.disetujui: // Sesuaikan enum ini dengan milik Anda
        color = Colors.green;
        text = 'Disetujui';
        break;
      case StatusKRS.ditolak:
        color = Colors.red;
        text = 'Ditolak';
        break;
      default:
        color = Colors.orange;
        text = 'Draft';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: BaseTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // --- Widget Bottom Action Bar yang baru ---
  Widget _buildBottomActionBar(KrsSubmissionModel krs) {
    // Sesuaikan status enum dengan logika bisnis Anda
    if (krs.status == StatusKRS.ditolak) {
      return const SizedBox.shrink(); // Jika ditolak, sembunyikan baris tombol
    }

    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (krs.status == StatusKRS.disetujui) ...[
              // Tombol untuk Batalkan
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(krs),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: const Text('Batalkan Persetujuan'),
                ),
              ),
            ] else ...[
              // Tombol Tolak & Setujui (Jika masih Diajukan/Draft)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(krs),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              Gap.w16,
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApproveDialog(krs),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: const Text('Setujui'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ─── Action dialogs ─────────────────────────────────────────────

  void _showApproveDialog(KrsSubmissionModel krs) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui KRS?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${krs.mahasiswa?.nama ?? 'Mahasiswa'} — '
              '${krs.totalSKS} SKS, '
              '${krs.kelasPerkuliahan.length} MK',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .approveKrs(
                    krs.id,
                    catatan: catatanController.text.isNotEmpty
                        ? catatanController.text
                        : null,
                  );
              if (success && mounted) {
                _showSnackBar('KRS berhasil disetujui', Colors.green);
                _reloadDetail();
              }
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(KrsSubmissionModel krs) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak KRS?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KRS ${krs.mahasiswa?.nama ?? ''} akan ditolak dan '
              'dikembalikan ke mahasiswa.',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan *',
                border: OutlineInputBorder(),
                hintText: 'Wajib diisi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (catatanController.text.trim().isEmpty) {
                _showSnackBar('Alasan penolakan wajib diisi', Colors.orange);
                return;
              }
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .rejectKrs(krs.id, catatan: catatanController.text.trim());
              if (success && mounted) {
                _showSnackBar('KRS berhasil ditolak', Colors.red);
                _reloadDetail();
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(KrsSubmissionModel krs) {
    final catatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Persetujuan?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KRS ${krs.mahasiswa?.nama ?? ''} yang sudah disetujui '
              'akan dikembalikan ke status Draft.',
              style: BaseTypography.bodySmall,
            ),
            Gap.h16,
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Alasan pembatalan *',
                border: OutlineInputBorder(),
                hintText: 'Wajib diisi',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (catatanController.text.trim().isEmpty) {
                _showSnackBar('Alasan pembatalan wajib diisi', Colors.orange);
                return;
              }
              Navigator.pop(ctx);
              final success = await ref
                  .read(krsLecturerActionControllerProvider.notifier)
                  .cancelKrs(krs.id, catatan: catatanController.text.trim());
              if (success && mounted) {
                _showSnackBar(
                  'Persetujuan KRS berhasil dibatalkan',
                  Colors.orange,
                );
                _reloadDetail();
              }
            },
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  void _reloadDetail() {
    ref
        .read(krsLecturerDetailControllerProvider(widget.krsId).notifier)
        .loadDetail();
    // Pastikan krsLecturerListControllerProvider sudah di-import di file state/controller
    // ref.invalidate(krsLecturerListControllerProvider);
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
