import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/transcript/domain/services/transcript_service.dart';
import 'package:inspire/features/presentation.dart';

final transcriptControllerProvider =
    StateNotifierProvider<TranscriptController, TranscriptState>(
  (ref) => TranscriptController(ref.watch(transcriptServiceProvider)),
);

class TranscriptController extends StateNotifier<TranscriptState> {
  final TranscriptService _service;

  TranscriptController(this._service) : super(const TranscriptState.initial());

  Future<void> loadTranscript() async {
    state = const TranscriptState.loading();
    try {
      final transcript = await _service.getTranscript();
      state = TranscriptState.loaded(transcript);
    } catch (e) {
      state = TranscriptState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void reset() {
    state = const TranscriptState.initial();
  }

  Future<String> downloadHtml() async {
    try {
      return await _service.downloadTranscriptHtml();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
