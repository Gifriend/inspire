import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/krs/krs_model.dart';

part 'krs_state.freezed.dart';

@freezed
abstract class KrsState with _$KrsState {
  const factory KrsState.initial() = _Initial;
  const factory KrsState.loading() = _Loading;
  const factory KrsState.loaded(KrsModel krs) = _Loaded;
  const factory KrsState.error(String message) = _Error;
}

@freezed
abstract class AvailableClassesState with _$AvailableClassesState {
  const factory AvailableClassesState.initial() = _AvailableClassesInitial;
  const factory AvailableClassesState.loading() = _AvailableClassesLoading;
  const factory AvailableClassesState.loaded(
      List<KelasPerkuliahanModel> classes) = _AvailableClassesLoaded;
  const factory AvailableClassesState.error(String message) =
      _AvailableClassesError;
}
