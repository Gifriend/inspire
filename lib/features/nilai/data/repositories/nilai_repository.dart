import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/endpoint/endpoint.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';

class NilaiRepository {
  final DioClient _dioClient;

  NilaiRepository(this._dioClient);

  /// GET /nilai/kelas — list of classes the lecturer teaches.
  Future<List<KelasDosenItemModel>> getKelasDosen() async {
    try {
      final data = await _dioClient.get(Endpoint.nilaiKelasDosen);
      if (data is List) {
        return data
            .map((json) =>
                KelasDosenItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// GET /nilai/kelas/:kelasId — students + grades for a class.
  Future<KelasNilaiModel> getNilaiByKelas(int kelasId) async {
    try {
      final data = await _dioClient.get(Endpoint.nilaiByKelas(kelasId));
      return KelasNilaiModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /nilai/input — input/update grade for one student.
  Future<NilaiMahasiswaModel> inputNilai(InputNilaiDto dto) async {
    try {
      final data = await _dioClient.post(
        Endpoint.nilaiInput,
        data: dto.toJson(),
      );
      return NilaiMahasiswaModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// POST /nilai/input/batch — batch input grades.
  Future<Map<String, dynamic>> inputNilaiBatch(List<InputNilaiDto> items) async {
    try {
      final data = await _dioClient.post(
        Endpoint.nilaiInputBatch,
        data: {
          'items': items.map((e) => e.toJson()).toList(),
        },
      );
      return data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

final nilaiRepositoryProvider = Provider<NilaiRepository>((ref) {
  return NilaiRepository(ref.watch(dioClientProvider));
});
