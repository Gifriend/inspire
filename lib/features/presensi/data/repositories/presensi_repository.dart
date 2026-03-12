import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/models.dart';

class PresensiRepository {
  final DioClient _dioClient;

  PresensiRepository(this._dioClient);

  Future<ApiEnvelope<PresensiRecordModel>> submitPresensi(
    SubmitPresensiRequestModel request,
  ) async {
    final raw = await _dioClient.post<dynamic>(
      Endpoint.presensiSubmit,
      data: request.toJson(),
    );

    return ApiEnvelope.fromDynamic<PresensiRecordModel>(
      raw,
      dataParser: (data) => PresensiRecordModel.fromJson(
        ApiEnvelope.parseSingleMap(data),
      ),
    );
  }

  Future<ApiEnvelope<PresensiSessionModel>> createSession(
    CreatePresensiRequestModel request,
  ) async {
    final raw = await _dioClient.post<dynamic>(
      Endpoint.presensiCreateSession,
      data: request.toJson(),
    );

    return ApiEnvelope.fromDynamic<PresensiSessionModel>(
      raw,
      dataParser: (data) => PresensiSessionModel.fromJson(
        ApiEnvelope.parseSingleMap(data),
      ),
    );
  }
}
