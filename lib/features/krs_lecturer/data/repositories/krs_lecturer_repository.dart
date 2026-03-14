import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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

      final response = await _dioClient.get<dynamic>(
        Endpoint.krsSubmissions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<KrsSubmissionModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((json) =>
                    KrsSubmissionModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat daftar KRS mahasiswa',
      ).data;
    } catch (e) {
      throw ApiException.from(e,
          fallbackMessage: 'Gagal memuat daftar KRS mahasiswa');
    }
  }

  /// Get single KRS detail with full kelas list.
  /// Backend endpoint: GET /krs/submissions/:krsId
  Future<KrsSubmissionModel> getSubmissionDetail(int krsId) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.krsSubmissionDetail(krsId),
      );
      if (response == null) {
        throw const ApiException(message: 'Data KRS tidak ditemukan');
      }
      return ApiEnvelope.fromDynamic<KrsSubmissionModel>(
        response,
        dataParser: (data) =>
            KrsSubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat detail KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat detail KRS');
    }
  }

  /// Approve a KRS.
  /// Backend endpoint: POST /krs/approve/:krsId
  Future<KrsSubmissionModel> approveKrs(int krsId, {String? catatan}) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsApprove(krsId),
        data: {'catatan': catatan ?? 'Disetujui'},
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsSubmissionModel>(
        response,
        dataParser: (data) =>
            KrsSubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menyetujui KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menyetujui KRS');
    }
  }

  /// Reject a KRS.
  /// Backend endpoint: POST /krs/reject/:krsId
  Future<KrsSubmissionModel> rejectKrs(int krsId,
      {required String catatan}) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsReject(krsId),
        data: {'catatan': catatan},
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsSubmissionModel>(
        response,
        dataParser: (data) =>
            KrsSubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menolak KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menolak KRS');
    }
  }

  /// Cancel an already-approved KRS (revert to DRAFT).
  /// Backend endpoint: POST /krs/cancel/:krsId
  Future<KrsSubmissionModel> cancelKrs(int krsId,
      {required String catatan}) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsCancel(krsId),
        data: {'catatan': catatan},
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsSubmissionModel>(
        response,
        dataParser: (data) =>
            KrsSubmissionModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal membatalkan KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal membatalkan KRS');
    }
  }
}

final krsLecturerRepositoryProvider = Provider<KrsLecturerRepository>((ref) {
  return KrsLecturerRepository(ref.watch(dioClientProvider));
});
