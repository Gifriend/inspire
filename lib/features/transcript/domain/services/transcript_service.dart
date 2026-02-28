import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';
import 'package:inspire/features/transcript/data/repositories/transcript_repository.dart';

abstract class TranscriptService {
  Future<TranscriptModel> getTranscript();
  Future<List<int>> downloadTranscriptPdf();
}

class TranscriptServiceImpl implements TranscriptService {
  final TranscriptRepository _transcriptRepository;

  TranscriptServiceImpl(this._transcriptRepository);

  @override
  Future<TranscriptModel> getTranscript() async {
    try {
      return await _transcriptRepository.getTranscript();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<int>> downloadTranscriptPdf() async {
    try {
      return await _transcriptRepository.downloadTranscriptPdf();
    } catch (e) {
      rethrow;
    }
  }
}

final transcriptServiceProvider = Provider<TranscriptService>((ref) {
  return TranscriptServiceImpl(
    ref.watch(transcriptRepositoryProvider),
  );
});
