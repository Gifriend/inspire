import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'presensi_detail_controller.g.dart';

@riverpod
class PresensiDetailController extends _$PresensiDetailController {
  @override
  PresensiDetailState build(PresensiType presensiType) {
    return PresensiDetailState(type: presensiType);
  }

  void updatePresensi(String value) {
    state = state.copyWith(
      presensi: value,
      errorPresensi: null,
      isFormValid: value.isNotEmpty,
    );
  }

  void _setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }

  void _setError(String error) {
    state = state.copyWith(errorPresensi: error, loading: false);
  }

  // Fungsi submit untuk UAS
  Future<void> submitPresensiUAS() async {
    if (state.presensi?.isEmpty ?? true) {
      _setError('Kode presensi UAS tidak boleh kosong');
      return;
    }

    _setLoading(true);

    try {
      // TODO: Implementasi API call untuk presensi UAS
      // await ref.read(presensiRepositoryProvider).submitPresensiUAS(state.presensi!);

      // Simulasi delay
      await Future.delayed(Duration(seconds: 2));

      // Handle success
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(...);
    } catch (e) {
      _setError('Gagal mengirim presensi UAS: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi submit untuk Kelas
  Future<void> submitPresensiKelas() async {
    if (state.presensi?.isEmpty ?? true) {
      _setError('Kode presensi kelas tidak boleh kosong');
      return;
    }

    _setLoading(true);

    try {
      // TODO: Implementasi API call untuk presensi Kelas
      // await ref.read(presensiRepositoryProvider).submitPresensiKelas(state.presensi!);

      // Simulasi delay
      await Future.delayed(Duration(seconds: 2));

      // Handle success
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(...);
    } catch (e) {
      _setError('Gagal mengirim presensi kelas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi submit untuk Event
  Future<void> submitPresensiEvent() async {
    if (state.presensi?.isEmpty ?? true) {
      _setError('Kode presensi event tidak boleh kosong');
      return;
    }

    _setLoading(true);

    try {
      // TODO: Implementasi API call untuk presensi Event
      // await ref.read(presensiRepositoryProvider).submitPresensiEvent(state.presensi!);

      // Simulasi delay
      await Future.delayed(Duration(seconds: 2));

      // Handle success
      // Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(...);
    } catch (e) {
      _setError('Gagal mengirim presensi event: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
