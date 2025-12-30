import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';
import 'package:inspire/features/login/presentation/login_state.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<LoginState> {
  LoginController(this.ref) : super(const LoginState.initial());

  final Ref ref;

  Future<void> login(String nim, String password) async {
    state = const LoginState.loading();
    try {
      await ref.read(loginServiceProvider).login(
            nim: nim,
            password: password,
          );
      state = const LoginState.success();
    } catch (e) {
      state = LoginState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    state = const LoginState.initial();
  }
}
