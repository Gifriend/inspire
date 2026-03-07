import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoint {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static String _baseUrl({required String path}) {
    return '$baseUrl$path';
  }

  static String account = _baseUrl(path: "/account");
  static String membership = _baseUrl(path: "/membership");
  static String auth = _baseUrl(path: "/auth");
  static String signing = '$auth/signing';
  static String login = '$auth/login';
  static String profile = '$auth/profile';

  // Academic endpoints
  static String academic = _baseUrl(path: "/academic");
  static String transcript = '$academic/transkrip';
  static String transcriptDownload = '$academic/transkrip/download';
  static String khsSemesters = '$academic/khs/semesters';
  static String khs(String semester) => '$academic/khs?semester=$semester';
  static String khsDownload(String semester) =>
      '$academic/khs/download?semester=$semester';

  // Announcement endpoints
  static String announcement = _baseUrl(path: "/pengumuman");
  static String announcementCreate = announcement;
  static String announcementMahasiswa = '$announcement/mahasiswa';
  static String announcementLecturerHistory = '$announcement/dosen/history';
  static String announcementLecturerByClass(int kelasId) =>
      '$announcement/dosen/kelas/$kelasId';
  static String announcementCoordinatorAll = '$announcement/koorprodi/all';
  static String announcementById(int id) => '$announcement/$id';

  // E-learning endpoints
  static String elearning = _baseUrl(path: "/elearning");
  static String courseContent(int kelasId) => '$elearning/course/$kelasId';
  static String courseDetail(int kelasId) =>
      '$elearning/course-detail/$kelasId';
  static String studentCourses = '$elearning/courses';
  static String assignmentSubmit = '$elearning/assignment/submit';
  static String assignmentDetail(String id) => '$elearning/assignment/$id';
  static String quizSubmit = '$elearning/quiz/submit';
  static String quizDetail(String id) => '$elearning/quiz/$id';
  static String materialDetail(String id) => '$elearning/material/$id';
  static String studentParticipants(int kelasId) =>
      '$elearning/kelas/$kelasId/participants';
  static String studentGrades(int kelasId) =>
      '$elearning/kelas/$kelasId/my-grades';

  // E-learning — Lecturer endpoints
  static String lecturerCourses = '$elearning/lecturer/courses';
  static String assignmentSubmissions(String assignmentId) =>
      '$elearning/assignment/$assignmentId/submissions';
  static String submissionGrade(String submissionId) =>
      '$elearning/submission/$submissionId/grade';
  static String quizAttempts(String quizId) =>
      '$elearning/quiz/$quizId/attempts';
  static String submissionDetail(String submissionId) =>
      '$elearning/submission/$submissionId';

  // E-learning — Setup endpoints
  static String elearningSetupBase = '$elearning/setup';
  static String elearningSetupClass = '$elearningSetupBase/class';
  static String elearningSetupMerge = '$elearningSetupBase/merge';
  static String elearningSetupUnmerge(int kelasId) =>
      '$elearningSetupBase/unmerge/$kelasId';
  static String elearningSetupVisibility = '$elearningSetupBase/visibility';
  static String elearningClassSetup(int kelasId) =>
      '$elearningSetupBase/class/$kelasId';

  // KRS endpoints
  static String krsBase = _baseUrl(path: "/krs");
  static String krs(String semester) => '$krsBase/$semester';
  static String krsAddClass = '$krsBase/add-class';
  static String krsRemoveClass = '$krsBase/remove-class';
  static String krsSubmit = '$krsBase/submit';
  // KRS Lecturer endpoints
    static String krsSubmissions = '$krsBase/pa/mahasiswa';
    static String krsSubmissionDetail(int krsId) => '$krsBase/pa/detail/$krsId';
  static String krsApprove(int krsId) => '$krsBase/approve/$krsId';
  static String krsReject(int krsId) => '$krsBase/reject/$krsId';
  static String krsCancel(int krsId) => '$krsBase/cancel/$krsId';
  static String krsLoadAvailableCourses(String academicYear) =>
      '$krsBase/available-courses?academicYear=$academicYear';

    // Academic PA endpoints
    static String academicPaBase = '$academic/pa';
    static String academicPaMahasiswa = '$academicPaBase/mahasiswa';
    static String academicPaStudentSemesters(int mahasiswaId) => '$academicPaBase/mahasiswa/$mahasiswaId/semesters';
    static String academicPaKhs(int mahasiswaId, String semester) => '$academicPaBase/mahasiswa/$mahasiswaId/khs?semester=$semester';
    static String academicPaKhsDownload(int mahasiswaId, String semester) => '$academicPaBase/mahasiswa/$mahasiswaId/khs/download?semester=$semester';
    static String academicPaTranskrip(int mahasiswaId) => '$academicPaBase/mahasiswa/$mahasiswaId/transkrip';
    static String academicPaTranskripDownload(int mahasiswaId) => '$academicPaBase/mahasiswa/$mahasiswaId/transkrip/download';
    static String academicPaRingkasan(int mahasiswaId) => '$academicPaBase/mahasiswa/$mahasiswaId/ringkasan';
  // Google Classroom endpoints (proxied via backend)
  static String classroom = _baseUrl(path: "/api/classroom");
  static String classroomCourses = '$classroom/courses';
  static String classroomCourseWork(String courseId) =>
      '$classroom/courses/$courseId/course-work';
  static String classroomStudents(String courseId) =>
      '$classroom/courses/$courseId/students';

  // Class selection endpoint (you may need to add this to backend)
  static String availableClasses = _baseUrl(
    path: "/kelas-perkuliahan/available",
  );

  // Schedule endpoints
  static String schedule = _baseUrl(path: "/schedule");
  static String scheduleMonthly = '$schedule/monthly';
  static String scheduleToday = '$schedule/today';
  static String scheduleIcal = '$schedule/ical';

  // Nilai (Grading) endpoints
  static String nilaiBase = _baseUrl(path: "/nilai");
  static String nilaiKelasDosen = '$nilaiBase/kelas';
  static String nilaiByKelas(int kelasId) => '$nilaiBase/kelas/$kelasId';
  static String nilaiInput = '$nilaiBase/input';
  static String nilaiInputBatch = '$nilaiBase/input/batch';

    // Presensi endpoints
    static String presensi = _baseUrl(path: "/presensi");
    static String presensiSubmit = '$presensi/submit';
}
