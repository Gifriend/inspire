import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

enum LoginSubmitStatus { initial, loading, success, error }

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String identifier,
    @Default('') String password,
    @Default(LoginSubmitStatus.initial) LoginSubmitStatus status,
    String? errorMessage,
  }) = _LoginState;

  factory LoginState.initial() => const LoginState();
}
