import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/models/user/user_model.dart';
import 'package:inspire/features/profile/data/repositories/profile_repository.dart';

abstract class ProfileService {
  Future<UserModel> getProfile();
}

class ProfileServiceImpl implements ProfileService {
  final ProfileRepository _profileRepository;

  ProfileServiceImpl(this._profileRepository);

  @override
  Future<UserModel> getProfile() async {
    try {
      return await _profileRepository.getProfile();
    } catch (e) {
      rethrow;
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileServiceImpl(
    ref.watch(profileRepositoryProvider),
  );
});
