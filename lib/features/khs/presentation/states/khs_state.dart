import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/khs/khs_model.dart';

part 'khs_state.freezed.dart';

@freezed
abstract class KhsState with _$KhsState {
  const factory KhsState.initial() = _Initial;
  const factory KhsState.loading() = _Loading;
  const factory KhsState.loaded(KhsModel khs) = _Loaded;
  const factory KhsState.error(String message) = _Error;
}

@freezed
abstract class SemesterListState with _$SemesterListState {
  const factory SemesterListState.initial() = _SemesterListInitial;
  const factory SemesterListState.loading() = _SemesterListLoading;
  const factory SemesterListState.loaded(List<String> semesters) = _SemesterListLoaded;
  const factory SemesterListState.error(String message) = _SemesterListError;
}


