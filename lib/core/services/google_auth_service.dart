import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum ClassroomRole { student, lecturer }

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;
  final String _serverClientId;

  GoogleAuthService({ClassroomRole role = ClassroomRole.student})
      : _serverClientId = (dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '').trim(),
        _googleSignIn = GoogleSignIn(
          serverClientId: (dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '').trim(),
          scopes: role == ClassroomRole.lecturer
              ? <String>[
                  'email',
                  'https://www.googleapis.com/auth/classroom.courses.readonly',
                  'https://www.googleapis.com/auth/classroom.coursework.readonly',
                  'https://www.googleapis.com/auth/classroom.coursework.students.readonly',
                  'https://www.googleapis.com/auth/classroom.rosters.readonly',
                ]
              : <String>[
                  'email',
                  'https://www.googleapis.com/auth/classroom.courses.readonly',
                  'https://www.googleapis.com/auth/classroom.coursework.me.readonly',
                  'https://www.googleapis.com/auth/classroom.rosters.readonly',
                ],
        ) {
    debugPrint('[GoogleAuth] serverClientId = $_serverClientId');
    debugPrint('[GoogleAuth] role = $role');
  }

  /// Mengembalikan Google Access Token setelah login berhasil.
  /// Mengembalikan null jika user membatalkan login.
  Future<String?> signInWithGoogle() async {
    try {
      debugPrint('[GoogleAuth] Memulai signIn...');
      if (_serverClientId.isEmpty) {
        throw Exception('GOOGLE_WEB_CLIENT_ID belum diatur di .env');
      }

      await _googleSignIn.signOut();

      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        debugPrint('[GoogleAuth] disconnect gagal, lanjut signIn: $e');
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('[GoogleAuth] User membatalkan login');
        return null;
      }

      debugPrint('[GoogleAuth] Akun: ${account.email}');
      debugPrint('[GoogleAuth] ID: ${account.id}');

      final GoogleSignInAuthentication auth = await account.authentication;
      final accessToken = auth.accessToken;
      final accessTokenPreview =
          accessToken != null && accessToken.length > 20
              ? '${accessToken.substring(0, 20)}...'
              : accessToken;
      debugPrint(
        '[GoogleAuth] AccessToken: ${accessTokenPreview != null ? "OK ($accessTokenPreview)" : "NULL"}',
      );
      debugPrint('[GoogleAuth] IdToken: ${auth.idToken != null ? "OK" : "NULL"}');

      return auth.accessToken;
    } catch (e, stack) {
      debugPrint('[GoogleAuth] ❌ ERROR signIn: $e');
      debugPrint('[GoogleAuth] ❌ Error type: ${e.runtimeType}');
      debugPrint('[GoogleAuth] ❌ Stacktrace: $stack');
      throw Exception('Gagal login menggunakan Google: $e');
    }
  }

  /// Mengambil token dari akun yang sudah login sebelumnya (silent sign-in).
  Future<String?> signInSilently() async {
    try {
      final GoogleSignInAccount? account =
          await _googleSignIn.signInSilently();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// Informasi akun yang sedang login.
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Logout dan membatalkan akses (disconnect).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('[GoogleAuth] disconnect saat signOut gagal: $e');
    }
  }
}

/// Provider untuk mahasiswa (student scopes)
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(role: ClassroomRole.student);
});

/// Provider khusus untuk dosen (lecturer scopes)
final googleAuthLecturerServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService(role: ClassroomRole.lecturer);
});
