import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/models.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.success(Auth auth) = _Success;
  const factory LoginState.error(String message) = _Error;
}
