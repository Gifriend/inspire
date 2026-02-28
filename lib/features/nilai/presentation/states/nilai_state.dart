import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';

part 'nilai_state.freezed.dart';

/// State for the lecturer's class list (GET /nilai/kelas).
@freezed
abstract class NilaiKelasListState with _$NilaiKelasListState {
  const factory NilaiKelasListState.initial() = _NilaiKelasListInitial;
  const factory NilaiKelasListState.loading() = _NilaiKelasListLoading;
  const factory NilaiKelasListState.loaded(List<KelasDosenItemModel> kelas) =
      _NilaiKelasListLoaded;
  const factory NilaiKelasListState.error(String message) =
      _NilaiKelasListError;
}

/// State for a single class's student grades (GET /nilai/kelas/:kelasId).
@freezed
abstract class NilaiKelasDetailState with _$NilaiKelasDetailState {
  const factory NilaiKelasDetailState.initial() = _NilaiKelasDetailInitial;
  const factory NilaiKelasDetailState.loading() = _NilaiKelasDetailLoading;
  const factory NilaiKelasDetailState.loaded(KelasNilaiModel data) =
      _NilaiKelasDetailLoaded;
  const factory NilaiKelasDetailState.error(String message) =
      _NilaiKelasDetailError;
}

/// State for input-nilai actions (single or batch).
@freezed
abstract class NilaiInputState with _$NilaiInputState {
  const factory NilaiInputState.idle() = _NilaiInputIdle;
  const factory NilaiInputState.loading() = _NilaiInputLoading;
  const factory NilaiInputState.success(String message) = _NilaiInputSuccess;
  const factory NilaiInputState.error(String message) = _NilaiInputError;
}
