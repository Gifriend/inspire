import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/constants/constants.dart';
import 'package:inspire/core/models/models.dart';

import '../../../core/data_sources/data_sources.dart';
import '../../../core/data_sources/network/dio_client.dart';
import '../../presentation.dart';

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
      final dio = ref.read(dioClientProvider);
      final request = LoginRequest(nim: nim, password: password);
      final response = await dio.post<Map<String, dynamic>>(
        Endpoint.login, // Using /auth/login to match backend
        data: request.toJson(),
      );
      final auth = AuthData.fromJson(response!);
      await ref.read(hiveServiceProvider).saveAuth(auth);
      state = LoginState.success(auth as Auth);
    } catch (e) {
      state = LoginState.error(e.toString());
    }
  }
}
