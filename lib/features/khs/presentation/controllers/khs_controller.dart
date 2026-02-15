import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/khs/domain/services/khs_service.dart';
import 'package:inspire/features/khs/presentation/states/khs_state.dart';

class KhsController extends StateNotifier<KhsState> {
  final KhsService _service;
  final String semester;

  KhsController(this._service, this.semester) : super(const KhsState.initial());

  Future<void> loadKhs() async {
    state = const KhsState.loading();
    try {
      final khs = await _service.getKhs(semester);
      state = KhsState.loaded(khs);
    } catch (e) {
      state = KhsState.error(e.toString());
    }
  }

  String getDownloadUrl() {
    return _service.getKhsDownloadUrl(semester);
  }
}

final khsControllerProvider = StateNotifierProvider.family<KhsController, KhsState, String>((ref, semester) {
  final service = ref.watch(khsServiceProvider);
  return KhsController(service, semester);
});

class SemesterListController extends StateNotifier<SemesterListState> {
  final KhsService _service;

  SemesterListController(this._service) : super(const SemesterListState.initial());

  Future<void> loadSemesters() async {
    state = const SemesterListState.loading();
    try {
      final semesters = await _service.getSemesters();
      state = SemesterListState.loaded(semesters);
    } catch (e) {
      state = SemesterListState.error(e.toString());
    }
  }
}

final semesterListControllerProvider = StateNotifierProvider<SemesterListController, SemesterListState>((ref) {
  final service = ref.watch(khsServiceProvider);
  return SemesterListController(service);
});


