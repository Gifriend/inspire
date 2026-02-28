import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';
import 'package:inspire/features/nilai/data/repositories/nilai_repository.dart';

class NilaiService {
  final NilaiRepository _repository;

  NilaiService(this._repository);

  /// Fetch classes the lecturer teaches.
  Future<({List<KelasDosenItemModel> data, String? error})>
      getKelasDosen() async {
    try {
      final data = await _repository.getKelasDosen();
      return (data: data, error: null);
    } catch (e) {
      return (data: <KelasDosenItemModel>[], error: e.toString());
    }
  }

  /// Fetch students + grades for a class.
  Future<({KelasNilaiModel? data, String? error})> getNilaiByKelas(
      int kelasId) async {
    try {
      final data = await _repository.getNilaiByKelas(kelasId);
      return (data: data, error: null);
    } catch (e) {
      return (data: null, error: e.toString());
    }
  }

  /// Input a single student's grade.
  Future<({NilaiMahasiswaModel? data, String? error})> inputNilai(
      InputNilaiDto dto) async {
    try {
      final data = await _repository.inputNilai(dto);
      return (data: data, error: null);
    } catch (e) {
      return (data: null, error: e.toString());
    }
  }

  /// Batch input grades.
  Future<({Map<String, dynamic>? data, String? error})> inputNilaiBatch(
      List<InputNilaiDto> items) async {
    try {
      final data = await _repository.inputNilaiBatch(items);
      return (data: data, error: null);
    } catch (e) {
      return (data: null, error: e.toString());
    }
  }
}

final nilaiServiceProvider = Provider<NilaiService>((ref) {
  return NilaiService(ref.watch(nilaiRepositoryProvider));
});
