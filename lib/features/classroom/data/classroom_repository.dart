import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/endpoint/endpoint.dart';
import 'package:inspire/core/models/classroom/classroom_models.dart';

/// Repository yang memanggil backend /api/classroom/...
/// menggunakan Google Access Token sebagai Bearer di header Authorization.
class ClassroomRepository {
  final Dio _dio;

  ClassroomRepository(this._dio);

  Options _authOptions(String googleAccessToken) => Options(
        headers: {'Authorization': 'Bearer $googleAccessToken'},
      );

  /// Mengambil daftar kelas aktif dari Google Classroom milik user.
  Future<List<ClassroomCourse>> getCourses(String googleAccessToken) async {
    try {
      final response = await _dio.get<dynamic>(
        Endpoint.classroomCourses,
        options: _authOptions(googleAccessToken),
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ClassroomCourse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'Gagal memuat daftar kelas');
    }
  }

  /// Mengambil daftar tugas/materi dari kelas tertentu.
  Future<List<ClassroomCourseWork>> getCourseWork(
    String googleAccessToken,
    String courseId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        Endpoint.classroomCourseWork(courseId),
        options: _authOptions(googleAccessToken),
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) =>
                ClassroomCourseWork.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'Gagal memuat tugas kelas');
    }
  }

  /// Mengambil daftar mahasiswa di kelas tertentu (untuk dosen).
  Future<List<ClassroomStudent>> getStudents(
    String googleAccessToken,
    String courseId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        Endpoint.classroomStudents(courseId),
        options: _authOptions(googleAccessToken),
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) =>
                ClassroomStudent.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e, 'Gagal memuat daftar mahasiswa');
    }
  }

  Exception _handleDioError(DioException e, String fallback) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return Exception('Sesi Google Anda telah berakhir. Silakan login ulang.');
    }
    final message =
        e.response?.data?['message'] as String? ?? e.message ?? fallback;
    return Exception(message);
  }
}

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  return ClassroomRepository(dio);
});
