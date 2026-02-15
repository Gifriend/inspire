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
  static String khsDownload(String semester) => '$academic/khs/download?semester=$semester';
  
  // Announcement endpoints
  static String announcement = _baseUrl(path: "/pengumuman");
  static String announcementMahasiswa = '$announcement/mahasiswa';
  static String announcementById(int id) => '$announcement/$id';
  
  // E-learning endpoints
  static String elearning = _baseUrl(path: "/elearning");
  static String courseContent(int kelasId) => '$elearning/course/$kelasId';
  static String courseDetail(int kelasId) => '$elearning/course-detail/$kelasId';
  static String studentCourses = '$elearning/courses';
  static String assignmentSubmit = '$elearning/assignment/submit';
  static String assignmentDetail(String id) => '$elearning/assignment/$id';
  static String quizSubmit = '$elearning/quiz/submit';
  static String quizDetail(String id) => '$elearning/quiz/$id';
  static String materialDetail(String id) => '$elearning/material/$id';
  
  // KRS endpoints
  static String krsBase = _baseUrl(path: "/krs");
  static String krs(String semester) => '$krsBase/$semester';
  static String krsAddClass = '$krsBase/add-class';
  static String krsRemoveClass = '$krsBase/remove-class';
  static String krsSubmit = '$krsBase/submit';
  static String krsApprove(int krsId) => '$krsBase/approve/$krsId';
  static String krsReject(int krsId) => '$krsBase/reject/$krsId';
  static String krsCancel(int krsId) => '$krsBase/cancel/$krsId';
  static String krsLoadAvailableCourses(String academicYear) => '$krsBase/available-courses?academicYear=$academicYear';
  
  // Class selection endpoint (you may need to add this to backend)
  static String availableClasses = _baseUrl(path: "/kelas-perkuliahan/available");
}
