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

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoadingCourses: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final courses = await _service.getLecturerCourses();
      final selectedCourse = courses.isNotEmpty ? courses.first : null;

      state = state.copyWith(
        isLoadingCourses: false,
        courses: courses,
        selectedCourse: selectedCourse,
        replaceSelectedCourse: true,
        students: const [],
        manualPresentStudentIds: <int>{},
        clearGeneratedCode: true,
      );

      if (selectedCourse != null) {
        await loadStudents(selectedCourse.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingCourses: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadStudents(int kelasId) async {
    state = state.copyWith(
      isLoadingStudents: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final students = await _service.getCourseStudents(kelasId);
      state = state.copyWith(isLoadingStudents: false, students: students);
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> selectCourse(CourseListModel? course) async {
    state = state.copyWith(
      selectedCourse: course,
      replaceSelectedCourse: true,
      students: const [],
      manualPresentStudentIds: <int>{},
      clearGeneratedCode: true,
      clearInfoMessage: true,
      clearErrorMessage: true,
    );

    if (course != null) {
      await loadStudents(course.id);
    }
  }

  void selectMeetingNumber(int meetingNumber) {
    state = state.copyWith(
      selectedMeetingNumber: meetingNumber,
      clearGeneratedCode: true,
      clearInfoMessage: true,
      clearErrorMessage: true,
    );
  }

  Future<void> generateMeetingCode() async {
    final selectedCourse = state.selectedCourse;
    if (selectedCourse == null) {
      state = state.copyWith(
        errorMessage: 'Silakan pilih kelas terlebih dahulu',
      );
      return;
    }

    state = state.copyWith(
      isGeneratingCode: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final code = await _service.generateMeetingCode(
        kelasPerkuliahanId: selectedCourse.id,
        meetingNumber: state.selectedMeetingNumber,
      );

      state = state.copyWith(
        isGeneratingCode: false,
        generatedCode: code,
        infoMessage:
            'Kode presensi pertemuan ${state.selectedMeetingNumber} berhasil dibuat',
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingCode: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> markManualAttendance(StudentInfoModel student) async {
    final selectedCourse = state.selectedCourse;
    if (selectedCourse == null) {
      state = state.copyWith(
        errorMessage: 'Silakan pilih kelas terlebih dahulu',
      );
      return;
    }

    if (state.manualPresentStudentIds.contains(student.id)) {
      return;
    }

    state = state.copyWith(
      isSubmittingManual: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      await _service.markManualAttendance(
        kelasPerkuliahanId: selectedCourse.id,
        mahasiswaId: student.id,
        meetingNumber: state.selectedMeetingNumber,
      );

      final markedIds = {...state.manualPresentStudentIds, student.id};
      state = state.copyWith(
        isSubmittingManual: false,
        manualPresentStudentIds: markedIds,
        infoMessage:
            '${student.name} berhasil dipresensi manual pada pertemuan ${state.selectedMeetingNumber}',
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
