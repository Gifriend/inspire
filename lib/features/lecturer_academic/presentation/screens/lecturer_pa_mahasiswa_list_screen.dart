import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/models/academic/mahasiswa_bimbingan_model.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/lecturer_academic/presentation/controllers/lecturer_academic_controller.dart';
import 'package:inspire/features/lecturer_academic/presentation/states/lecturer_academic_state.dart';

/// Daftar mahasiswa bimbingan PA dosen.
/// Tiap mahasiswa bisa dilihat KHS atau Transkripnya.
class LecturerPaMahasiswaListScreen extends ConsumerStatefulWidget {
  const LecturerPaMahasiswaListScreen({super.key});

  @override
  ConsumerState<LecturerPaMahasiswaListScreen> createState() =>
      _LecturerPaMahasiswaListScreenState();
}

class _LecturerPaMahasiswaListScreenState
    extends ConsumerState<LecturerPaMahasiswaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mahasiswaBimbinganControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mahasiswaBimbinganControllerProvider);

    return ScaffoldWidget(
      backgroundColor: BaseColor.neutral[10],
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Mahasiswa Bimbingan',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      child: _buildBody(state),
    );
  }

  Widget _buildBody(MahasiswaBimbinganState state) {
    if (state is MahasiswaBimbinganLoading ||
        state is MahasiswaBimbinganInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MahasiswaBimbinganError) {
      return _buildError(state.message);
    }
    if (state is MahasiswaBimbinganLoaded) {
      if (state.data.isEmpty) return _buildEmpty();
      return _buildList(state.data);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          Gap.h16,
          Text(
            'Belum ada mahasiswa bimbingan',
            style: BaseTypography.bodyLarge.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          Gap.h12,
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
            onPressed: () =>
                ref.read(mahasiswaBimbinganControllerProvider.notifier).load(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BaseColor.primaryInspire,
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MahasiswaBimbinganModel> list) {
    return RefreshIndicator(
      color: BaseColor.primaryInspire,
      onRefresh: () =>
          ref.read(mahasiswaBimbinganControllerProvider.notifier).load(),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.customWidth(12),
        ),
        itemCount: list.length,
        separatorBuilder: (_, _) => Gap.h12,
        itemBuilder: (context, index) => _MahasiswaCard(mahasiswa: list[index]),
      ),
    );
  }
}

class _MahasiswaCard extends StatelessWidget {
  final MahasiswaBimbinganModel mahasiswa;

  const _MahasiswaCard({required this.mahasiswa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + NIM
          Row(
            children: [
              CircleAvatar(
                backgroundColor: BaseColor.primaryInspire.withValues(
                  alpha: 0.15,
                ),
                radius: 22,
                child: Text(
                  mahasiswa.nama.isNotEmpty
                      ? mahasiswa.nama[0].toUpperCase()
                      : '?',
                  style: BaseTypography.bodyLarge.copyWith(
                    color: BaseColor.primaryInspire,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mahasiswa.nama,
                      style: BaseTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(mahasiswa.nim, style: BaseTypography.bodySmall.toGrey),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mahasiswa.status == 'AKTIF'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Text(
                  mahasiswa.status,
                  style: BaseTypography.labelSmall.copyWith(
                    color: mahasiswa.status == 'AKTIF'
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          Gap.h12,

          // Stats: IPK + SKS
          Row(
            children: [
              _StatChip(label: 'IPK', value: mahasiswa.ipk.toStringAsFixed(2)),
              Gap.w12,
              _StatChip(
                label: 'SKS Lulus',
                value: mahasiswa.totalSksLulus.toString(),
              ),
              Gap.w12,
              _StatChip(label: 'Angkatan', value: mahasiswa.angkatan),
            ],
          ),

          Gap.h8,

          Text(
            mahasiswa.prodi,
            style: BaseTypography.bodySmall.toGrey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Gap.h12,

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.lecturerPaKhs,
                    pathParameters: {'mahasiswaId': mahasiswa.id.toString()},
                    extra: mahasiswa.nama,
                  ),
                  icon: const Icon(Icons.assignment, size: 16),
                  label: const Text('KHS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BaseColor.primaryInspire,
                    side: BorderSide(color: BaseColor.primaryInspire),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              Gap.w8,
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed(
                    AppRoute.lecturerPaTranskrip,
                    pathParameters: {'mahasiswaId': mahasiswa.id.toString()},
                    extra: mahasiswa.nama,
                  ),
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Transkrip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColor.primaryInspire,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BaseColor.neutral[20] ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: BaseTypography.labelSmall.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: BaseTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
