import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';

abstract class TranscriptRepository {
  Future<TranscriptModel> getTranscript();
  Future<List<int>> downloadTranscriptPdf();
}

class TranscriptRepositoryImpl implements TranscriptRepository {
  final DioClient _dioClient;

  TranscriptRepositoryImpl(this._dioClient);

  @override
  Future<TranscriptModel> getTranscript() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        Endpoint.transcript,
      );
      if (response == null) {
        throw const ApiException(message: 'Data transkrip kosong');
      }
      return ApiEnvelope.fromDynamic<TranscriptModel>(
        response,
        dataParser: (data) => TranscriptModel.fromJson(ApiEnvelope.parseSingleMap(data)),
        defaultMessage: 'Gagal memuat transkrip',
      ).data;
    } catch (e) {
      throw ApiException.from(e, fallbackMessage: 'Gagal memuat transkrip');
    }
  }

  @override
  Future<List<int>> downloadTranscriptPdf() async {
    try {
      final bytes = await _dioClient.downloadBytes(
        Endpoint.transcriptDownload,
      );
      if (bytes.isEmpty) {
        throw Exception('File PDF kosong');
      }
      return bytes;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

final transcriptRepositoryProvider = Provider<TranscriptRepository>((ref) {
  return TranscriptRepositoryImpl(ref.watch(dioClientProvider));
});
