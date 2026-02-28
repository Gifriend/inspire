import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/elearning_setup_state.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

/// Setup controller per kelas — setiap kelas punya state sendiri.
final elearningSetupControllerProvider = StateNotifierProvider.autoDispose
    .family<ElearningSetupController, ElearningSetupState, int>(
  (ref, kelasId) {
    keepAliveFor(ref, const Duration(minutes: 10));
    return ElearningSetupController(
      ref.watch(elearningServiceProvider),
      kelasId,
    );
  },
);

/// Daftar kelas yang diampu dosen — dipakai untuk dropdown pilihan kelas sumber.
final lecturerCoursesControllerProvider = StateNotifierProvider.autoDispose<
    LecturerCoursesController, LecturerCoursesState>(
  (ref) {
    keepAliveFor(ref, const Duration(minutes: 10));
    return LecturerCoursesController(ref.watch(elearningServiceProvider));
  },
);

// ─── ElearningSetupController ────────────────────────────────────────────────

/// Mengelola setup / merge / unmerge / toggle-visibility untuk satu kelas.
class ElearningSetupController extends StateNotifier<ElearningSetupState> {
  final ElearningService _service;
  final int kelasId;

  ElearningSetupController(this._service, this.kelasId)
      : super(const ElearningSetupState.initial());

  /// Memuat konfigurasi e-learning yang tersimpan untuk kelas ini.
  Future<void> loadClassSetup() async {
    try {
      state = const ElearningSetupState.loading();
      final config = await _service.getClassSetup(kelasId);
      state = ElearningSetupState.loaded(config);
    } catch (e) {
      state = ElearningSetupState.error(e.toString());
    }
  }

  /// Simpan pilihan setup:
  /// - `setupMode = NEW` → e-learning baru kosong
  /// - `setupMode = EXISTING` + `sourceKelasPerkuliahanId` → gunakan / clone
  /// - `isMergedClass = true` → ikut sumber tanpa clone (shared)
  Future<bool> setupClass(SetupElearningClassRequest request) async {
    try {
      state = const ElearningSetupState.loading();
      final result = await _service.setupClass(request);
      state = ElearningSetupState.success(result.message);
      return true;
    } catch (e) {
      state = ElearningSetupState.error(e.toString());
      return false;
    }
  }

  /// Gabungkan beberapa kelas ke satu sumber e-learning.
  Future<bool> mergeClasses(MergeElearningClassesRequest request) async {
    try {
      state = const ElearningSetupState.loading();
      final result = await _service.mergeClasses(request);
      state = ElearningSetupState.success(result.message);
      return true;
    } catch (e) {
      state = ElearningSetupState.error(e.toString());
      return false;
    }
  }

  /// Pisahkan kelas dari gabungan — kelas kembali menggunakan e-learning sendiri.
  Future<bool> unmergeClass() async {
    try {
      state = const ElearningSetupState.loading();
      final config = await _service.unmergeClass(kelasId);
      state = ElearningSetupState.loaded(config);
      return true;
    } catch (e) {
      state = ElearningSetupState.error(e.toString());
      return false;
    }
  }

  /// Toggle visibilitas per-item (materi / tugas / kuis).
  /// [onSuccess] dipanggil setelah berhasil agar UI lokal bisa diperbarui
  /// tanpa reload penuh.
  Future<bool> toggleVisibility(
    ToggleVisibilityRequest request, {
    void Function()? onSuccess,
  }) async {
    try {
      await _service.toggleVisibility(request);
      onSuccess?.call();
      return true;
    } catch (e) {
      state = ElearningSetupState.error(e.toString());
      return false;
    }
  }

  void resetToInitial() => state = const ElearningSetupState.initial();
}

// ─── LecturerCoursesController ────────────────────────────────────────────────

/// Memuat semua kelas yang diampu dosen.
/// Terutama digunakan untuk mengisi dropdown pemilihan kelas sumber.
class LecturerCoursesController extends StateNotifier<LecturerCoursesState> {
  final ElearningService _service;

  LecturerCoursesController(this._service)
      : super(const LecturerCoursesState.initial());

  Future<void> loadCourses() async {
    try {
      state = const LecturerCoursesState.loading();
      final courses = await _service.getLecturerCourses();
      state = LecturerCoursesState.loaded(courses);
    } catch (e) {
      state = LecturerCoursesState.error(e.toString());
    }
  }
}
