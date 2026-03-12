import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/data_sources/network/network.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/core/services/presensi_history_service.dart';
import 'package:inspire/core/services/presensi_service.dart';
import 'package:inspire/features/presensi/presentations/states/presensi_detail_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presensi_detail_controller.g.dart';

@riverpod
class PresensiDetailController extends _$PresensiDetailController {
  @override
  PresensiDetailState build(PresensiType presensiType) {
    return PresensiDetailState(type: presensiType);
  }

  void updateSessionId(String value) {
    final trimmed = value.trim();
    state = state.copyWith(
      sessionId: trimmed,
      errorSessionId: null,
      successMessage: null,
      isFormValid: trimmed.isNotEmpty && (state.presensi?.trim().isNotEmpty ?? false),
    );
  }

  void updatePresensi(String value) {
    final trimmed = value.trim();
    state = state.copyWith(
      presensi: trimmed,
      errorPresensi: null,
      successMessage: null,
      isFormValid: trimmed.isNotEmpty && (state.sessionId?.trim().isNotEmpty ?? false),
    );
  }

  void _setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void _setError(String error) {
    state = state.copyWith(errorPresensi: error, loading: false);
  }

  void clearFeedback() {
    state = state.copyWith(successMessage: null, errorPresensi: null);
  }

  Future<void> _submitPresensi(String errorLabel) async {
    final token = state.presensi?.trim() ?? '';

    if (token.isEmpty) {
      state = state.copyWith(errorPresensi: '$errorLabel tidak boleh kosong');
      return;
    }

    state = state.copyWith(
      errorSessionId: null,
      errorPresensi: null,
      successMessage: null,
    );

    _setLoading(true);

    try {
      final request = SubmitPresensiRequestModel(
        token: token,
      );

      final response = await ref.read(presensiServiceProvider).submitPresensi(
            request,
          );

      final successMessage = response.message.isNotEmpty
          ? response.message
          : 'Presensi berhasil dikirim.';

      await ref.read(presensiHistoryServiceProvider).addHistory(
            type: presensiType,
            token: token,
            message: successMessage,
          );

      state = state.copyWith(
        errorSessionId: null,
        errorPresensi: null,
        successMessage: successMessage,
      );
    } catch (e) {
      final apiError = ApiException.from(
        e,
        fallbackMessage: 'Presensi gagal dikirim.',
      );
      _setError(apiError.firstFieldError('token') ?? apiError.message);
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi submit untuk UAS
  Future<void> submitPresensiUAS() async {
    await _submitPresensi('Kode presensi UAS');
  }

  // Fungsi submit untuk Kelas
  Future<void> submitPresensiKelas() async {
    await _submitPresensi('Kode presensi kelas');
  }

  // Fungsi submit untuk Event
  Future<void> submitPresensiEvent() async {
    await _submitPresensi('Kode presensi event');
  }
}
