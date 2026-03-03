import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/lecturer_academic/domain/services/lecturer_academic_service.dart';
import 'package:inspire/features/lecturer_academic/presentation/states/lecturer_academic_state.dart';

// ─── Mahasiswa Bimbingan Controller ─────────────────────────────────────────

class MahasiswaBimbinganController
    extends StateNotifier<MahasiswaBimbinganState> {
  final LecturerAcademicService _service;

  MahasiswaBimbinganController(this._service)
      : super(const MahasiswaBimbinganInitial());

  Future<void> load() async {
    state = const MahasiswaBimbinganLoading();
    try {
      final data = await _service.getMahasiswaBimbingan();
      state = MahasiswaBimbinganLoaded(data);
    } catch (e) {
      state = MahasiswaBimbinganError(e.toString());
    }
  }
}

final mahasiswaBimbinganControllerProvider = StateNotifierProvider.autoDispose<
    MahasiswaBimbinganController, MahasiswaBimbinganState>(
  (ref) {
    final service = ref.watch(lecturerAcademicServiceProvider);
    return MahasiswaBimbinganController(service);
  },
);

// ─── PA Semester List Controller ─────────────────────────────────────────────

class PaSemesterListController
    extends StateNotifier<PaSemesterListState> {
  final LecturerAcademicService _service;
  final int mahasiswaId;

  PaSemesterListController(this._service, this.mahasiswaId)
      : super(const PaSemesterListInitial());

  Future<void> load() async {
    state = const PaSemesterListLoading();
    try {
      final data = await _service.getSemestersByPA(mahasiswaId);
      state = PaSemesterListLoaded(data);
    } catch (e) {
      state = PaSemesterListError(e.toString());
    }
  }
}

final paSemesterListControllerProvider = StateNotifierProvider.autoDispose
    .family<PaSemesterListController, PaSemesterListState, int>(
  (ref, mahasiswaId) {
    final service = ref.watch(lecturerAcademicServiceProvider);
    return PaSemesterListController(service, mahasiswaId);
  },
);

// ─── PA KHS Controller ───────────────────────────────────────────────────────

class PaKhsController extends StateNotifier<PaKhsState> {
  final LecturerAcademicService _service;
  final int mahasiswaId;
  final String semester;

  PaKhsController(this._service, this.mahasiswaId, this.semester)
      : super(const PaKhsInitial());

  Future<void> load() async {
    state = const PaKhsLoading();
    try {
      final data = await _service.getKhsByPA(mahasiswaId, semester);
      state = PaKhsLoaded(data);
    } catch (e) {
      state = PaKhsError(e.toString());
    }
  }

  Future<List<int>> downloadPdf() async {
    return _service.downloadKhsByPA(mahasiswaId, semester);
  }
}

final paKhsControllerProvider = StateNotifierProvider.autoDispose
    .family<PaKhsController, PaKhsState, ({int mahasiswaId, String semester})>(
  (ref, params) {
    final service = ref.watch(lecturerAcademicServiceProvider);
    return PaKhsController(service, params.mahasiswaId, params.semester);
  },
);

// ─── PA Transkrip Controller ──────────────────────────────────────────────────

class PaTranskripController extends StateNotifier<PaTranskripState> {
  final LecturerAcademicService _service;
  final int mahasiswaId;

  PaTranskripController(this._service, this.mahasiswaId)
      : super(const PaTranskripInitial());

  Future<void> load() async {
    state = const PaTranskripLoading();
    try {
      final data = await _service.getTranskripByPA(mahasiswaId);
      state = PaTranskripLoaded(data);
    } catch (e) {
      state = PaTranskripError(e.toString());
    }
  }

  Future<List<int>> downloadPdf() async {
    return _service.downloadTranskripByPA(mahasiswaId);
  }
}

final paTranskripControllerProvider = StateNotifierProvider.autoDispose
    .family<PaTranskripController, PaTranskripState, int>(
  (ref, mahasiswaId) {
    final service = ref.watch(lecturerAcademicServiceProvider);
    return PaTranskripController(service, mahasiswaId);
  },
);
