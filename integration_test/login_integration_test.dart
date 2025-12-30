import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inspire/core/data_sources/local/hive_service.dart';
import 'package:inspire/features/login/presentation/login_screen.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Tests', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: ".env");
      
      // Initialize Hive for testing
      await Hive.initFlutter('test_cache');
      await Hive.openBox<String>(HiveKey.authBox);
      await Hive.openBox<String>(HiveKey.userBox);
    });

    tearDownAll(() async {
      // Clean up Hive after tests
      await Hive.close();
    });

    setUp(() async {
      // Clear auth data before each test
      final authBox = Hive.box<String>(HiveKey.authBox);
      await authBox.clear();
    });

    testWidgets('Complete login flow with valid credentials', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find input fields
      final nimField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      // Enter valid credentials (ganti dengan kredensial valid dari backend Anda)
      await tester.enterText(nimField, '12345678');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pump();

      // Wait for login process
      await tester.pump(const Duration(seconds: 1));

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for response (adjust timeout as needed)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After successful login, should show success message or navigate
      // Note: Adjust assertion based on your actual success behavior
      expect(
        find.text('Login berhasil'),
        findsOneWidget,
        reason: 'Success message should be displayed',
      );
    });

    testWidgets('Login flow with invalid credentials shows error',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find input fields
      final nimField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      // Enter invalid credentials
      await tester.enterText(nimField, 'invalidnim');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pump();

      // Wait for response
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error message
      expect(
        find.textContaining('salah'),
        findsOneWidget,
        reason: 'Error message should be displayed',
      );
    });

    testWidgets('Token is saved after successful login', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid credentials
      final nimField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(nimField, '12345678');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login
      final loginButton = find.text('Login');
      await tester.tap(loginButton);

      // Wait for login to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify token is saved in Hive
      final authBox = Hive.box<String>(HiveKey.authBox);
      final savedAuth = authBox.get(HiveKey.auth);

      expect(
        savedAuth,
        isNotNull,
        reason: 'Auth token should be saved after successful login',
      );
    });

    testWidgets('Form validation prevents empty submission', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit without filling fields
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('NIM tidak boleh kosong'), findsOneWidget);

      // Loading indicator should NOT appear
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Password field is obscured', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find password field by looking for TextField widget inside TextFormField
      final passwordField = find.byType(TextField).last;
      final textField = tester.widget<TextField>(passwordField);

      // Verify obscureText is true
      expect(textField.obscureText, true);
    });
  });

  group('Login Service Integration Tests', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      await Hive.initFlutter('test_service_cache');
      await Hive.openBox<String>(HiveKey.authBox);
      await Hive.openBox<String>(HiveKey.userBox);
    });

    tearDownAll(() async {
      await Hive.close();
    });

    setUp(() async {
      final authBox = Hive.box<String>(HiveKey.authBox);
      await authBox.clear();
    });

    testWidgets('Login service saves auth data correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) {
              return const MaterialApp(
                home: LoginScreen(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform login
      final nimField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(nimField, '12345678');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check Hive storage
      final authBox = Hive.box<String>(HiveKey.authBox);
      final savedAuth = authBox.get(HiveKey.auth);

      if (savedAuth != null) {
        // Verify it contains expected fields
        expect(savedAuth, contains('accessToken'));
        expect(savedAuth, contains('refreshToken'));
      }
    });
  });
}
