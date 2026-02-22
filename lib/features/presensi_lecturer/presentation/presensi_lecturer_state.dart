import 'package:flutter/material.dart';
import 'package:inspire/core/models/models.dart';

class PresensiLecturerState {
  const PresensiLecturerState({
    this.isLoadingCourses = false,
    this.isLoadingStudents = false,
    this.isGeneratingCode = false,
    this.isSubmittingManual = false,
    this.courses = const [],
    this.sessions = const [],
    this.students = const [],
    this.selectedCourse,
    this.selectedMeetingNumber = 1,
    this.generatedCode,
    this.currentSessionId,
    this.attendedStudentIds = const {},
    this.errorMessage,
    this.infoMessage,
    this.selectedDeadlineDate,
    this.selectedDeadlineTime,
  });

  final bool isLoadingCourses;
  final bool isLoadingStudents;
  final bool isGeneratingCode;
  final bool isSubmittingManual;
  final List<CourseListModel> courses;
  final List<Map<String, dynamic>>
  sessions; // Stores existing sessions from backend
  final List<StudentInfoModel> students;
  final CourseListModel? selectedCourse;
  final int selectedMeetingNumber;
  final String? generatedCode;
  final int? currentSessionId;
  final Set<int> attendedStudentIds; // Tracks students who have attended
  final String? errorMessage;
  final String? infoMessage;
  final DateTime? selectedDeadlineDate;
  final TimeOfDay? selectedDeadlineTime;

  PresensiLecturerState copyWith({
    bool? isLoadingCourses,
    bool? isLoadingStudents,
    bool? isGeneratingCode,
    bool? isSubmittingManual,
    List<CourseListModel>? courses,
    List<Map<String, dynamic>>? sessions,
    List<StudentInfoModel>? students,
    CourseListModel? selectedCourse,
    bool replaceSelectedCourse = false,
    int? selectedMeetingNumber,
    String? generatedCode,
    bool clearGeneratedCode = false,
    int? currentSessionId,
    bool clearCurrentSessionId = false,
    Set<int>? attendedStudentIds,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? infoMessage,
    bool clearInfoMessage = false,
    DateTime? selectedDeadlineDate,
    bool clearDeadlineDate = false,
    TimeOfDay? selectedDeadlineTime,
    bool clearDeadlineTime = false,
  }) {
    return PresensiLecturerState(
      isLoadingCourses: isLoadingCourses ?? this.isLoadingCourses,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
      isSubmittingManual: isSubmittingManual ?? this.isSubmittingManual,
      courses: courses ?? this.courses,
      sessions: sessions ?? this.sessions,
      students: students ?? this.students,
      selectedCourse: replaceSelectedCourse
          ? selectedCourse
          : (selectedCourse ?? this.selectedCourse),
      selectedMeetingNumber:
          selectedMeetingNumber ?? this.selectedMeetingNumber,
      generatedCode: clearGeneratedCode
          ? null
          : (generatedCode ?? this.generatedCode),
      currentSessionId: clearCurrentSessionId
          ? null
          : (currentSessionId ?? this.currentSessionId),
      attendedStudentIds: attendedStudentIds ?? this.attendedStudentIds,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      selectedDeadlineDate: clearDeadlineDate
          ? null
          : (selectedDeadlineDate ?? this.selectedDeadlineDate),
      selectedDeadlineTime: clearDeadlineTime
          ? null
          : (selectedDeadlineTime ?? this.selectedDeadlineTime),
    );
  }
}
