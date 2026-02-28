import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/nilai/presentation/controllers/nilai_controller.dart';
import 'package:inspire/features/nilai/presentation/states/nilai_state.dart';

/// Lists all classes the lecturer teaches. Tapping a class navigates to its
/// student-grade detail screen.
class MyClassesLecturerScreen extends ConsumerStatefulWidget {
  const MyClassesLecturerScreen({super.key});

  @override
  ConsumerState<MyClassesLecturerScreen> createState() =>
      _MyClassesLecturerScreenState();
}

class _MyClassesLecturerScreenState
    extends ConsumerState<MyClassesLecturerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nilaiKelasListControllerProvider.notifier).loadKelasDosen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nilaiKelasListControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(
        title: 'Kelas Saya',
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
        loaded: (kelasList) => kelasList.isEmpty
            ? _buildEmptyState()
            : _buildKelasList(kelasList),
        error: (message) => _buildErrorState(message),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade300),
          Gap.h16,
          Text(
            'Belum ada kelas',
            style: BaseTypography.bodyLarge.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          Gap.h8,
          Text(
            'Kelas yang Anda ampu akan muncul di sini',
            style: BaseTypography.bodySmall.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

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
                .read(nilaiKelasListControllerProvider.notifier)
                .loadKelasDosen(),
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

  Widget _buildKelasList(List<KelasDosenItemModel> kelasList) {
    return RefreshIndicator(
      color: BaseColor.primaryInspire,
      onRefresh: () => ref
          .read(nilaiKelasListControllerProvider.notifier)
          .loadKelasDosen(),
      child: ListView.separated(
        padding: EdgeInsets.all(BaseSize.customWidth(16)),
        itemCount: kelasList.length,
        separatorBuilder: (_, __) => Gap.h12,
        itemBuilder: (context, index) {
          final kelas = kelasList[index];
          return _KelasCard(
            kelas: kelas,
            onTap: () {
              context.pushNamed(
                AppRoute.gradingLecturer,
                extra: kelas.kelasId,
              );
            },
          );
        },
      ),
    );
  }
}

class _KelasCard extends StatelessWidget {
  final KelasDosenItemModel kelas;
  final VoidCallback onTap;

  const _KelasCard({required this.kelas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: BaseColor.primaryInspire,
                size: 24,
              ),
            ),
            Gap.w12,
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kelas.namaKelas,
                    style: BaseTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Text(
                    '${kelas.kodeMK} — ${kelas.namaMK}',
                    style: BaseTypography.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap.h4,
                  Row(
                    children: [
                      _infoBadge('${kelas.sks} SKS'),
                      Gap.w8,
                      _infoBadge(kelas.academicYear),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: BaseTypography.labelSmall.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
