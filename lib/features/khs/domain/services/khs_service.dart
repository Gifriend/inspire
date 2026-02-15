import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/features/khs/data/repositories/khs_repository.dart';

class KhsService {
  final KhsRepository _repository;

  KhsService(this._repository);

  // Get list of semesters
  Future<List<String>> getSemesters() async {
    try {
      return await _repository.getSemesters();
    } catch (e) {
      throw Exception('Gagal memuat daftar semester: ${e.toString()}');
    }
  }

  // Get KHS by semester
  Future<KhsModel> getKhs(String semester) async {
    try {
      return await _repository.getKhs(semester);
    } catch (e) {
      throw Exception('Gagal memuat KHS: ${e.toString()}');
    }
  }

  // Get KHS download URL
  String getKhsDownloadUrl(String semester) {
    return _repository.getKhsDownloadUrl(semester);
  }


}

final khsServiceProvider = Provider<KhsService>((ref) {
  final repository = ref.watch(khsRepositoryProvider);
  return KhsService(repository);
});
