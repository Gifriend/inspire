import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/krs_lecturer/domain/services/krs_lecturer_service.dart';
import 'package:inspire/features/krs_lecturer/presentation/states/krs_lecturer_state.dart';

// ─── List Controller ───────────────────────────────────────────────

final krsLecturerListControllerProvider = StateNotifierProvider.autoDispose<
    KrsLecturerListController, KrsLecturerListState>(
  (ref) {
    keepAliveFor(ref, const Duration(minutes: 10));
    final service = ref.watch(krsLecturerServiceProvider);
    return KrsLecturerListController(service);
  },
);

class KrsLecturerListController extends StateNotifier<KrsLecturerListState> {
  final KrsLecturerService _service;

  KrsLecturerListController(this._service)
      : super(const KrsLecturerListState.initial());

  Future<void> loadSubmissions({String? status, String? academicYear}) async {
    state = const KrsLecturerListState.loading();
    try {
      final submissions = await _service.getSubmissions(
        status: status,
        academicYear: academicYear,
      );
      state = KrsLecturerListState.loaded(submissions);
    } catch (e) {
      state = KrsLecturerListState.error(e.toString());
    }
  }
}

// ─── Detail Controller ─────────────────────────────────────────────

final krsLecturerDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<KrsLecturerDetailController, KrsLecturerDetailState, int>(
  (ref, krsId) {
    keepAliveFor(ref, const Duration(minutes: 5));
    final service = ref.watch(krsLecturerServiceProvider);
    return KrsLecturerDetailController(service, krsId);
  },
);

class KrsLecturerDetailController
    extends StateNotifier<KrsLecturerDetailState> {
  final KrsLecturerService _service;
  final int krsId;

  KrsLecturerDetailController(this._service, this.krsId)
      : super(const KrsLecturerDetailState.initial());

  Future<void> loadDetail() async {
    state = const KrsLecturerDetailState.loading();
    try {
      final krs = await _service.getSubmissionDetail(krsId);
      state = KrsLecturerDetailState.loaded(krs);
    } catch (e) {
      state = KrsLecturerDetailState.error(e.toString());
    }
  }
}

// ─── Action Controller (approve / reject / cancel) ─────────────────

final krsLecturerActionControllerProvider = StateNotifierProvider.autoDispose<
    KrsLecturerActionController, KrsLecturerActionState>(
  (ref) {
    final service = ref.watch(krsLecturerServiceProvider);
    return KrsLecturerActionController(service);
  },
);

class KrsLecturerActionController
    extends StateNotifier<KrsLecturerActionState> {
  final KrsLecturerService _service;

  KrsLecturerActionController(this._service)
      : super(const KrsLecturerActionState.idle());

  Future<bool> approveKrs(int krsId, {String? catatan}) async {
    state = const KrsLecturerActionState.loading();
    try {
      await _service.approveKrs(krsId, catatan: catatan);
      state = const KrsLecturerActionState.success('KRS berhasil disetujui');
      return true;
    } catch (e) {
      state = KrsLecturerActionState.error(e.toString());
      return false;
    }
  }

  Future<bool> rejectKrs(int krsId, {required String catatan}) async {
    state = const KrsLecturerActionState.loading();
    try {
      await _service.rejectKrs(krsId, catatan: catatan);
      state = const KrsLecturerActionState.success('KRS berhasil ditolak');
      return true;
    } catch (e) {
      state = KrsLecturerActionState.error(e.toString());
      return false;
    }
  }

  Future<bool> cancelKrs(int krsId, {required String catatan}) async {
    state = const KrsLecturerActionState.loading();
    try {
      await _service.cancelKrs(krsId, catatan: catatan);
      state = const KrsLecturerActionState.success(
          'Persetujuan KRS berhasil dibatalkan');
      return true;
    } catch (e) {
      state = KrsLecturerActionState.error(e.toString());
      return false;
    }
  }

  void resetState() {
    state = const KrsLecturerActionState.idle();
  }
}
