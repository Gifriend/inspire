import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/utils/utils.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/krs/presentation/controllers/krs_controller.dart';
import 'package:inspire/core/models/krs/krs_model.dart';
import 'package:inspire/features/krs/presentation/states/krs_state.dart';

import '../../../../core/constants/constants.dart';

class AddClassScreen extends ConsumerStatefulWidget {
  final String semester;

  const AddClassScreen({super.key, required this.semester});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(availableClassesControllerProvider(widget.semester).notifier)
          .loadAvailableClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classesState =
        ref.watch(availableClassesControllerProvider(widget.semester));
    final krsState = ref.watch(krsControllerProvider(widget.semester));

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      appBar: AppBarWidget(title: 'Pilih Mata Kuliah',),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     IconButton(
          //       icon: const Icon(Icons.arrow_back),
          //       onPressed: () => Navigator.pop(context),
          //     ),
          //     Expanded(
          //       child: ScreenTitleWidget.titleOnly(
          //         title: 'Pilih Mata Kuliah',
          //       ),
          //     ),
          //   ],
          // ),
          // Gap.h20,
          // _buildSearchBar(),
          Gap.h20,
          krsState.maybeWhen(
            loaded: (krs) => _buildSelectedInfo(krs),
            orElse: () => const SizedBox.shrink(),
          ),
          Gap.h12,
          Expanded(
            child: classesState.when(
              initial: () => const Center(child: Text('Memuat...')),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: BaseColor.primaryInspire,
                ),
              ),
              loaded: (classes) => _buildClassList(classes),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    Gap.h16,
                    Text('Gagal memuat daftar kelas'),
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
                            .read(availableClassesControllerProvider(
                                    widget.semester)
                                .notifier)
                            .loadAvailableClasses();
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

  // Widget _buildSearchBar() {
  //   return TextField(
  //     decoration: InputDecoration(
  //       hintText: 'Cari mata kuliah...',
  //       prefixIcon: const Icon(Icons.search),
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(BaseSize.radiusMd),
  //       ),
  //       filled: true,
  //       fillColor: BaseColor.grey.shade100,
  //     ),
  //     onChanged: (value) {
  //       setState(() {
  //         _searchQuery = value.toLowerCase();
  //       });
  //     },
  //   );
  // }

  Widget _buildSelectedInfo(KrsModel krs) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w16),
      decoration: BoxDecoration(
        color: BaseColor.primaryInspire.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terpilih: ${krs.kelasPerkuliahan.length} mata kuliah',
                style: BaseTypography.bodyMedium.toBold,
              ),
              Gap.h4,
              Text(
                'Total SKS: ${krs.totalSKS}',
                style: BaseTypography.bodySmall,
              ),
            ],
          ),
          Icon(
            Icons.check_circle,
            color: BaseColor.primaryInspire,
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(List<KelasPerkuliahanModel> classes) {
    // Filter by search query
    final filteredClasses = classes.where((kelas) {
      final name = (kelas.mataKuliah?.name ?? kelas.nama).toLowerCase();
      final code = kelas.kode.toLowerCase();
      return name.contains(_searchQuery) || code.contains(_searchQuery);
    }).toList();

    if (filteredClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: BaseColor.grey),
            Gap.h16,
            Text(
              _searchQuery.isEmpty
                  ? 'Tidak ada kelas tersedia'
                  : 'Tidak ditemukan',
              style: BaseTypography.bodyLarge.toGrey,
            ),
          ],
        ),
      );
    }

    // Group by semester
    final grouped = <int, List<KelasPerkuliahanModel>>{};
    for (final kelas in filteredClasses) {
      final sem = kelas.mataKuliah?.semester ?? 0;
      grouped.putIfAbsent(sem, () => []);
      grouped[sem]!.add(kelas);
    }

    final sortedSemesters = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedSemesters.length,
      itemBuilder: (context, index) {
        final semester = sortedSemesters[index];
        final classes = grouped[semester]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w16,
                vertical: BaseSize.h8,
              ),
              child: Text(
                'Semester $semester',
                style: BaseTypography.titleSmall.toBold,
              ),
            ),
            ...classes.map((kelas) => _buildClassCard(kelas)),
            Gap.h12,
          ],
        );
      },
    );
  }

  Widget _buildClassCard(KelasPerkuliahanModel kelas) {
    final krsState = ref.watch(krsControllerProvider(widget.semester));
    final isSelected = krsState.maybeWhen(
      loaded: (krs) => krs.kelasPerkuliahan.any((k) => k.id == kelas.id),
      orElse: () => false,
    );

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h4,
      ),
      child: InkWell(
        onTap: isSelected
            ? null
            : () => _showAddConfirmation(kelas),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          '${kelas.kode} • ${kelas.mataKuliah?.sks ?? 0} SKS • Kelas ${kelas.nama}',
                          style: BaseTypography.bodySmall.toGrey,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                  else
                    Icon(
                      Icons.add_circle_outline,
                      color: BaseColor.primaryInspire,
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
      ),
    );
  }

  void _showAddConfirmation(KelasPerkuliahanModel kelas) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Mata Kuliah?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kelas.mataKuliah?.name ?? kelas.nama,
              style: BaseTypography.bodyMedium.toBold,
            ),
            Gap.h8,
            Text('Kode: ${kelas.kode}'),
            Text('SKS: ${kelas.mataKuliah?.sks ?? 0}'),
            Text('Kelas: ${kelas.nama}'),
            if (kelas.dosen != null) Text('Dosen: ${kelas.dosen!.name}'),
          ],
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
                  .addClass(kelas.id)
                  .then((_) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil menambahkan mata kuliah'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
