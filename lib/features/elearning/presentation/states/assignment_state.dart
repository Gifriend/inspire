import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/assignment_model.dart';

part 'assignment_state.freezed.dart';

@freezed
class AssignmentState with _$AssignmentState {
  const factory AssignmentState.initial() = _Initial;
  const factory AssignmentState.loading() = _Loading;
  const factory AssignmentState.loaded(AssignmentModel assignment) = _Loaded;
  const factory AssignmentState.submitting() = _Submitting;
  const factory AssignmentState.submitted(SubmissionModel submission) = _Submitted;
  const factory AssignmentState.error(String message) = _Error;
}
