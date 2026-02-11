import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/routing/app_routing.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/krs/presentation/controllers/krs_controller.dart';
import 'package:inspire/core/models/krs/krs_model.dart';
import 'package:inspire/features/krs/presentation/states/krs_state.dart';

import '../../../../core/constants/constants.dart';

class KrsScreen extends ConsumerStatefulWidget {
  final String semester;

  const KrsScreen({super.key, required this.semester});

  @override
  ConsumerState<KrsScreen> createState() => _KrsScreenState();
}

class _KrsScreenState extends ConsumerState<KrsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(krsControllerProvider(widget.semester).notifier).loadKrs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final krsState = ref.watch(krsControllerProvider(widget.semester));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h16,
          ScreenTitleWidget.titleOnly(title: 'Kartu Rencana Studi'),
          Gap.h12,
          _buildSemesterInfo(),
          Gap.h20,
          Expanded(
            child: krsState.when(
              initial: () => const Center(child: Text('Memuat...')),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (krs) => _buildKrsContent(krs),
              error: (message) => Center(
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
                      'Gagal memuat KRS',
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
                        ref
                            .read(krsControllerProvider(widget.semester).notifier)
                            .loadKrs();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
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
        color: BaseColor.primaryInspire.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: BaseColor.primaryInspire,
            size: 20,
          ),
          Gap.w12,
          Text(
            'Semester: ${widget.semester}',
            style: BaseTypography.bodyLarge.toBold.copyWith(
              color: BaseColor.primaryInspire,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrsContent(KrsModel krs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKrsHeader(krs),
        Gap.h20,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Mata Kuliah',
              style: BaseTypography.titleMedium.toBold,
            ),
            if (krs.status == StatusKRS.draft)
              TextButton.icon(
                onPressed: () {
                  context.pushNamed(
                    AppRoute.krsAddClass,
                    pathParameters: {'semester': widget.semester},
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah MK'),
              ),
          ],
        ),
        Gap.h12,
        Expanded(
          child: krs.kelasPerkuliahan.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: krs.kelasPerkuliahan.length,
                  itemBuilder: (context, index) {
                    final kelas = krs.kelasPerkuliahan[index];
                    return _buildKelasCard(kelas, krs.status);
                  },
                ),
        ),
        if (krs.status == StatusKRS.draft && krs.kelasPerkuliahan.isNotEmpty)
          _buildSubmitButton(krs),
      ],
    );
  }

  Widget _buildKrsHeader(KrsModel krs) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status:', style: BaseTypography.bodyMedium),
              _buildStatusChip(krs.status),
            ],
          ),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total SKS:', style: BaseTypography.bodyMedium),
              Text(
                '${krs.totalSKS} SKS',
                style: BaseTypography.bodyLarge.toBold.copyWith(
                  color: BaseColor.primaryInspire,
                ),
              ),
            ],
          ),
          if (krs.catatanDosen != null) ...[
            Gap.h12,
            Divider(),
            Gap.h8,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catatan Dosen:',
                style: BaseTypography.bodySmall.toBold,
              ),
            ),
            Gap.h4,
            Text(
              krs.catatanDosen!,
              style: BaseTypography.bodySmall.toGrey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(StatusKRS status) {
    Color color;
    String text;

    switch (status) {
      case StatusKRS.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case StatusKRS.diajukan:
        color = Colors.orange;
        text = 'Diajukan';
        break;
      case StatusKRS.disetujui:
        color = Colors.green;
        text = 'Disetujui';
        break;
      case StatusKRS.ditolak:
        color = Colors.red;
        text = 'Ditolak';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: BaseTypography.bodySmall.toBold.copyWith(color: color),
      ),
    );
  }

  Widget _buildKelasCard(KelasPerkuliahanModel kelas, StatusKRS status) {
    return Card(
      margin: EdgeInsets.only(bottom: BaseSize.h12),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas.mataKuliah?.name ?? kelas.nama,
                        style: BaseTypography.bodyMedium.toBold,
                      ),
                      Gap.h4,
                      Text(
                        '${kelas.kode} • ${kelas.mataKuliah?.sks ?? 0} SKS',
                        style: BaseTypography.bodySmall.toGrey,
                      ),
                    ],
                  ),
                ),
                if (status == StatusKRS.draft)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(kelas),
                  ),
              ],
            ),
            if (kelas.dosen != null) ...[
              Gap.h8,
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: BaseColor.grey),
                  Gap.w4,
                  Text(
                    kelas.dosen!.name,
                    style: BaseTypography.bodySmall,
                  ),
                ],
              ),
            ],
            if (kelas.jadwal != null) ...[
              Gap.h4,
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: BaseColor.grey),
                  Gap.w4,
                  Text(
                    kelas.jadwal!,
                    style: BaseTypography.bodySmall,
                  ),
                ],
              ),
            ],
            if (kelas.ruangan != null) ...[
              Gap.h4,
              Row(
                children: [
                  Icon(Icons.room, size: 16, color: BaseColor.grey),
                  Gap.w4,
                  Text(
                    kelas.ruangan!,
                    style: BaseTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: BaseColor.grey,
          ),
          Gap.h16,
          Text(
            'Belum ada mata kuliah dipilih',
            style: BaseTypography.bodyLarge.toGrey,
          ),
          Gap.h8,
          Text(
            'Tap tombol "Tambah MK" untuk memilih',
            style: BaseTypography.bodySmall.toGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(KrsModel krs) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
      child: ButtonWidget.primary(
        text: 'Ajukan KRS (${krs.totalSKS} SKS)',
        color: BaseColor.primaryInspire,
        onTap: () => _showSubmitConfirmation(krs),
      ),
    );
  }

  void _showDeleteConfirmation(KelasPerkuliahanModel kelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${kelas.mataKuliah?.name ?? kelas.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(krsControllerProvider(widget.semester).notifier)
                  .removeClass(kelas.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation(KrsModel krs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajukan KRS?'),
        content: Text(
          'Total ${krs.totalSKS} SKS dengan ${krs.kelasPerkuliahan.length} mata kuliah.\n\n'
          'Setelah diajukan, KRS tidak dapat diubah sampai disetujui/ditolak dosen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(krsControllerProvider(widget.semester).notifier)
                  .submitKrs();
            },
            child: const Text('Ajukan'),
          ),
        ],
      ),
    );
  }
}
