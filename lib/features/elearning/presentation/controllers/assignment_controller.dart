import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/assignment_state.dart';

final assignmentControllerProvider =
    StateNotifierProvider.autoDispose<AssignmentController, AssignmentState>((
      ref,
    ) {
      return AssignmentController(ref.watch(elearningServiceProvider));
    });

class AssignmentController extends StateNotifier<AssignmentState> {
  final ElearningService _service;

  AssignmentController(this._service) : super(const AssignmentState.initial());

  Future<void> submitAssignment({
    required int assignmentId,
    String? fileUrl,
    String? textContent,
  }) async {
    try {
      state = const AssignmentState.submitting();
      final submission = await _service.submitAssignment(
        assignmentId: assignmentId,
        fileUrl: fileUrl,
        textContent: textContent,
      );
      state = AssignmentState.submitted(submission);
    } catch (e) {
      state = AssignmentState.error(e.toString());
    }
  }

  Future<void> loadAssignmentDetail(String id) async {
    try {
      state = const AssignmentState.loading();
      // Asumsi service memiliki method getAssignmentDetail
      final assignment = await _service.getAssignmentDetail(id);
      state = AssignmentState.loaded(assignment);
    } catch (e) {
      state = AssignmentState.error(e.toString());
    }
  }
}
