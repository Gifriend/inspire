import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/student_grades_model.dart';

part 'student_grades_state.freezed.dart';

@freezed
class StudentGradesState with _$StudentGradesState {
  const factory StudentGradesState.initial() = _Initial;
  const factory StudentGradesState.loading() = _Loading;
  const factory StudentGradesState.loaded(StudentGradesData data) = _Loaded;
  const factory StudentGradesState.error(String message) = _Error;
}
