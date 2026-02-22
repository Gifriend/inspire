import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/assets/assets.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/elearning_lecturer/data/services/elearning_lecturer_service.dart';
import 'package:inspire/features/presentation.dart';

// Pastikan Anda sudah meng-import file dropdown_widget.dart di atas jika berada di folder berbeda

class AnnouncementLecturerScreen extends ConsumerStatefulWidget {
  const AnnouncementLecturerScreen({super.key});

  @override
  ConsumerState<AnnouncementLecturerScreen> createState() =>
      _AnnouncementLecturerScreenState();
}

class _AnnouncementLecturerScreenState
    extends ConsumerState<AnnouncementLecturerScreen> {
  List<CourseListModel> _lecturerCourses = const [];
  bool _isLoadingCourses = false;
  String? _coursesError;
  int? _selectedFilterKelasId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLecturerCourses();
      ref
          .read(announcementLecturerControllerProvider.notifier)
          .loadAnnouncements(kelasId: _selectedFilterKelasId);
    });
  }

  Future<void> _loadLecturerCourses() async {
    setState(() {
      _isLoadingCourses = true;
      _coursesError = null;
    });

    try {
      final courses = await ref
          .read(elearningLecturerServiceProvider)
          .getLecturerCourses();
      if (!mounted) {
        return;
      }

      setState(() {
        _lecturerCourses = courses;
        _isLoadingCourses = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCourses = false;
        _coursesError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementLecturerControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: 'Pengumuman Dosen',
        leadIcon: Assets.icons.fill.arrowBack,
        leadIconColor: BaseColor.white,
        onPressedLeadIcon: () => context.pop(),
      ),
      disableSingleChildScrollView: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateAnnouncementDialog(context);
        },
        tooltip: 'Buat Pengumuman',
        child: const Icon(Icons.add),
      ),
      child: state.maybeWhen(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 54),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(announcementLecturerControllerProvider.notifier)
                        .loadAnnouncements(kelasId: _selectedFilterKelasId);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        loaded: (announcements) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildClassFilter(),
              ),
              Expanded(
                child: announcements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.announcement_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pengumuman',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = announcements[index];
                          return _buildAnnouncementCard(announcement, context);
                        },
                      ),
              ),
            ],
          );
        },
        created: (announcement) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(announcementLecturerControllerProvider.notifier)
                .clearCache();
            ref
                .read(announcementLecturerControllerProvider.notifier)
                .loadAnnouncements(kelasId: _selectedFilterKelasId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengumuman berhasil dibuat'),
              backgroundColor: Colors.green,
            ),
          );

          return const SizedBox.shrink();
        },
        deleted: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(announcementLecturerControllerProvider.notifier)
                .clearCache();
            ref
                .read(announcementLecturerControllerProvider.notifier)
                .loadAnnouncements(kelasId: _selectedFilterKelasId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengumuman berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );

          return const SizedBox.shrink();
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildClassFilter() {
    if (_isLoadingCourses) {
      return const LinearProgressIndicator(minHeight: 2);
    }

    if (_coursesError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              _coursesError!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: _loadLecturerCourses,
            child: const Text('Muat Ulang Kelas'),
          ),
        ],
      );
    }

    return DropdownWidget<int?>(
      hintText: 'Riwayat Pengumuman Kelas',
      value: _selectedFilterKelasId,
      items: [null, ..._lecturerCourses.map((c) => c.id)],
      itemLabelBuilder: (id) {
        if (id == null) return 'Semua Kelas Saya';
        final course = _lecturerCourses.firstWhere((c) => c.id == id);
        return '${course.kode} - ${course.nama}';
      },
      onChanged: (value) {
        setState(() {
          _selectedFilterKelasId = value;
        });
        ref
            .read(announcementLecturerControllerProvider.notifier)
            .loadAnnouncements(kelasId: value);
      },
    );
  }

  Widget _buildAnnouncementCard(
    AnnouncementModel announcement,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (announcement.kelas != null &&
                          announcement.kelas!.isNotEmpty)
                        Text(
                          announcement.kelas!.map((k) => k.nama).join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (announcement.isGlobal)
                  Chip(
                    label: const Text('Global'),
                    backgroundColor: Colors.blue[100],
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.isi,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dibuat: ${_formatDate(announcement.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context, announcement.id);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    int? selectedKelasId;

    if (_lecturerCourses.isEmpty && !_isLoadingCourses) {
      _loadLecturerCourses();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Pengumuman'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Pengumuman',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan judul pengumuman',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Isi Pengumuman',
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan isi pengumuman',
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    DropdownWidget<int?>(
                      labelText: 'Riwayat Pengumuman Kelas',
                      hintText: 'Pilih Kelas',
                      value: selectedKelasId,
                      items: _lecturerCourses.map((c) => c.id).toList(),
                      itemLabelBuilder: (id) {
                        final course = _lecturerCourses.firstWhere((c) => c.id == id);
                        return '${course.kode} - ${course.nama}';
                      },
                      onChanged: (value) {
                        setDialogState(() {
                          selectedKelasId = value;
                        });
                      },
                    ),
                    if (_lecturerCourses.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Kelas belum tersedia. Silakan muat ulang kelas terlebih dahulu.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Judul dan isi harus diisi'),
                        ),
                      );
                      return;
                    }

                    if (selectedKelasId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Silakan pilih kelas terlebih dahulu'),
                        ),
                      );
                      return;
                    }

                    ref
                        .read(announcementLecturerControllerProvider.notifier)
                        .createAnnouncement(
                          judul: titleController.text,
                          isi: contentController.text,
                          kelasId: selectedKelasId!,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text('Buat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int announcementId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pengumuman?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pengumuman ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(announcementLecturerControllerProvider.notifier)
                    .deleteAnnouncement(announcementId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}