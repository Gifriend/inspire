import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/course_state.dart';

final courseControllerProvider =
    StateNotifierProvider.autoDispose.family<CourseController, CourseState, int>(
  (ref, kelasId) {
    return CourseController(
      ref.watch(elearningServiceProvider),
      kelasId,
    );
  },
);

class CourseController extends StateNotifier<CourseState> {
  final ElearningService _service;
  final int kelasId;

  CourseController(this._service, this.kelasId)
      : super(const CourseState.initial());

  Future<void> loadCourseContent() async {
    try {
      state = const CourseState.loading();
      final sessions = await _service.getCourseContent(kelasId);
      state = CourseState.loaded(sessions);
      debugPrint('$sessions');
    } catch (e) {
      state = CourseState.error(e.toString());
    }
  }
}
