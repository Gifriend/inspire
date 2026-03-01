import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/core/widgets/widgets.dart';
import 'package:inspire/features/presentation.dart';

import '../../../core/constants/constants.dart';

class AnnouncementKoorprodiScreen extends ConsumerStatefulWidget {
  const AnnouncementKoorprodiScreen({super.key});

  @override
  ConsumerState<AnnouncementKoorprodiScreen> createState() =>
      _AnnouncementKoorprodiScreenState();
}

class _AnnouncementKoorprodiScreenState
    extends ConsumerState<AnnouncementKoorprodiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(announcementKoorprodiControllerProvider.notifier)
          .loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementKoorprodiControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(title: 'Pengumuman Program Studi', leadIcon: null),
      disableSingleChildScrollView: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGlobalAnnouncementDialog(context);
        },
        tooltip: 'Buat Pengumuman Global',
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
                Gap.h12,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                Gap.h12,
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(announcementKoorprodiControllerProvider.notifier)
                        .loadAnnouncements();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        loaded: (announcements) {
          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.announcement_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  Gap.h16,
                  Text(
                    'Belum ada pengumuman',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return _buildAnnouncementCard(announcement, context);
            },
          );
        },
        created: (announcement) {
          // Reload announcements after creation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(announcementKoorprodiControllerProvider.notifier)
                .clearCache();
            ref
                .read(announcementKoorprodiControllerProvider.notifier)
                .loadAnnouncements();
          });

          showSuccessAlertDialogWidget(
            context,
            title: 'Pengumuman berhasil dibuat',
          );

          return const SizedBox.shrink();
        },
        deleted: () {
          // Reload announcements after deletion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(announcementKoorprodiControllerProvider.notifier)
                .clearCache();
            ref
                .read(announcementKoorprodiControllerProvider.notifier)
                .loadAnnouncements();
          });

          showSuccessAlertDialogWidget(
            context,
            title: 'Pengumuman berhasil dihapus',
          );

          return const SizedBox.shrink();
        },
        orElse: () => const SizedBox.shrink(),
      ),
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
                      if (announcement.kelas != null &&
                          announcement.kelas!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            announcement.kelas!.map((k) => k.nama).join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(announcement.isGlobal ? 'Global' : 'Per Kelas'),
                  backgroundColor: announcement.isGlobal
                      ? Colors.green[100]
                      : Colors.blue[100],
                  labelStyle: TextStyle(
                    color: announcement.isGlobal ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            Gap.h8,
            if (announcement.dosen != null)
              Text(
                'Oleh: ${announcement.dosen!.name}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Gap.h12,
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
            Gap.h12,
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

  void _showCreateGlobalAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialogCustomWidget<void>(
      context: context,
      title: 'Buat Pengumuman Global',
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
            Gap.h16,
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Pengumuman',
                border: OutlineInputBorder(),
                hintText: 'Masukkan isi pengumuman',
                helperText:
                    'Pengumuman ini akan dilihat oleh semua mahasiswa Informatika',
              ),
              maxLines: 5,
            ),
            Gap.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
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

                    ref
                        .read(announcementKoorprodiControllerProvider.notifier)
                        .createGlobalAnnouncement(
                          judul: titleController.text,
                          isi: contentController.text,
                        );

                    Navigator.pop(context);
                  },
                  child: const Text('Buat'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int announcementId) {
    showDialogCustomWidget<void>(
      context: context,
      title: 'Hapus Pengumuman?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
          Gap.h12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(announcementKoorprodiControllerProvider.notifier)
                      .deleteAnnouncement(announcementId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
