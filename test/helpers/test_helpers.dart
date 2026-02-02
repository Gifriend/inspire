import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inspire/core/data_sources/local/model/auth_data.dart';
import 'package:inspire/features/login/data/repositories/login_repository.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks using: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([], customMocks: [
  MockSpec<LoginRepository>(as: #MockLoginRepository),
  MockSpec<LoginService>(as: #MockLoginService),
])
void main() {}

// Mock providers for testing
final mockLoginRepositoryProvider = Provider<LoginRepository>((ref) {
  throw UnimplementedError();
});

final mockLoginServiceProvider = Provider<LoginService>((ref) {
  throw UnimplementedError();
});

// Test data
class TestData {
  static const validIdentifier = '12345678';
  static const validPassword = 'password123';
  static const invalidIdentifier = 'invalid';
  static const invalidPassword = 'wrong';
  
  static const accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';
  static const refreshToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.refresh';
  
  static AuthData get authData => const AuthData(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
