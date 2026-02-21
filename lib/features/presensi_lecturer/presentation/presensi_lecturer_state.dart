import 'package:inspire/core/models/models.dart';

class PresensiLecturerState {
  const PresensiLecturerState({
    this.isLoadingCourses = false,
    this.isLoadingStudents = false,
    this.isGeneratingCode = false,
    this.isSubmittingManual = false,
    this.courses = const [],
    this.students = const [],
    this.selectedCourse,
    this.selectedMeetingNumber = 1,
    this.generatedCode,
    this.manualPresentStudentIds = const {},
    this.errorMessage,
    this.infoMessage,
  });

  final bool isLoadingCourses;
  final bool isLoadingStudents;
  final bool isGeneratingCode;
  final bool isSubmittingManual;
  final List<CourseListModel> courses;
  final List<StudentInfoModel> students;
  final CourseListModel? selectedCourse;
  final int selectedMeetingNumber;
  final String? generatedCode;
  final Set<int> manualPresentStudentIds;
  final String? errorMessage;
  final String? infoMessage;

  PresensiLecturerState copyWith({
    bool? isLoadingCourses,
    bool? isLoadingStudents,
    bool? isGeneratingCode,
    bool? isSubmittingManual,
    List<CourseListModel>? courses,
    List<StudentInfoModel>? students,
    CourseListModel? selectedCourse,
    bool replaceSelectedCourse = false,
    int? selectedMeetingNumber,
    String? generatedCode,
    bool clearGeneratedCode = false,
    Set<int>? manualPresentStudentIds,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? infoMessage,
    bool clearInfoMessage = false,
  }) {
    return PresensiLecturerState(
      isLoadingCourses: isLoadingCourses ?? this.isLoadingCourses,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
      isSubmittingManual: isSubmittingManual ?? this.isSubmittingManual,
      courses: courses ?? this.courses,
      students: students ?? this.students,
      selectedCourse: replaceSelectedCourse
          ? selectedCourse
          : (selectedCourse ?? this.selectedCourse),
      selectedMeetingNumber:
          selectedMeetingNumber ?? this.selectedMeetingNumber,
      generatedCode: clearGeneratedCode
          ? null
          : (generatedCode ?? this.generatedCode),
      manualPresentStudentIds:
          manualPresentStudentIds ?? this.manualPresentStudentIds,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
