import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/features/announcement/domain/services/announcement_service.dart';
import 'announcement_koorprodi_state.dart';

final announcementKoorprodiControllerProvider =
    StateNotifierProvider.autoDispose<AnnouncementKoorprodiController, AnnouncementKoorprodiState>(
  (ref) => AnnouncementKoorprodiController(ref),
);

class AnnouncementKoorprodiController extends StateNotifier<AnnouncementKoorprodiState> {
  AnnouncementKoorprodiController(this.ref)
      : super(const AnnouncementKoorprodiState.initial());

  final Ref ref;
  List<AnnouncementModel>? _cachedAnnouncements;

  Future<void> loadAnnouncements() async {
    if (_cachedAnnouncements != null) {
      state = AnnouncementKoorprodiState.loaded(_cachedAnnouncements!);
      return;
    }

    state = const AnnouncementKoorprodiState.loading();
    try {
      final announcements =
          await ref.watch(announcementServiceProvider).getCoordinatorAnnouncements();
      _cachedAnnouncements = announcements;
      state = AnnouncementKoorprodiState.loaded(announcements);
    } catch (e) {
      state = AnnouncementKoorprodiState.error(
          e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> createGlobalAnnouncement({
    required String judul,
    required String isi,
  }) async {
    state = const AnnouncementKoorprodiState.creating();
    try {
      final announcement = await ref
          .watch(announcementServiceProvider)
          .createGlobalAnnouncement(
            judul: judul,
            isi: isi,
          );
      state = AnnouncementKoorprodiState.created(announcement);
      // Clear cache to reload
      _cachedAnnouncements = null;
    } catch (e) {
      state = AnnouncementKoorprodiState.error(
          e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    state = const AnnouncementKoorprodiState.deleting();
    try {
      await ref.watch(announcementServiceProvider).deleteAnnouncement(id);
      state = const AnnouncementKoorprodiState.deleted();
      // Clear cache to reload
      _cachedAnnouncements = null;
    } catch (e) {
      state = AnnouncementKoorprodiState.error(
          e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearCache() {
    _cachedAnnouncements = null;
  }
}
