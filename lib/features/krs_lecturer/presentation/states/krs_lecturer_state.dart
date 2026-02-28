import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/krs/krs_lecturer_model.dart';

part 'krs_lecturer_state.freezed.dart';

@freezed
abstract class KrsLecturerListState with _$KrsLecturerListState {
  const factory KrsLecturerListState.initial() = _KrsLecturerListInitial;
  const factory KrsLecturerListState.loading() = _KrsLecturerListLoading;
  const factory KrsLecturerListState.loaded(
      List<KrsSubmissionModel> submissions) = _KrsLecturerListLoaded;
  const factory KrsLecturerListState.error(String message) =
      _KrsLecturerListError;
}

@freezed
abstract class KrsLecturerDetailState with _$KrsLecturerDetailState {
  const factory KrsLecturerDetailState.initial() = _KrsLecturerDetailInitial;
  const factory KrsLecturerDetailState.loading() = _KrsLecturerDetailLoading;
  const factory KrsLecturerDetailState.loaded(KrsSubmissionModel krs) =
      _KrsLecturerDetailLoaded;
  const factory KrsLecturerDetailState.error(String message) =
      _KrsLecturerDetailError;
}

@freezed
abstract class KrsLecturerActionState with _$KrsLecturerActionState {
  const factory KrsLecturerActionState.idle() = _KrsLecturerActionIdle;
  const factory KrsLecturerActionState.loading() = _KrsLecturerActionLoading;
  const factory KrsLecturerActionState.success(String message) =
      _KrsLecturerActionSuccess;
  const factory KrsLecturerActionState.error(String message) =
      _KrsLecturerActionError;
}
