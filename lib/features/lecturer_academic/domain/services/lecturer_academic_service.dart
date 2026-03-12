import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/academic/mahasiswa_bimbingan_model.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';
import 'package:inspire/features/lecturer_academic/data/repositories/lecturer_academic_repository.dart';

class LecturerAcademicService {
  final LecturerAcademicRepository _repository;

  LecturerAcademicService(this._repository);

  Future<List<MahasiswaBimbinganModel>> getMahasiswaBimbingan() async {
    try {
      return await _repository.getMahasiswaBimbingan();
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar mahasiswa bimbingan');
    }
  }

  Future<List<String>> getSemestersByPA(int mahasiswaId) async {
    try {
      return await _repository.getSemestersByPA(mahasiswaId);
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat semester');
    }
  }

  Future<KhsModel> getKhsByPA(int mahasiswaId, String semester) async {
    try {
      return await _repository.getKhsByPA(mahasiswaId, semester);
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat KHS');
    }
  }

  Future<List<int>> downloadKhsByPA(int mahasiswaId, String semester) async {
    try {
      return await _repository.downloadKhsByPA(mahasiswaId, semester);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<TranscriptModel> getTranskripByPA(int mahasiswaId) async {
    try {
      return await _repository.getTranskripByPA(mahasiswaId);
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat transkrip');
    }
  }

  Future<List<int>> downloadTranskripByPA(int mahasiswaId) async {
    try {
      return await _repository.downloadTranskripByPA(mahasiswaId);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final lecturerAcademicServiceProvider =
    Provider<LecturerAcademicService>((ref) {
  return LecturerAcademicService(
      ref.watch(lecturerAcademicRepositoryProvider));
});
