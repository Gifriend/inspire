import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/network.dart';
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

  Future<ApiEnvelope<PresensiRecordModel>> submitPresensi(
    SubmitPresensiRequestModel request,
  ) => _repository.submitPresensi(request);

  Future<ApiEnvelope<PresensiSessionModel>> createSession(
    CreatePresensiRequestModel request,
  ) => _repository.createSession(request);
}
