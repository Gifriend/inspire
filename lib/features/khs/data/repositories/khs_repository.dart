import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/config/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/khs/khs_model.dart';

class KhsRepository {
  final DioClient _dioClient;

  KhsRepository(this._dioClient);

  // Get list of semesters
  Future<List<String>> getSemesters() async {
    try {
      final data = await _dioClient.get(Endpoint.khsSemesters);
      return List<String>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get KHS by semester
  Future<KhsModel> getKhs(String semester) async {
    try {
      final encoded = Uri.encodeComponent(semester);
      final url = Endpoint.khs(encoded);
      debugPrint('KHS get URL: $url');
      final data = await _dioClient.get(url);
      return KhsModel.fromJson(data);
    } catch (e) {
      rethrow;
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
      rethrow;
    }
  }
}

final khsRepositoryProvider = Provider<KhsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return KhsRepository(dioClient);
});
