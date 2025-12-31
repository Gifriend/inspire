import 'package:inspire/core/models/krs/krs_model.dart';
import 'package:inspire/features/krs/data/repositories/krs_repository.dart';

class KrsService {
  final KrsRepository _repository;

  KrsService(this._repository);

  // Get KRS by semester
  Future<KrsModel> getKrs(String semester) async {
    try {
      return await _repository.getKrs(semester);
    } catch (e) {
      throw Exception('Gagal memuat KRS: ${e.toString()}');
    }
  }

  // Add class to KRS
  Future<KrsModel> addClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      return await _repository.addClass(
        kelasId: kelasId,
        semester: semester,
      );
    } catch (e) {
      throw Exception('Gagal menambahkan kelas: ${e.toString()}');
    }
  }

  // Submit KRS for approval
  Future<KrsModel> submitKrs(String semester) async {
    try {
      return await _repository.submitKrs(semester);
    } catch (e) {
      throw Exception('Gagal mengajukan KRS: ${e.toString()}');
    }
  }

  // Remove class from KRS
  Future<KrsModel> removeClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      return await _repository.removeClass(
        kelasId: kelasId,
        semester: semester,
      );
    } catch (e) {
      throw Exception('Gagal menghapus kelas: ${e.toString()}');
    }
  }

  // Get available classes
  Future<List<KelasPerkuliahanModel>> getAvailableClasses({
    required String semester,
    int? prodiId,
  }) async {
    try {
      return await _repository.getAvailableClasses(
        semester: semester,
        prodiId: prodiId,
      );
    } catch (e) {
      throw Exception('Gagal memuat daftar kelas: ${e.toString()}');
    }
  }
}
