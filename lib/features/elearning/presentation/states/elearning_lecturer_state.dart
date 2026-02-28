import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/elearning/elearning_setup_models.dart';

part 'elearning_lecturer_state.freezed.dart';

/// State untuk daftar submission mahasiswa pada sebuah tugas.
@freezed
class AssignmentSubmissionsState with _$AssignmentSubmissionsState {
  const factory AssignmentSubmissionsState.initial() = _ASInitial;
  const factory AssignmentSubmissionsState.loading() = _ASLoading;
  const factory AssignmentSubmissionsState.loaded(
    List<SubmissionWithStudentModel> submissions,
  ) = _ASLoaded;
  const factory AssignmentSubmissionsState.grading() = _ASGrading;
  const factory AssignmentSubmissionsState.graded(String message) = _ASGraded;
  const factory AssignmentSubmissionsState.error(String message) = _ASError;
}

/// State untuk daftar percobaan kuis mahasiswa yang dilihat dosen.
@freezed
class QuizAttemptsState with _$QuizAttemptsState {
  const factory QuizAttemptsState.initial() = _QAInitial;
  const factory QuizAttemptsState.loading() = _QALoading;
  const factory QuizAttemptsState.loaded(
    List<QuizAttemptWithStudentModel> attempts,
  ) = _QALoaded;
  const factory QuizAttemptsState.error(String message) = _QAError;
}
