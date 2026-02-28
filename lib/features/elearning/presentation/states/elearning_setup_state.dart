import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/elearning_class_config_model.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';

part 'elearning_setup_state.freezed.dart';

/// State untuk operasi setup e-learning kelas (setup, merge, unmerge, visibility).
@freezed
class ElearningSetupState with _$ElearningSetupState {
  const factory ElearningSetupState.initial() = _Initial;
  const factory ElearningSetupState.loading() = _Loading;

  /// Konfigurasi kelas berhasil dimuat.
  const factory ElearningSetupState.loaded(
    ElearningClassConfigModel? config,
  ) = _Loaded;

  /// Operasi mutasi (setup / merge / unmerge / toggle-visibility) berhasil.
  const factory ElearningSetupState.success(String message) = _Success;

  const factory ElearningSetupState.error(String message) = _Error;
}

/// State untuk daftar kelas dosen (GET /elearning/lecturer/courses).
@freezed
class LecturerCoursesState with _$LecturerCoursesState {
  const factory LecturerCoursesState.initial() = _LCInitial;
  const factory LecturerCoursesState.loading() = _LCLoading;
  const factory LecturerCoursesState.loaded(
    List<LecturerCourseModel> courses,
  ) = _LCLoaded;
  const factory LecturerCoursesState.error(String message) = _LCError;
}
