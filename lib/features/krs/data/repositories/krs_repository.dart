import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/krs/krs_model.dart';

class KrsRepository {
  final DioClient _dioClient;

  KrsRepository(this._dioClient);

  // Get KRS by semester
  Future<KrsModel> getKrs(String semester) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.krs(semester),
      );
      if (response == null) {
        throw const ApiException(message: 'Data KRS kosong');
      }
      return ApiEnvelope.fromDynamic<KrsModel>(
        response,
        dataParser: (data) => KrsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat KRS');
    }
  }

  // Add class to KRS
  Future<KrsModel> addClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsAddClass,
        data: {
          'kelasId': kelasId,
          'semester': semester,
        },
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsModel>(
        response,
        dataParser: (data) => KrsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menambahkan kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menambahkan kelas');
    }
  }

  // Submit KRS for approval
  Future<KrsModel> submitKrs(String semester) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsSubmit,
        data: {
          'semester': semester,
        },
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsModel>(
        response,
        dataParser: (data) => KrsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal mengajukan KRS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal mengajukan KRS');
    }
  }

  // Remove class from KRS
  Future<KrsModel> removeClass({
    required int kelasId,
    required String semester,
  }) async {
    try {
      final response = await _dioClient.post<dynamic>(
        Endpoint.krsRemoveClass,
        data: {
          'kelasId': kelasId,
          'semester': semester,
        },
      );
      if (response == null) {
        throw const ApiException(message: 'Respons kosong');
      }
      return ApiEnvelope.fromDynamic<KrsModel>(
        response,
        dataParser: (data) => KrsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal menghapus kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal menghapus kelas');
    }
  }

  // Get available classes for selection
  Future<List<KelasPerkuliahanModel>> getAvailableClasses({
    required String academicYear,
    int? prodiId,
  }) async {
    try {
      final response = await _dioClient.get<dynamic>(
        Endpoint.krsLoadAvailableCourses(academicYear),
        // queryParameters: {
        //   'semester': semester,
        //   if (prodiId != null) 'prodiId': prodiId,
        // },
      );
      if (response == null) return [];
      return ApiEnvelope.fromDynamic<List<KelasPerkuliahanModel>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data
                .map((json) => KelasPerkuliahanModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat daftar kelas',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar kelas');
    }
  }
}

final krsRepositoryProvider = Provider<KrsRepository>((ref) {
  return KrsRepository(ref.watch(dioClientProvider));
});
