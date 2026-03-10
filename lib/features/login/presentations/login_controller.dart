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
  LoginController(this.ref) : super(const LoginState.initial());

  final Ref ref;

  Future<void> login(String identifier, String password) async {
    state = const LoginState.loading();
    try {
      await ref.watch(hiveServiceProvider).ensureInitialized();

      // Get FCM new fcm token, so the backend can save the device token on login.
      final fcmToken = await FirebaseNotificationService.instance
          .getToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      await ref.watch(loginServiceProvider).login(
            identifier: identifier,
            password: password,
            fcmToken: fcmToken,
          );
      state = const LoginState.success();
    } catch (e, st) {
      // ignore: avoid_print
      print('Login error: ${e.runtimeType} -> $e\n$st');
      state = LoginState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    state = const LoginState.initial();
  }
}
