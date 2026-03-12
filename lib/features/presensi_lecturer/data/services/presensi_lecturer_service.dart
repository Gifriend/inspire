import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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
    String type = 'KELAS',
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
    final raw = await _dioClient.get<dynamic>(Endpoint.lecturerCourses);
    return ApiEnvelope.fromDynamic<List<CourseListModel>>(
      raw,
      dataParser: (data) {
        if (data == null) {
          return const [];
        }
        if (data is! List) {
          throw const FormatException('Invalid response data format');
        }
        return data
            .map((item) => CourseListModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    ).data;
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseSessions(int kelasId) async {
    final raw = await _dioClient.get<dynamic>(
      Endpoint.presensiKelasSessions(kelasId),
    );
    return ApiEnvelope.fromDynamic<List<Map<String, dynamic>>>(
      raw,
      dataParser: (data) {
        if (data == null) {
          return const [];
        }
        if (data is! List) {
          throw const FormatException('Invalid response data format');
        }
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      },
    ).data;
  }

  @override
  Future<List<StudentInfoModel>> getCourseStudents(int kelasId, {int? sessionId}) async {
    final raw = await _dioClient.get<dynamic>(
      Endpoint.presensiClassStudents(kelasId, sessionId: sessionId),
    );

    return ApiEnvelope.fromDynamic<List<StudentInfoModel>>(
      raw,
      dataParser: (data) {
        if (data == null) {
          return const [];
        }
        if (data is! List) {
          throw const FormatException('Invalid response data format');
        }
        return data
            .map((item) => StudentInfoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    ).data;
  }

  @override
  Future<({int id, String token})> generateSession({
    required int kelasPerkuliahanId,
    required String title,
    String type = 'KELAS',
    String? deadlineDate, // Format: YYYY-MM-DD
    String? deadlineTime, // Format: HH:mm
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'type': type,
      'kelasPerkuliahanId': kelasPerkuliahanId,
    };

    // Masukkan deadline jika diisi
    if (deadlineDate != null && deadlineTime != null) {
      data['deadlineDate'] = deadlineDate;
      data['deadlineTime'] = deadlineTime;
    }

    final raw = await _dioClient.post<dynamic>(
      Endpoint.presensiCreateSession,
      data: data,
    );

    final response = ApiEnvelope.fromDynamic<Map<String, dynamic>>(
      raw,
      dataParser: ApiEnvelope.parseSingleMap,
    ).data;

    final id = response['id'] as int?;
    final token = response['token']?.toString();

    if (id == null || token == null || token.isEmpty) {
      throw Exception('Kode presensi tidak ditemukan');
    }

    return (id: id, token: token);
  }

  @override
  Future<void> markManualAttendance({
    required int sessionId,
    required int mahasiswaId,
  }) async {
    final raw = await _dioClient.post<dynamic>(
      '${Endpoint.presensi}/manual',
      data: {
        'sessionId': sessionId,
        'mahasiswaId': mahasiswaId,
        'status': 'HADIR',
      },
    );

    ApiEnvelope.fromDynamic<Object?>(
      raw,
      dataParser: (data) => data,
    );
  }

  @override
  Future<void> revokeAttendance({
    required int sessionId,
    required int mahasiswaId,
  }) async {
    final raw = await _dioClient.delete<dynamic>(
      Endpoint.presensiRevokeAttendance(sessionId, mahasiswaId),
    );

    ApiEnvelope.fromDynamic<Object?>(
      raw,
      dataParser: (data) => data,
    );
  }
}

final presensiLecturerServiceProvider = Provider<PresensiLecturerService>((ref) {
  return PresensiLecturerServiceImpl(ref.watch(dioClientProvider));
});