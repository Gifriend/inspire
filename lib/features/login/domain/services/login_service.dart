import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/features/login/data/repositories/login_repository.dart';

abstract class LoginService {
  Future<void> login({required String nim, required String password});
  Future<void> logout();
  Future<void> refreshToken();
}

class LoginServiceImpl implements LoginService {
  final LoginRepository _loginRepository;
  final HiveService _hiveService;

  LoginServiceImpl(this._loginRepository, this._hiveService);

  @override
  Future<void> login({
    required String nim,
    required String password,
  }) async {
    try {
      await _hiveService.ensureInitialized();
      final authData = await _loginRepository.login(
        nim: nim,
        password: password,
      );

      await _hiveService.saveAuth(authData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _hiveService.deleteAuth();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      await _hiveService.ensureInitialized();
      final currentAuth = await _hiveService.getAuth();
      if (currentAuth == null) {
        throw Exception('Tidak ada token yang tersimpan');
      }

      final newAuthData = await _loginRepository.refreshToken(
        refreshToken: currentAuth.refreshToken,
      );

      await _hiveService.saveAuth(newAuthData);
    } catch (e) {
      rethrow;
    }
  }
}

final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginServiceImpl(
    ref.watch(loginRepositoryProvider),
    ref.watch(hiveServiceProvider),
  );
});
