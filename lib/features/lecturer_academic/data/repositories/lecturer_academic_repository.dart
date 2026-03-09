import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/academic/mahasiswa_bimbingan_model.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';

class LecturerAcademicRepository {
  final DioClient _dioClient;

  LecturerAcademicRepository(this._dioClient);

  // GET /academic/pa/mahasiswa — daftar mahasiswa bimbingan
  Future<List<MahasiswaBimbinganModel>> getMahasiswaBimbingan() async {
    try {
      final data = await _dioClient.get<List<dynamic>>(
        Endpoint.academicPaMahasiswa,
      );
      if (data == null) return [];
      return data
          .map((e) => MahasiswaBimbinganModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat daftar mahasiswa bimbingan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /academic/pa/mahasiswa/:id/semesters
  Future<List<String>> getSemestersByPA(int mahasiswaId) async {
    try {
      final data = await _dioClient.get<List<dynamic>>(
        Endpoint.academicPaStudentSemesters(mahasiswaId),
      );
      if (data == null) return [];
      return List<String>.from(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat daftar semester');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /academic/pa/mahasiswa/:id/khs?semester=...
  Future<KhsModel> getKhsByPA(int mahasiswaId, String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final data = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaKhs(mahasiswaId, encoded),
      );
      if (data == null) throw Exception('Data KHS kosong');
      return KhsModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat KHS');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengunduh KHS PDF');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // GET /academic/pa/mahasiswa/:id/transkrip
  Future<TranscriptModel> getTranskripByPA(int mahasiswaId) async {
    try {
      final data = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.academicPaTranskrip(mahasiswaId),
      );
      if (data == null) throw Exception('Data transkrip kosong');
      return TranscriptModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat transkrip');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengunduh transkrip PDF');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final lecturerAcademicRepositoryProvider =
    Provider<LecturerAcademicRepository>((ref) {
  return LecturerAcademicRepository(ref.watch(dioClientProvider));
});
