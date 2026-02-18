import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';
import 'package:inspire/features/announcement/data/repositories/announcement_repository.dart';

abstract class AnnouncementService {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<AnnouncementModel> getAnnouncementById(int id);
  Future<AnnouncementModel> createClassAnnouncement({
    required String judul,
    required String isi,
    required int kelasId,
  });
  Future<AnnouncementModel> createGlobalAnnouncement({
    required String judul,
    required String isi,
  });
  Future<List<AnnouncementModel>> getCoordinatorAnnouncements();
  Future<List<AnnouncementModel>> getLecturerAnnouncements({int? kelasId});
  Future<void> deleteAnnouncement(int id);
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

  @override
  Future<AnnouncementModel> createClassAnnouncement({
    required String judul,
    required String isi,
    required int kelasId,
  }) async {
    try {
      return await _announcementRepository.createClassAnnouncement(
        judul: judul,
        isi: isi,
        kelasId: kelasId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AnnouncementModel> createGlobalAnnouncement({
    required String judul,
    required String isi,
  }) async {
    try {
      return await _announcementRepository.createGlobalAnnouncement(
        judul: judul,
        isi: isi,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AnnouncementModel>> getCoordinatorAnnouncements() async {
    try {
      return await _announcementRepository.getCoordinatorAnnouncements();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AnnouncementModel>> getLecturerAnnouncements({
    int? kelasId,
  }) async {
    try {
      return await _announcementRepository.getLecturerAnnouncements(
        kelasId: kelasId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAnnouncement(int id) async {
    try {
      return await _announcementRepository.deleteAnnouncement(id);
    } catch (e) {
      rethrow;
    }
  }
}

final announcementServiceProvider = Provider<AnnouncementService>((ref) {
  return AnnouncementServiceImpl(ref.watch(announcementRepositoryProvider));
});
