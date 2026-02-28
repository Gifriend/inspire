import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/endpoint/endpoint.dart';
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
      final data = await _dioClient.get(Endpoint.khs(semester));
      return KhsModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Download KHS as PDF bytes (with auth header via DioClient)
  Future<List<int>> downloadKhsPdf(String semester) async {
    try {
      final bytes = await _dioClient.get<List<int>>(
        Endpoint.khsDownload(semester),
        options: Options(responseType: ResponseType.bytes),
      );
      return bytes ?? [];
    } catch (e) {
      rethrow;
    }
  }
}

final khsRepositoryProvider = Provider<KhsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return KhsRepository(dioClient);
});
