import 'package:inspire/core/constants/endpoint/endpoint.dart';
import 'package:inspire/core/models/krs/krs_model.dart';

import '../../../../core/data_sources/network/dio_client.dart';

class KrsRepository {
  final DioClient _dioClient;

  KrsRepository(this._dioClient);

  // Get KRS by semester
  Future<KrsModel> getKrs(String semester) async {
    try {
      final data = await _dioClient.get(
        Endpoint.krs(semester),
      );

      return KrsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Add class to KRS
  Future<KrsModel> addClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      final data = await _dioClient.post(
        Endpoint.krsAddClass,
        data: {
          'kelasId': kelasId,
          'semester': semester,
        },
      );

      return KrsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Submit KRS for approval
  Future<KrsModel> submitKrs(String semester) async {
    try {
      final data = await _dioClient.post(
        Endpoint.krsSubmit,
        data: {
          'semester': semester,
        },
      );

      return KrsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Remove class from KRS (if backend supports it)
  Future<KrsModel> removeClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      final data = await _dioClient.post(
        '${Endpoint.krsAddClass}/remove', // Adjust endpoint if different
        data: {
          'kelasId': kelasId,
          'semester': semester,
        },
      );

      return KrsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get available classes for selection
  Future<List<KelasPerkuliahanModel>> getAvailableClasses({
    required String semester,
    int? prodiId,
  }) async {
    try {
      final data = await _dioClient.get(
        Endpoint.availableClasses,
        queryParameters: {
          'semester': semester,
          if (prodiId != null) 'prodiId': prodiId,
        },
      );

      if (data is List) {
        return data
            .map((json) => KelasPerkuliahanModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      rethrow;
    }
  }
}
