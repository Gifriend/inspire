import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/constants/enums/enums.dart';

part 'presensi_detail_state.freezed.dart';

@freezed
abstract class PresensiDetailState with _$PresensiDetailState {
  const factory PresensiDetailState({
    required PresensiType type,
    String? presensi,
    String? errorPresensi,
    bool? loading,
    @Default(false) bool isFormValid,
  }) = _PresensiDetailState;
}
