import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';

part 'transcript_state.freezed.dart';

@freezed
class TranscriptState with _$TranscriptState {
  const factory TranscriptState.initial() = _Initial;
  const factory TranscriptState.loading() = _Loading;
  const factory TranscriptState.loaded(TranscriptSummaryModel transcript) = _Loaded;
  const factory TranscriptState.error(String message) = _Error;
}
