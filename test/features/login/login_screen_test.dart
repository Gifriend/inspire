import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspire/features/login/domain/services/login_service.dart';
import 'package:inspire/features/login/presentation/login_controller.dart';
import 'package:inspire/features/login/presentation/login_screen.dart';
import 'package:inspire/features/login/presentation/login_state.dart';

import '../../helpers/test_helpers.dart';

// Fake LoginService for testing without mockito complexity
class FakeLoginService implements LoginService {
  bool shouldSucceed = true;
  String? errorMessage;
  
  @override
  Future<void> login({required String identifier, required String password, String? fcmToken}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!shouldSucceed) {
      throw Exception(errorMessage ?? 'Login failed');
    }
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> refreshToken() async {}
}

void main() {
  late FakeLoginService fakeLoginService;

  setUp(() {
    fakeLoginService = FakeLoginService();
  });

  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [
        loginServiceProvider.overrideWithValue(fakeLoginService),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should display all UI elements correctly', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify text elements
      expect(find.text('Selamat Datang Kembali'), findsOneWidget);
      expect(find.text('NIM'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should validate empty NIM field', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find login button and tap without filling fields
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('NIM tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Fill only NIM
      final nimField = find.byType(TextFormField).first;
      await tester.enterText(nimField, TestData.validNim);

      // Tap login
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error for password
      expect(find.text('Kata sandi tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show loading indicator during login', (tester) async {
      fakeLoginService.shouldSucceed = true;
      
      await tester.pumpWidget(createLoginScreen());

      // Fill fields
      final nimField = find.byType(TextFormField).first;
      await tester.enterText(nimField, TestData.validNim);

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, TestData.validPassword);

      // Tap login
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success message on successful login', (tester) async {
      fakeLoginService.shouldSucceed = true;

      await tester.pumpWidget(createLoginScreen());

      // Fill fields
      final nimField = find.byType(TextFormField).first;
      await tester.enterText(nimField, TestData.validNim);

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, TestData.validPassword);

      // Tap login
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Login berhasil'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show error message on login failure', (tester) async {
      const errorMessage = 'NIM atau password salah';
      fakeLoginService.shouldSucceed = false;
      fakeLoginService.errorMessage = errorMessage;

      await tester.pumpWidget(createLoginScreen());

      // Fill fields
      final nimField = find.byType(TextFormField).first;
      await tester.enterText(nimField, TestData.invalidNim);

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, TestData.invalidPassword);

      // Tap login
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should have two input fields', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify there are 2 input fields (NIM and Password)
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
    });
  });

  group('LoginController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          loginServiceProvider.overrideWithValue(fakeLoginService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be LoginState.initial()', () {
      final state = container.read(loginControllerProvider);
      expect(state, const LoginState.initial());
    });

    test('should emit loading and success states on successful login',
        () async {
      fakeLoginService.shouldSucceed = true;

      final states = <LoginState>[];
      container.listen<LoginState>(
        loginControllerProvider,
        (previous, next) => states.add(next),
      );

      await container
          .read(loginControllerProvider.notifier)
          .login(TestData.validNim, TestData.validPassword);

      expect(states, [
        const LoginState.loading(),
        const LoginState.success(),
      ]);
    });

    test('should emit loading and error states on failed login', () async {
      const errorMessage = 'NIM atau password salah';
      fakeLoginService.shouldSucceed = false;
      fakeLoginService.errorMessage = errorMessage;

      final states = <LoginState>[];
      container.listen<LoginState>(
        loginControllerProvider,
        (previous, next) => states.add(next),
      );

      await container
          .read(loginControllerProvider.notifier)
          .login(TestData.invalidNim, TestData.invalidPassword);

      expect(states.length, 2);
      expect(states[0], const LoginState.loading());
      expect(states[1], const LoginState.error(errorMessage));
    });

    test('should reset state to initial', () async {
      fakeLoginService.shouldSucceed = false;
      
      await container
          .read(loginControllerProvider.notifier)
          .login(TestData.validNim, TestData.validPassword);

      container.read(loginControllerProvider.notifier).resetState();

      final state = container.read(loginControllerProvider);
      expect(state, const LoginState.initial());
    });
  });
}
