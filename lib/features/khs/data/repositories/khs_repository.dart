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

  // Get KHS download URL
  String getKhsDownloadUrl(String semester) {
    return Endpoint.khsDownload(semester);
  }


}

final khsRepositoryProvider = Provider<KhsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return KhsRepository(dioClient);
});
