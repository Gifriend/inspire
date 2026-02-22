import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/models.dart';

abstract class PresensiLecturerService {
  Future<List<CourseListModel>> getLecturerCourses();
  
  /// Fetches all sessions for a specific course
  Future<List<Map<String, dynamic>>> getCourseSessions(int kelasId);
  
  /// Fetches students, including their attendance status if sessionId is provided
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId, {int? sessionId});
  
  Future<({int id, String token})> generateSession({
    required int kelasPerkuliahanId,
    required String title,
    String? deadlineDate, // Format: YYYY-MM-DD
    String? deadlineTime, // Format: HH:mm
  });
  
  Future<void> markManualAttendance({
    required int sessionId,
    required int mahasiswaId,
  });

  /// Revokes an existing attendance record
  Future<void> revokeAttendance({
    required int sessionId,
    required int mahasiswaId,
  });
}

class PresensiLecturerServiceImpl implements PresensiLecturerService {
  PresensiLecturerServiceImpl(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<List<CourseListModel>> getLecturerCourses() async {
    try {
      final response = await _dioClient.get<List>('/elearning/lecturer/courses');
      if (response == null) return [];
      
      return response
          .map((item) => CourseListModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading lecturer courses: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseSessions(int kelasId) async {
    try {
      final response = await _dioClient.get<List>('/presensi/kelas/$kelasId/sessions');
      if (response == null) return [];
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error loading sessions: $e');
    }
  }

  @override
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId, {int? sessionId}) async {
    try {
      final query = sessionId != null ? '?sessionId=$sessionId' : '';
      final response = await _dioClient.get<List>('/presensi/kelas/$kelasId/mahasiswa$query');
      
      if (response == null) return [];
      
      return response
          .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error loading course students: $e');
    }
  }

  @override
  Future<({int id, String token})> generateSession({
    required int kelasPerkuliahanId,
    required String title,
    String? deadlineDate, // Format: YYYY-MM-DD
    String? deadlineTime, // Format: HH:mm
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'type': 'KELAS',
      'kelasPerkuliahanId': kelasPerkuliahanId,
    };

    // Masukkan deadline jika diisi
    if (deadlineDate != null && deadlineTime != null) {
      data['deadlineDate'] = deadlineDate;
      data['deadlineTime'] = deadlineTime;
    }

    final response = await _dioClient.post<Map<String, dynamic>>(
      '/presensi/session',
      data: data,
    );

    final id = response?['id'] as int?;
    final token = response?['token']?.toString();

    if (id == null || token == null || token.isEmpty) {
      throw Exception('Session ID atau token presensi tidak ditemukan');
    }

    return (id: id, token: token);
  }

  @override
  Future<void> markManualAttendance({
    required int sessionId,
    required int mahasiswaId,
  }) async {
    await _dioClient.post<Map<String, dynamic>>(
      '/presensi/manual',
      data: {
        'sessionId': sessionId,
        'mahasiswaId': mahasiswaId,
        'status': 'HADIR',
      },
    );
  }

  @override
  Future<void> revokeAttendance({
    required int sessionId,
    required int mahasiswaId,
  }) async {
    await _dioClient.delete<Map<String, dynamic>>(
      '/presensi/session/$sessionId/mahasiswa/$mahasiswaId',
    );
  }
}

final presensiLecturerServiceProvider = Provider<PresensiLecturerService>((ref) {
  return PresensiLecturerServiceImpl(ref.watch(dioClientProvider));
});