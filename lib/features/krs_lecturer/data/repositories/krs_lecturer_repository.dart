import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/krs/krs_lecturer_model.dart';

class KrsLecturerRepository {
  final DioClient _dioClient;

  KrsLecturerRepository(this._dioClient);

  /// Fetch all KRS submissions for the logged-in dosen PA.
  /// Backend endpoint: GET /krs/submissions?status=...&academicYear=...
  Future<List<KrsSubmissionModel>> getSubmissions({
    String? status,
    String? academicYear,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (academicYear != null) queryParams['academicYear'] = academicYear;

      final data = await _dioClient.get(
        Endpoint.krsSubmissions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (data is List) {
        return data
            .map((json) =>
                KrsSubmissionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get single KRS detail with full kelas list.
  /// Backend endpoint: GET /krs/submissions/:krsId
  Future<KrsSubmissionModel> getSubmissionDetail(int krsId) async {
    try {
      final data = await _dioClient.get(
        Endpoint.krsSubmissionDetail(krsId),
      );

      return KrsSubmissionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Approve a KRS.
  /// Backend endpoint: POST /krs/approve/:krsId
  Future<KrsSubmissionModel> approveKrs(int krsId, {String? catatan}) async {
    try {
      final data = await _dioClient.post(
        Endpoint.krsApprove(krsId),
        data: {'catatan': catatan ?? 'Disetujui'},
      );

      return KrsSubmissionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Reject a KRS.
  /// Backend endpoint: POST /krs/reject/:krsId
  Future<KrsSubmissionModel> rejectKrs(int krsId,
      {required String catatan}) async {
    try {
      final data = await _dioClient.post(
        Endpoint.krsReject(krsId),
        data: {'catatan': catatan},
      );

      return KrsSubmissionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel an already-approved KRS (revert to DRAFT).
  /// Backend endpoint: POST /krs/cancel/:krsId
  Future<KrsSubmissionModel> cancelKrs(int krsId,
      {required String catatan}) async {
    try {
      final data = await _dioClient.post(
        Endpoint.krsCancel(krsId),
        data: {'catatan': catatan},
      );

      return KrsSubmissionModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}

final krsLecturerRepositoryProvider = Provider<KrsLecturerRepository>((ref) {
  return KrsLecturerRepository(ref.watch(dioClientProvider));
});
