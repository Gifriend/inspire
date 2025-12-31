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
  
  // Announcement endpoints
  static String announcement = _baseUrl(path: "/pengumuman");
  static String announcementMahasiswa = '$announcement/mahasiswa';
  static String announcementById(int id) => '$announcement/$id';
}
