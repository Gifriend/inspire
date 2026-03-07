import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/student_grades_state.dart';

final studentGradesControllerProvider =
    StateNotifierProvider.autoDispose.family<StudentGradesController, StudentGradesState, int>(
  (ref, kelasId) {
    keepAliveFor(ref, const Duration(minutes: 10));
    return StudentGradesController(
      ref.watch(elearningServiceProvider),
      kelasId,
    );
  },
);

class StudentGradesController extends StateNotifier<StudentGradesState> {
  final ElearningService _service;
  final int kelasId;

  StudentGradesController(this._service, this.kelasId)
      : super(const StudentGradesState.initial());

  Future<void> loadStudentGrades() async {
    try {
      state = const StudentGradesState.loading();
      final grades = await _service.getStudentGrades(kelasId);
      state = StudentGradesState.loaded(grades);
      debugPrint('Student grades loaded: $grades');
    } catch (e) {
      state = StudentGradesState.error(e.toString());
      debugPrint('Error loading student grades: $e');
    }
  }
}
