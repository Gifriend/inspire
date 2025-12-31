import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/course_list_state.dart';

final courseListControllerProvider =
    StateNotifierProvider.autoDispose<CourseListController, CourseListState>(
  (ref) {
    return CourseListController(
      ref.watch(elearningServiceProvider),
    );
  },
);

class CourseListController extends StateNotifier<CourseListState> {
  final ElearningService _service;

  CourseListController(this._service) : super(const CourseListState.initial());

  Future<void> loadCourses() async {
    try {
      state = const CourseListState.loading();
      final courses = await _service.getStudentCourses();
      state = CourseListState.loaded(courses);
      print(courses);
    } catch (e) {
      state = CourseListState.error(e.toString());
    }
  }
}
