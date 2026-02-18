import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/features/announcement/domain/services/announcement_service.dart';
import 'announcement_lecturer_state.dart';

final announcementLecturerControllerProvider =
    StateNotifierProvider.autoDispose<
      AnnouncementLecturerController,
      AnnouncementLecturerState
    >((ref) => AnnouncementLecturerController(ref));

class AnnouncementLecturerController
    extends StateNotifier<AnnouncementLecturerState> {
  AnnouncementLecturerController(this.ref)
    : super(const AnnouncementLecturerState.initial());

  final Ref ref;
  final Map<int?, List<AnnouncementModel>> _cachedAnnouncementsByClass = {};

  Future<void> loadAnnouncements({int? kelasId}) async {
    if (_cachedAnnouncementsByClass.containsKey(kelasId)) {
      state = AnnouncementLecturerState.loaded(
        _cachedAnnouncementsByClass[kelasId]!,
      );
      return;
    }

    state = const AnnouncementLecturerState.loading();
    try {
      final announcements = await ref
          .watch(announcementServiceProvider)
          .getLecturerAnnouncements(kelasId: kelasId);
      _cachedAnnouncementsByClass[kelasId] = announcements;
      state = AnnouncementLecturerState.loaded(announcements);
    } catch (e) {
      state = AnnouncementLecturerState.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> createAnnouncement({
    required String judul,
    required String isi,
    required int kelasId,
  }) async {
    state = const AnnouncementLecturerState.creating();
    try {
      final announcement = await ref
          .watch(announcementServiceProvider)
          .createClassAnnouncement(judul: judul, isi: isi, kelasId: kelasId);
      state = AnnouncementLecturerState.created(announcement);
      // Clear cache to reload
      _cachedAnnouncementsByClass.clear();
    } catch (e) {
      state = AnnouncementLecturerState.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    state = const AnnouncementLecturerState.deleting();
    try {
      await ref.watch(announcementServiceProvider).deleteAnnouncement(id);
      state = const AnnouncementLecturerState.deleted();
      // Clear cache to reload
      _cachedAnnouncementsByClass.clear();
    } catch (e) {
      state = AnnouncementLecturerState.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearCache() {
    _cachedAnnouncementsByClass.clear();
  }
}
