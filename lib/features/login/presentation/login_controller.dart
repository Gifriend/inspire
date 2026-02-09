import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';
import 'package:inspire/features/login/presentation/login_state.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<LoginState> {
  LoginController(this.ref) : super(const LoginState.initial());

  final Ref ref;

  Future<void> login(String identifier, String password) async {
    state = const LoginState.loading();
    try {
      await ref.watch(hiveServiceProvider).ensureInitialized();
      await ref.watch(loginServiceProvider).login(
            identifier: identifier,
            password: password,
          );
      state = const LoginState.success();
    } catch (e, st) {
      // Log detail ke debug console untuk membantu melacak error asli
      // (pengguna melaporkan hanya pesan snackbar yang muncul).
      // Ini tidak mengubah alur, hanya menambah visibilitas.
      // ignore: avoid_print
      print('Login error: ${e.runtimeType} -> $e\n$st');
      state = LoginState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    state = const LoginState.initial();
  }
}
