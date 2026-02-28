import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/nilai/nilai_model.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/nilai/domain/services/nilai_service.dart';
import 'package:inspire/features/nilai/presentation/states/nilai_state.dart';

// ─── Kelas List Controller ─────────────────────────────────────────

final nilaiKelasListControllerProvider = StateNotifierProvider.autoDispose<
    NilaiKelasListController, NilaiKelasListState>(
  (ref) {
    keepAliveFor(ref, const Duration(minutes: 10));
    final service = ref.watch(nilaiServiceProvider);
    return NilaiKelasListController(service);
  },
);

class NilaiKelasListController extends StateNotifier<NilaiKelasListState> {
  final NilaiService _service;

  NilaiKelasListController(this._service)
      : super(const NilaiKelasListState.initial());

  Future<void> loadKelasDosen() async {
    state = const NilaiKelasListState.loading();
    final result = await _service.getKelasDosen();
    if (result.error != null) {
      state = NilaiKelasListState.error(result.error!);
    } else {
      state = NilaiKelasListState.loaded(result.data);
    }
  }
}

// ─── Kelas Detail Controller (students + grades) ───────────────────

final nilaiKelasDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<NilaiKelasDetailController, NilaiKelasDetailState, int>(
  (ref, kelasId) {
    keepAliveFor(ref, const Duration(minutes: 5));
    final service = ref.watch(nilaiServiceProvider);
    return NilaiKelasDetailController(service, kelasId);
  },
);

class NilaiKelasDetailController
    extends StateNotifier<NilaiKelasDetailState> {
  final NilaiService _service;
  final int kelasId;

  NilaiKelasDetailController(this._service, this.kelasId)
      : super(const NilaiKelasDetailState.initial());

  Future<void> loadNilai() async {
    state = const NilaiKelasDetailState.loading();
    final result = await _service.getNilaiByKelas(kelasId);
    if (result.error != null) {
      state = NilaiKelasDetailState.error(result.error!);
    } else {
      state = NilaiKelasDetailState.loaded(result.data!);
    }
  }
}

// ─── Input Nilai Controller (single & batch) ───────────────────────

final nilaiInputControllerProvider = StateNotifierProvider.autoDispose<
    NilaiInputController, NilaiInputState>(
  (ref) {
    final service = ref.watch(nilaiServiceProvider);
    return NilaiInputController(service);
  },
);

class NilaiInputController extends StateNotifier<NilaiInputState> {
  final NilaiService _service;

  NilaiInputController(this._service) : super(const NilaiInputState.idle());

  /// Input grade for a single student.
  Future<bool> inputNilai(InputNilaiDto dto) async {
    state = const NilaiInputState.loading();
    final result = await _service.inputNilai(dto);
    if (result.error != null) {
      state = NilaiInputState.error(result.error!);
      return false;
    }
    state = const NilaiInputState.success('Nilai berhasil disimpan');
    return true;
  }

  /// Batch input grades.
  Future<bool> inputNilaiBatch(List<InputNilaiDto> items) async {
    state = const NilaiInputState.loading();
    final result = await _service.inputNilaiBatch(items);
    if (result.error != null) {
      state = NilaiInputState.error(result.error!);
      return false;
    }
    state = const NilaiInputState.success('Nilai batch berhasil disimpan');
    return true;
  }

  void resetState() {
    state = const NilaiInputState.idle();
  }
}
