import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/course_list_model.dart';

part 'course_list_state.freezed.dart';

@freezed
class CourseListState with _$CourseListState {
  const factory CourseListState.initial() = _Initial;
  const factory CourseListState.loading() = _Loading;
  const factory CourseListState.loaded(List<CourseListModel> courses) = _Loaded;
  const factory CourseListState.error(String message) = _Error;
}
