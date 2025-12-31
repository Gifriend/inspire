import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/network/dio_client.dart';
import 'package:inspire/features/krs/data/repositories/krs_repository.dart';
import 'package:inspire/features/krs/domain/services/krs_service.dart';
import 'package:inspire/features/krs/presentation/states/krs_state.dart';

// Repository Provider
final krsRepositoryProvider = Provider<KrsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return KrsRepository(dioClient);
});

// Service Provider
final krsServiceProvider = Provider<KrsService>((ref) {
  final repository = ref.watch(krsRepositoryProvider);
  return KrsService(repository);
});

// KRS Controller Provider
final krsControllerProvider =
    StateNotifierProvider.autoDispose.family<KrsController, KrsState, String>(
  (ref, semester) {
    final service = ref.watch(krsServiceProvider);
    return KrsController(service, semester);
  },
);

class KrsController extends StateNotifier<KrsState> {
  final KrsService _service;
  final String semester;

  KrsController(this._service, this.semester) : super(const KrsState.initial());

  // Load KRS
  Future<void> loadKrs() async {
    state = const KrsState.loading();
    try {
      final krs = await _service.getKrs(semester);
      state = KrsState.loaded(krs);
    } catch (e) {
      state = KrsState.error(e.toString());
    }
  }

  // Add class to KRS
  Future<void> addClass(int kelasId) async {
    state = const KrsState.loading();
    try {
      final krs = await _service.addClass(
        kelasId: kelasId,
        semester: semester,
      );
      state = KrsState.loaded(krs);
    } catch (e) {
      state = KrsState.error(e.toString());
    }
  }

  // Remove class from KRS
  Future<void> removeClass(int kelasId) async {
    state = const KrsState.loading();
    try {
      final krs = await _service.removeClass(
        kelasId: kelasId,
        semester: semester,
      );
      state = KrsState.loaded(krs);
    } catch (e) {
      state = KrsState.error(e.toString());
    }
  }

  // Submit KRS
  Future<void> submitKrs() async {
    state = const KrsState.loading();
    try {
      final krs = await _service.submitKrs(semester);
      state = KrsState.loaded(krs);
    } catch (e) {
      state = KrsState.error(e.toString());
    }
  }
}

// Available Classes Controller Provider
final availableClassesControllerProvider = StateNotifierProvider.autoDispose
    .family<AvailableClassesController, AvailableClassesState, String>(
  (ref, semester) {
    final service = ref.watch(krsServiceProvider);
    return AvailableClassesController(service, semester);
  },
);

class AvailableClassesController extends StateNotifier<AvailableClassesState> {
  final KrsService _service;
  final String semester;

  AvailableClassesController(this._service, this.semester)
      : super(const AvailableClassesState.initial());

  // Load available classes
  Future<void> loadAvailableClasses({int? prodiId}) async {
    state = const AvailableClassesState.loading();
    try {
      final classes = await _service.getAvailableClasses(
        semester: semester,
        prodiId: prodiId,
      );
      state = AvailableClassesState.loaded(classes);
    } catch (e) {
      state = AvailableClassesState.error(e.toString());
    }
  }
}
