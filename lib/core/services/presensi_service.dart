import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/features/presensi/data/repositories/presensi_repository.dart';

final presensiServiceProvider = Provider<PresensiService>((ref) {
  return PresensiService(
    PresensiRepository(ref.watch(dioClientProvider)),
  );
});

class PresensiService {
  final PresensiRepository _repository;

  PresensiService(this._repository);

  Future<PresensiRecordModel> submitPresensi(
    SubmitPresensiRequestModel request,
  ) async {
    try {
      return await _repository.submitPresensi(request);
    } catch (e) {
      rethrow;
    }
  }

  Future<PresensiSessionModel> createSession(
    CreatePresensiRequestModel request,
  ) async {
    try {
      return await _repository.createSession(request);
    } catch (e) {
      rethrow;
    }
  }
}
