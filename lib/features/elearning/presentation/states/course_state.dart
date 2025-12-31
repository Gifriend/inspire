import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/session_model.dart';

part 'course_state.freezed.dart';

@freezed
class CourseState with _$CourseState {
  const factory CourseState.initial() = _Initial;
  const factory CourseState.loading() = _Loading;
  const factory CourseState.loaded(List<SessionModel> sessions) = _Loaded;
  const factory CourseState.error(String message) = _Error;
}
