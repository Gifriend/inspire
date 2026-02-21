import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/user/user_model.dart';
import 'package:inspire/features/profile/domain/services/profile_service.dart';
import 'package:inspire/features/profile/presentation/profile_state.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>(
  (ref) => ProfileController(ref),
);

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this.ref) : super(const ProfileState.initial());

  final Ref ref;
  UserModel? _cachedUser;

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUser != null) {
      state = ProfileState.loaded(_cachedUser!);
      return;
    }

    state = const ProfileState.loading();
    try {
      final user = await ref.watch(profileServiceProvider).getProfile();
      _cachedUser = user;
      state = ProfileState.loaded(user);
    } catch (e) {
      state = ProfileState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearCache() {
    _cachedUser = null;
    state = const ProfileState.initial();
  }

  UserModel? get cachedUser => _cachedUser;
}
