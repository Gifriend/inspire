import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/student_participants_model.dart';

part 'student_participants_state.freezed.dart';

@freezed
class StudentParticipantsState with _$StudentParticipantsState {
  const factory StudentParticipantsState.initial() = _Initial;
  const factory StudentParticipantsState.loading() = _Loading;
  const factory StudentParticipantsState.loaded(StudentParticipantsData data) = _Loaded;
  const factory StudentParticipantsState.error(String message) = _Error;
}
