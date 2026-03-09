import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/models.dart';

class PresensiRepository {
  final DioClient _dioClient;

  PresensiRepository(this._dioClient);

  Future<PresensiRecordModel> submitPresensi(
    SubmitPresensiRequestModel request,
  ) async {
    try {
      final data = await _dioClient.post(
        Endpoint.presensiSubmit,
        data: request.toJson(),
      );

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return PresensiRecordModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PresensiSessionModel> createSession(
    CreatePresensiRequestModel request,
  ) async {
    try {
      final data = await _dioClient.post(
        Endpoint.presensiCreateSession,
        data: request.toJson(),
      );

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response format');
      }

      return PresensiSessionModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
