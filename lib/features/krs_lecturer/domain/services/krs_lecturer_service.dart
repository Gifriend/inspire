import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/krs/krs_lecturer_model.dart';
import 'package:inspire/features/krs_lecturer/data/repositories/krs_lecturer_repository.dart';

class KrsLecturerService {
  final KrsLecturerRepository _repository;

  KrsLecturerService(this._repository);

  Future<List<KrsSubmissionModel>> getSubmissions({
    String? status,
    String? academicYear,
  }) async {
    try {
      return await _repository.getSubmissions(
        status: status,
        academicYear: academicYear,
      );
    } catch (e) {
      throw Exception('Gagal memuat daftar KRS mahasiswa: ${e.toString()}');
    }
  }

  Future<KrsSubmissionModel> getSubmissionDetail(int krsId) async {
    try {
      return await _repository.getSubmissionDetail(krsId);
    } catch (e) {
      throw Exception('Gagal memuat detail KRS: ${e.toString()}');
    }
  }

  Future<KrsSubmissionModel> approveKrs(int krsId, {String? catatan}) async {
    try {
      return await _repository.approveKrs(krsId, catatan: catatan);
    } catch (e) {
      throw Exception('Gagal menyetujui KRS: ${e.toString()}');
    }
  }

  Future<KrsSubmissionModel> rejectKrs(int krsId,
      {required String catatan}) async {
    try {
      return await _repository.rejectKrs(krsId, catatan: catatan);
    } catch (e) {
      throw Exception('Gagal menolak KRS: ${e.toString()}');
    }
  }

  Future<KrsSubmissionModel> cancelKrs(int krsId,
      {required String catatan}) async {
    try {
      return await _repository.cancelKrs(krsId, catatan: catatan);
    } catch (e) {
      throw Exception('Gagal membatalkan KRS: ${e.toString()}');
    }
  }
}

final krsLecturerServiceProvider = Provider<KrsLecturerService>((ref) {
  return KrsLecturerService(ref.watch(krsLecturerRepositoryProvider));
});
