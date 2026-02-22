import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/models.dart';
import 'package:inspire/features/presensi_lecturer/data/services/presensi_lecturer_service.dart';

import 'presensi_lecturer_state.dart';

final presensiLecturerControllerProvider =
    StateNotifierProvider<PresensiLecturerController, PresensiLecturerState>(
      (ref) => PresensiLecturerController(
        ref.watch(presensiLecturerServiceProvider),
      ),
    );

class PresensiLecturerController extends StateNotifier<PresensiLecturerState> {
  PresensiLecturerController(this._service)
    : super(const PresensiLecturerState());

  final PresensiLecturerService _service;

  // Fungsi untuk update Date
  void selectDeadlineDate(DateTime date) {
    state = state.copyWith(selectedDeadlineDate: date, clearErrorMessage: true);
  }

  // Fungsi untuk update Time
  void selectDeadlineTime(TimeOfDay time) {
    state = state.copyWith(selectedDeadlineTime: time, clearErrorMessage: true);
  }

  // Fungsi untuk reset Deadline (misal saat ganti mata kuliah/pertemuan)
  void clearDeadline() {
    state = state.copyWith(clearDeadlineDate: true, clearDeadlineTime: true);
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoadingCourses: true, clearErrorMessage: true);

    try {
      final courses = await _service.getLecturerCourses();
      final selectedCourse = courses.isNotEmpty ? courses.first : null;

      state = state.copyWith(
        isLoadingCourses: false,
        courses: courses,
        selectedCourse: selectedCourse,
        replaceSelectedCourse: true,
      );

      if (selectedCourse != null) {
        await _loadCourseData(selectedCourse.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingCourses: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> selectCourse(CourseListModel? course) async {
    state = state.copyWith(
      selectedCourse: course,
      replaceSelectedCourse: true,
      selectedMeetingNumber: 1,
      clearErrorMessage: true,
    );

    if (course != null) {
      await _loadCourseData(course.id);
    }
  }

  /// Loads sessions and students for the selected course
  Future<void> _loadCourseData(int kelasId) async {
    state = state.copyWith(isLoadingStudents: true);
    try {
      final sessions = await _service.getCourseSessions(kelasId);
      state = state.copyWith(sessions: sessions);

      await _syncMeetingSession();
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> selectMeetingNumber(int meetingNumber) async {
    state = state.copyWith(
      selectedMeetingNumber: meetingNumber,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );
    await _syncMeetingSession();
  }

  /// Matches the selected meeting number with backend sessions and fetches attendance
  Future<void> _syncMeetingSession() async {
    final course = state.selectedCourse;
    if (course == null) return;

    state = state.copyWith(isLoadingStudents: true);

    try {
      final meetingTitlePrefix = 'Pertemuan ${state.selectedMeetingNumber}';

      // Find if session already exists for this meeting
      final existingSession = state.sessions
          .where((s) => s['title'].toString().startsWith(meetingTitlePrefix))
          .firstOrNull;

      if (existingSession != null) {
        final sessionId = existingSession['id'] as int;
        final token = existingSession['token'] as String;

        // Fetch students with their attendance status for this session
        final students = await _service.getCourseStudents(
          course.id,
          sessionId: sessionId,
        );

        // Assuming StudentInfoModel has raw JSON or a property for attendance.
        // If not, we map it manually based on backend response logic.
        final attendedIds = <int>{};
        for (var student in students) {
          // Adjust this check based on how you parse the `presensi` object in your model
          if (student.presensi != null) {
            attendedIds.add(student.id);
          }
        }

        state = state.copyWith(
          currentSessionId: sessionId,
          generatedCode: token,
          students: students,
          attendedStudentIds: attendedIds,
          isLoadingStudents: false,
        );
      } else {
        // No session exists for this meeting yet
        final students = await _service.getCourseStudents(course.id);

        state = state.copyWith(
          clearCurrentSessionId: true,
          clearGeneratedCode: true,
          students: students,
          attendedStudentIds: const {},
          isLoadingStudents: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> generateMeetingCode() async {
    final course = state.selectedCourse;
    if (course == null) return;

    // Validasi frontend: Jika salah satu diisi, yang lain juga harus diisi
    if ((state.selectedDeadlineDate != null &&
            state.selectedDeadlineTime == null) ||
        (state.selectedDeadlineDate == null &&
            state.selectedDeadlineTime != null)) {
      state = state.copyWith(
        errorMessage:
            'Tanggal dan Jam deadline harus diisi keduanya, atau kosongkan sama sekali.',
      );
      return;
    }

    state = state.copyWith(isGeneratingCode: true, clearErrorMessage: true);

    try {
      final sessionTitle =
          'Pertemuan ${state.selectedMeetingNumber} - ${course.mataKuliah?.name ?? course.nama}';

      String? formattedDate;
      String? formattedTime;

      if (state.selectedDeadlineDate != null &&
          state.selectedDeadlineTime != null) {
        final d = state.selectedDeadlineDate!;
        final t = state.selectedDeadlineTime!;

        // Format YYYY-MM-DD
        formattedDate =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        // Format HH:mm
        formattedTime =
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      }

      final result = await _service.generateSession(
        kelasPerkuliahanId: course.id,
        title: sessionTitle,
        deadlineDate: formattedDate,
        deadlineTime: formattedTime,
      );

      final updatedSessions = await _service.getCourseSessions(course.id);

      state = state.copyWith(
        isGeneratingCode: false,
        sessions: updatedSessions,
        generatedCode: result.token,
        currentSessionId: result.id,
        clearDeadlineDate: true, // Reset setelah sukses
        clearDeadlineTime: true, // Reset setelah sukses
        infoMessage: 'Kode presensi berhasil dibuat: ${result.token}',
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingCode: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> markManualAttendance(StudentInfoModel student) async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) return;

    state = state.copyWith(isSubmittingManual: true, clearErrorMessage: true);

    try {
      await _service.markManualAttendance(
        sessionId: sessionId,
        mahasiswaId: student.id,
      );

      state = state.copyWith(
        isSubmittingManual: false,
        attendedStudentIds: {...state.attendedStudentIds, student.id},
        infoMessage: '${student.name} berhasil dipresensi manual.',
      );
    } catch (e) {
      state = state.copyWith(
        isSubmittingManual: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> revokeAttendance(StudentInfoModel student) async {
    final sessionId = state.currentSessionId;
    if (sessionId == null) return;

    state = state.copyWith(isSubmittingManual: true, clearErrorMessage: true);

    try {
      await _service.revokeAttendance(
        sessionId: sessionId,
        mahasiswaId: student.id,
      );

      final updatedIds = Set<int>.from(state.attendedStudentIds)
        ..remove(student.id);

      state = state.copyWith(
        isSubmittingManual: false,
        attendedStudentIds: updatedIds,
        infoMessage: 'Presensi ${student.name} berhasil dibatalkan.',
      );
    } catch (e) {
      state = state.copyWith(
        isSubmittingManual: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(clearErrorMessage: true, clearInfoMessage: true);
  }
}
