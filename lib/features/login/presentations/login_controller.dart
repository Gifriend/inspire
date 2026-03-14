import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/data_sources.dart';
import 'package:inspire/core/services/firebase_notification_service.dart';
import 'package:inspire/core/services/login_service.dart';
import 'package:inspire/features/login/presentations/login_state.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<LoginState> {
  LoginController(this.ref) : super(LoginState.initial());

  final Ref ref;

  void updateIdentifier(String value) {
    state = state.copyWith(
      identifier: value,
      status: LoginSubmitStatus.initial,
      errorMessage: null,
    );
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: value,
      status: LoginSubmitStatus.initial,
      errorMessage: null,
    );
  }

  Future<void> login() async {
    final identifier = state.identifier.trim();
    final password = state.password;

    if (identifier.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: LoginSubmitStatus.error,
        errorMessage: 'NIM / NIP dan kata sandi wajib diisi',
      );
      return;
    }

    state = state.copyWith(
      status: LoginSubmitStatus.loading,
      errorMessage: null,
    );

    try {
      await ref.watch(hiveServiceProvider).ensureInitialized();

      final fcmToken = await FirebaseNotificationService.instance
          .getToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      await ref.watch(loginServiceProvider).login(
            identifier: identifier,
            password: password,
            fcmToken: fcmToken,
          );

      state = state.copyWith(
        status: LoginSubmitStatus.success,
        errorMessage: null,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Login error: ${e.runtimeType} -> $e\n$st');
      state = state.copyWith(
        status: LoginSubmitStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    state = LoginState.initial();
  }

  void clearFeedback() {
    state = state.copyWith(
      status: LoginSubmitStatus.initial,
      errorMessage: null,
    );
  }
}
