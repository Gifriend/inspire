import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/academic/mahasiswa_bimbingan_model.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';

class LecturerAcademicRepository {
  final DioClient _dioClient;

  LecturerAcademicRepository(this._dioClient);

  // GET /academic/pa/mahasiswa — daftar mahasiswa bimbingan
  Future<List<MahasiswaBimbinganModel>> getMahasiswaBimbingan() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaMahasiswa,
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<MahasiswaBimbinganModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((e) => MahasiswaBimbinganModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat daftar mahasiswa bimbingan',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar mahasiswa bimbingan');
    }
  }

  // GET /academic/pa/mahasiswa/:id/semesters
  Future<List<String>> getSemestersByPA(int mahasiswaId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaStudentSemesters(mahasiswaId),
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<String>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data.map((item) => item.toString()).toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat daftar semester',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar semester');
    }
  }

  // GET /academic/pa/mahasiswa/:id/khs?semester=...
  Future<KhsModel> getKhsByPA(int mahasiswaId, String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaKhs(mahasiswaId, encoded),
      );
      if (response == null) {
        throw const ApiException(message: 'Data KHS kosong');
      }
      return ApiEnvelope.fromDynamic<KhsModel>(
        response,
        dataParser: (data) => KhsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat KHS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat KHS');
    }
  }

  // GET /academic/pa/mahasiswa/:id/khs/download?semester=...
  Future<List<int>> downloadKhsByPA(int mahasiswaId, String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final bytes = await _dioClient.downloadBytes(
        Endpoint.academicPaKhsDownload(mahasiswaId, encoded),
      );
      if (bytes.isEmpty) throw Exception('File PDF kosong');
      return bytes;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // GET /academic/pa/mahasiswa/:id/transkrip
  Future<TranscriptModel> getTranskripByPA(int mahasiswaId) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaTranskrip(mahasiswaId),
      );
      if (response == null) {
        throw const ApiException(message: 'Data transkrip kosong');
      }
      return ApiEnvelope.fromDynamic<TranscriptModel>(
        response,
        dataParser: (data) => TranscriptModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat transkrip',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat transkrip');
    }
  }

  // GET /academic/pa/mahasiswa/:id/transkrip/download
  Future<List<int>> downloadTranskripByPA(int mahasiswaId) async {
    try {
      final bytes = await _dioClient.downloadBytes(
        Endpoint.academicPaTranskripDownload(mahasiswaId),
      );
      if (bytes.isEmpty) throw Exception('File PDF kosong');
      return bytes;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final lecturerAcademicRepositoryProvider =
    Provider<LecturerAcademicRepository>((ref) {
  return LecturerAcademicRepository(ref.watch(dioClientProvider));
});
