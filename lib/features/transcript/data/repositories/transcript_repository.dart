import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
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
        throw DioException(
          requestOptions: RequestOptions(path: Endpoint.transcript),
          error: 'Response is null',
        );
      }
      return TranscriptModel.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  @override
  Future<List<int>> downloadTranscriptPdf() async {
    try {
      final bytes = await _dioClient.get<List<int>>(
        Endpoint.transcriptDownload,
        options: Options(responseType: ResponseType.bytes),
      );
      return bytes ?? [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}

final transcriptRepositoryProvider = Provider<TranscriptRepository>((ref) {
  return TranscriptRepositoryImpl(ref.watch(dioClientProvider));
});
