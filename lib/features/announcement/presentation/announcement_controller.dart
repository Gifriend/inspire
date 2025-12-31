import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/features/announcement/domain/services/announcement_service.dart';
import 'package:inspire/features/announcement/presentation/announcement_state.dart';

final announcementControllerProvider =
    StateNotifierProvider.autoDispose<AnnouncementController, AnnouncementState>(
  (ref) => AnnouncementController(ref),
);

class AnnouncementController extends StateNotifier<AnnouncementState> {
  AnnouncementController(this.ref) : super(const AnnouncementState.initial());

  final Ref ref;
  List<AnnouncementModel>? _cachedAnnouncements;

  Future<void> loadAnnouncements() async {
    if (_cachedAnnouncements != null) {
      state = AnnouncementState.loaded(_cachedAnnouncements!);
      return;
    }

    state = const AnnouncementState.loading();
    try {
      final announcements = await ref.watch(announcementServiceProvider).getAnnouncements();
      _cachedAnnouncements = announcements;
      state = AnnouncementState.loaded(announcements);
    } catch (e) {
      state = AnnouncementState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearCache() {
    _cachedAnnouncements = null;
  }
}

final announcementDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<AnnouncementDetailController, AnnouncementDetailState, int>(
  (ref, id) => AnnouncementDetailController(ref, id),
);

class AnnouncementDetailController extends StateNotifier<AnnouncementDetailState> {
  AnnouncementDetailController(this.ref, this.announcementId)
      : super(const AnnouncementDetailState.initial());

  final Ref ref;
  final int announcementId;

  Future<void> loadAnnouncementDetail() async {
    state = const AnnouncementDetailState.loading();
    try {
      final announcement = await ref
          .watch(announcementServiceProvider)
          .getAnnouncementById(announcementId);
      state = AnnouncementDetailState.loaded(announcement);
    } catch (e) {
      state = AnnouncementDetailState.error(
          e.toString().replaceAll('Exception: ', ''));
    }
  }
}
