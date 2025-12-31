import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/features/announcement/data/repositories/announcement_repository.dart';

abstract class AnnouncementService {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> getAnnouncementById(int id);
}

class AnnouncementServiceImpl implements AnnouncementService {
  final AnnouncementRepository _announcementRepository;

  AnnouncementServiceImpl(this._announcementRepository);

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      return await _announcementRepository.getAnnouncements();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnnouncementModel> getAnnouncementById(int id) async {
    try {
      return await _announcementRepository.getAnnouncementById(id);
    } catch (e) {
      rethrow;
    }
  }
}

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementServiceImpl(
    ref.watch(announcementRepositoryProvider),
  );
});
