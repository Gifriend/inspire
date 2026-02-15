import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

class KhsSemesterListScreen extends ConsumerStatefulWidget {
  const KhsSemesterListScreen({super.key});

  @override
  ConsumerState<KhsSemesterListScreen> createState() => _KhsSemesterListScreenState();
}

class _KhsSemesterListScreenState extends ConsumerState<KhsSemesterListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(semesterListControllerProvider.notifier).loadSemesters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(semesterListControllerProvider);

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h16,
          ScreenTitleWidget.titleOnly(title: 'Kartu Hasil Studi (KHS)'),
          Gap.h12,
          _buildInfoCard(),
          Gap.h20,
          state.when(
            initial: () => const Center(child: Text('Memuat...')),
            loading: () => Center(
              child: CircularProgressIndicator(
                color: BaseColor.primaryInspire,
              ),
            ),
            loaded: (semesters) => _buildSemesterList(semesters),
            error: (message) => _buildErrorState(message),
          ),
        ],
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
        children: [
          Icon(
            Icons.info_outline,
            color: BaseColor.primaryInspire,
            size: 24,
          ),
          Gap.w12,
          Expanded(
            child: Text(
              'Pilih semester untuk melihat Kartu Hasil Studi',
              style: BaseTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterList(List<String> semesters) {
    if (semesters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            Gap.h16,
            Text(
              'Belum ada data semester',
              style: BaseTypography.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: semesters.length,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        final semester = semesters[index];
        return _buildSemesterCard(semester);
      },
    );
  }

  Widget _buildSemesterCard(String semester) {
    return InkWell(
      onTap: () {
        context.push('/khs/$semester');
      },
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w12),
              decoration: BoxDecoration(
                color: BaseColor.primaryInspire.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: Icon(
                Icons.school,
                color: BaseColor.primaryInspire,
                size: 24,
              ),
            ),
            Gap.w16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semester',
                    style: BaseTypography.bodySmall.toGrey,
                  ),
                  Gap.h4,
                  Text(
                    semester,
                    style: BaseTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          Gap.h16,
          Text(
            'Gagal memuat data',
            style: BaseTypography.bodyLarge,
          ),
          Gap.h8,
          Text(
            message,
            style: BaseTypography.bodySmall.toGrey,
            textAlign: TextAlign.center,
          ),
          Gap.h16,
          ElevatedButton(
            onPressed: () {
              ref.read(semesterListControllerProvider.notifier).loadSemesters();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
