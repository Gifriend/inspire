import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/utils/riverpod_keep_alive.dart';
import 'package:inspire/features/elearning/domain/services/elearning_service.dart';
import 'package:inspire/features/elearning/presentation/states/student_participants_state.dart';

final studentParticipantsControllerProvider =
    StateNotifierProvider.autoDispose.family<StudentParticipantsController, StudentParticipantsState, int>(
  (ref, kelasId) {
    keepAliveFor(ref, const Duration(minutes: 10));
    return StudentParticipantsController(
      ref.watch(elearningServiceProvider),
      kelasId,
    );
  },
);

class StudentParticipantsController extends StateNotifier<StudentParticipantsState> {
  final ElearningService _service;
  final int kelasId;

  StudentParticipantsController(this._service, this.kelasId)
      : super(const StudentParticipantsState.initial());

  Future<void> loadStudentParticipants() async {
    try {
      state = const StudentParticipantsState.loading();
      final participants = await _service.getStudentParticipants(kelasId);
      state = StudentParticipantsState.loaded(participants);
      debugPrint('Student participants loaded: $participants');
    } catch (e) {
      state = StudentParticipantsState.error(e.toString());
      debugPrint('Error loading student participants: $e');
    }
  }
}
