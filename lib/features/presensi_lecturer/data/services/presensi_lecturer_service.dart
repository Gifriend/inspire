import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/features/elearning_lecturer/data/services/elearning_lecturer_service.dart';

abstract class PresensiLecturerService {
  Future<List<CourseListModel>> getLecturerCourses();
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId);
  Future<String> generateMeetingCode({
    required int kelasPerkuliahanId,
    required int meetingNumber,
  });
  Future<void> markManualAttendance({
    required int kelasPerkuliahanId,
    required int mahasiswaId,
    required int meetingNumber,
  });
}

class PresensiLecturerServiceImpl implements PresensiLecturerService {
  PresensiLecturerServiceImpl(this._dioClient, this._elearningLecturerService);

  final DioClient _dioClient;
  final ElearningLecturerService _elearningLecturerService;

  @override
  Future<List<CourseListModel>> getLecturerCourses() {
    return _elearningLecturerService.getLecturerCourses();
  }

  @override
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId) {
    return _elearningLecturerService.getCourseStudents(kelasId);
  }

  @override
  Future<String> generateMeetingCode({
    required int kelasPerkuliahanId,
    required int meetingNumber,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/presensi/lecturer/generate-code',
      data: {
        'kelasPerkuliahanId': kelasPerkuliahanId,
        'meetingNumber': meetingNumber,
      },
    );

    final code =
        response?['token']?.toString() ?? response?['code']?.toString();
    if (code == null || code.isEmpty) {
      throw Exception('Kode presensi tidak ditemukan pada response server');
    }

    return code;
  }

  @override
  Future<void> markManualAttendance({
    required int kelasPerkuliahanId,
    required int mahasiswaId,
    required int meetingNumber,
  }) async {
    await _dioClient.post<Map<String, dynamic>>(
      '/presensi/lecturer/manual',
      data: {
        'kelasPerkuliahanId': kelasPerkuliahanId,
        'mahasiswaId': mahasiswaId,
        'meetingNumber': meetingNumber,
      },
    );
  }
}

final presensiLecturerServiceProvider = Provider<PresensiLecturerService>((
  ref,
) {
  return PresensiLecturerServiceImpl(
    ref.watch(dioClientProvider),
    ref.watch(elearningLecturerServiceProvider),
  );
});
