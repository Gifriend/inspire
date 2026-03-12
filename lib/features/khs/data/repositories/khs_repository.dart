import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/khs/khs_model.dart';

class KhsRepository {
  final DioClient _dioClient;

  KhsRepository(this._dioClient);

  // Get list of semesters
  Future<List<String>> getSemesters() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.khsSemesters,
      );

      if (response == null) {
        return [];
      }

      return ApiEnvelope.fromDynamic<List<String>>(
        response,
        dataParser: (data) {
          if (data is List) {
            return data.map((item) => item.toString()).toList();
          }
          return [];
        },
        defaultMessage: 'Gagal memuat daftar semester',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat daftar semester');
    }
  }

  // Get KHS by semester
  Future<KhsModel> getKhs(String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final url = Endpoint.khs(encoded);
      debugPrint('KHS get URL: $url');
      final response = await _dioClient.get<Map<String, dynamic>>(url);

      if (response == null) {
        throw const ApiException(message: 'Data KHS kosong');
      }

      return ApiEnvelope.fromDynamic<KhsModel>(
        response,
        dataParser: (data) => KhsModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat KHS',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat KHS');
    }
  }

  // Download KHS as PDF bytes (with auth header via DioClient)
  Future<List<int>> downloadKhsPdf(String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final url = Endpoint.khsDownload(encoded);
      debugPrint('KHS download URL: $url');
      final bytes = await _dioClient.downloadBytes(url);
      if (bytes.isEmpty) {
        throw Exception('File PDF kosong');
      }
      return bytes;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final khsRepositoryProvider = Provider<KhsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return KhsRepository(dioClient);
});
