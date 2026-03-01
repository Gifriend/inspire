import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/nilai/presentation/controllers/nilai_controller.dart';
import 'package:inspire/features/nilai/presentation/states/nilai_state.dart';

/// Detail screen: lists students in a class with their grades and allows
/// the lecturer to input/edit grades (tugas, UTS, UAS).
class GradingLecturerScreen extends ConsumerStatefulWidget {
  final int kelasId;

  const GradingLecturerScreen({super.key, required this.kelasId});

  @override
  ConsumerState<GradingLecturerScreen> createState() =>
      _GradingLecturerScreenState();
}

class _GradingLecturerScreenState
    extends ConsumerState<GradingLecturerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(nilaiKelasDetailControllerProvider(widget.kelasId).notifier)
          .loadNilai();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(nilaiKelasDetailControllerProvider(widget.kelasId));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Penilaian',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: state.when(
        initial: () => const Center(child: Text('Memuat...')),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: BaseColor.primaryInspire,
          ),
        ),
        loaded: (data) => _buildContent(data),
        error: (message) => _buildErrorState(message),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          Gap.h16,
          Text('Gagal memuat data', style: BaseTypography.bodyLarge),
          Gap.h8,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
            child: Text(
              message,
              style: BaseTypography.bodySmall.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Gap.h16,
          ElevatedButton(
            onPressed: () => ref
                .read(nilaiKelasDetailControllerProvider(widget.kelasId)
                    .notifier)
                .loadNilai(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BaseColor.primaryInspire,
            ),
            child: const Text('Coba Lagi',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Main Content ────────────────────────────────────────────────

  Widget _buildContent(KelasNilaiModel data) {
    return Column(
      children: [
        // Header card
        _buildClassHeader(data),
        // Students list
        Expanded(
          child: data.mahasiswa.isEmpty
              ? _buildEmptyStudents()
              : RefreshIndicator(
                  color: BaseColor.primaryInspire,
                  onRefresh: () => ref
                      .read(nilaiKelasDetailControllerProvider(widget.kelasId)
                          .notifier)
                      .loadNilai(),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: BaseSize.customWidth(16),
                      vertical: BaseSize.customWidth(8),
                    ),
                    itemCount: data.mahasiswa.length,
                    separatorBuilder: (_, _) => Gap.h12,
                    itemBuilder: (context, index) {
                      final mhs = data.mahasiswa[index];
                      return _StudentGradeCard(
                        mhs: mhs,
                        onEdit: () => _showGradeInputDialog(mhs),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildClassHeader(KelasNilaiModel data) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(BaseSize.customWidth(16)),
      padding: EdgeInsets.all(BaseSize.customWidth(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BaseColor.primaryInspire,
            BaseColor.primaryInspire.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.namaKelas,
            style: BaseTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap.h4,
          Text(
            '${data.kodeMK} — ${data.namaMK}',
            style: BaseTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          Gap.h8,
          Row(
            children: [
              _whiteChip('${data.sks} SKS'),
              Gap.w8,
              _whiteChip(data.academicYear),
              Gap.w8,
              _whiteChip('${data.mahasiswa.length} Mahasiswa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whiteChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: BaseTypography.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyStudents() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          Gap.h16,
          Text(
            'Belum ada mahasiswa',
            style: BaseTypography.bodyLarge.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Grade Input Dialog ──────────────────────────────────────────

  void _showGradeInputDialog(NilaiMahasiswaModel mhs) {
    final tugasCtrl =
        TextEditingController(text: mhs.nilaiTugas?.toString() ?? '');
    final utsCtrl =
        TextEditingController(text: mhs.nilaiUTS?.toString() ?? '');
    final uasCtrl =
        TextEditingController(text: mhs.nilaiUAS?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        title: Text(
          'Input Nilai',
          style: BaseTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mhs.namaMahasiswa,
                style: BaseTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'NIM: ${mhs.nim}',
                style: BaseTypography.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Gap.h16,
              _gradeField('Nilai Tugas (30%)', tugasCtrl),
              Gap.h12,
              _gradeField('Nilai UTS (30%)', utsCtrl),
              Gap.h12,
              _gradeField('Nilai UAS (40%)', uasCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Consumer(builder: (context, ref, _) {
            final inputState = ref.watch(nilaiInputControllerProvider);
            final isLoading = inputState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final dto = InputNilaiDto(
                        mahasiswaId: mhs.mahasiswaId,
                        mataKuliahId: mhs.mataKuliahId,
                        academicYear: mhs.academicYear,
                        nilaiTugas: double.tryParse(tugasCtrl.text),
                        nilaiUTS: double.tryParse(utsCtrl.text),
                        nilaiUAS: double.tryParse(uasCtrl.text),
                      );

                      final ok = await ref
                          .read(nilaiInputControllerProvider.notifier)
                          .inputNilai(dto);

                      if (!ctx.mounted) return;

                      if (ok) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Nilai berhasil disimpan'),
                            backgroundColor: BaseColor.primaryInspire,
                          ),
                        );
                        // Refresh detail
                        ref
                            .read(nilaiKelasDetailControllerProvider(
                                    widget.kelasId)
                                .notifier)
                            .loadNilai();
                      } else {
                        final errorMsg = ref
                            .read(nilaiInputControllerProvider)
                            .maybeWhen(
                              error: (m) => m,
                              orElse: () => 'Gagal menyimpan nilai',
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      ref
                          .read(nilaiInputControllerProvider.notifier)
                          .resetState();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: BaseColor.primaryInspire,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan',
                      style: TextStyle(color: Colors.white)),
            );
          }),
        ],
      ),
    );
  }

  Widget _gradeField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: BaseTypography.bodySmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          borderSide: BorderSide(color: BaseColor.primaryInspire),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

// ─── Student Grade Card Widget ─────────────────────────────────────

class _StudentGradeCard extends StatelessWidget {
  final NilaiMahasiswaModel mhs;
  final VoidCallback onEdit;

  const _StudentGradeCard({required this.mhs, required this.onEdit});

  Color get _statusColor {
    switch (mhs.status) {
      case 'FINAL':
        return Colors.green;
      case 'DRAFT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (mhs.status) {
      case 'FINAL':
        return 'Final';
      case 'DRAFT':
        return 'Draft';
      default:
        return 'Belum Ada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSize.customWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student name + status badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mhs.namaMahasiswa,
                      style: BaseTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      'NIM: ${mhs.nim}',
                      style: BaseTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel,
                  style: BaseTypography.labelSmall.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Gap.h12,
          // Grade chips
          Row(
            children: [
              _gradeChip('Tugas', mhs.nilaiTugas),
              Gap.w8,
              _gradeChip('UTS', mhs.nilaiUTS),
              Gap.w8,
              _gradeChip('UAS', mhs.nilaiUAS),
            ],
          ),
          Gap.h8,
          // Final grade row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Nilai Akhir: ',
                      style: BaseTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      mhs.nilaiAkhir != null
                          ? mhs.nilaiAkhir!.toStringAsFixed(1)
                          : '-',
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap.w12,
                    if (mhs.nilaiHuruf != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              BaseColor.primaryInspire.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mhs.nilaiHuruf!,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.primaryInspire,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Edit button
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: BaseColor.primaryInspire,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradeChip(String label, double? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: BaseTypography.labelSmall.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            Gap.h4,
            Text(
              value != null ? value.toStringAsFixed(1) : '-',
              style: BaseTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
