import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/user/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.loaded(UserModel user) = _Loaded;
  const factory ProfileState.error(String message) = _Error;
}
