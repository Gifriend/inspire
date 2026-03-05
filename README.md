# inspire

Mobile Flutter application for a student final project (Thesis).

Overview:

inspire is a Flutter-based mobile app that combines e-learning features, attendance submission, profile management, and Google Sign-In integration (including Classroom OAuth). It was developed as a student thesis project and follows a modular architecture using Riverpod for state management, Freezed for immutable models, and Dio for HTTP communication.

Key features:

- Elearning: quizzes, assignment submissions, and content viewing.
- Attendance (Presensi): submit session tokens/IDs to the backend.
- Authentication: Google Sign-In with best-effort revoke/disconnect support for Classroom.
- Profile: role-aware profile UI for students and lecturers, with unified logout.

Architecture & technologies:

- Flutter (Dart)
- State management: Riverpod
- Models: Freezed + json_serializable
- HTTP client: Dio with a `DioClient` wrapper
- Backend: communicates with an API (server implemented with NestJS) using client-side DTOs

Requirements:

- Flutter SDK (prefer stable)
- Android Studio or Xcode for device/emulator builds
- Google API credentials if enabling Google Sign-In / Classroom integration

Local setup:

1. Install dependencies:

```bash
flutter pub get
```

2. Run code generation for Freezed / json_serializable / generated providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Environment configuration:

- Make sure `google-services.json` (Android) is present under `app/` if using Firebase/Google Sign-In.
- Set `GOOGLE_WEB_CLIENT_ID` or other related environment variables in `lib/core/config` or your chosen env configuration.

Running the app:

```bash
flutter run
```

Running tests:

```bash
flutter test

# For integration tests
flutter drive --driver=integration_test_driver.dart --target=integration_test/login_integration_test.dart
```

Project structure (summary):

- `lib/`
	- `core/` : common configuration, models, and services (e.g. `google_auth_service.dart`, `dio_client`)
	- `features/` : feature modules such as `elearning`, `presensi`, `profile`, `login`, etc.
	- `main.dart` : application entry point

Notes & important details:

- Models and providers are generated via `build_runner`; run codegen after modifying Freezed models.
- Ensure the backend API matches the DTOs expected by the client (for example, `submitQuiz` expects `{ quizId, answers: [...] }`).
- Google/Classroom logout uses a best-effort revoke/disconnect implementation in `lib/core/services/google_auth_service.dart`; ensure credentials are configured correctly.

Contributing:

- Open an issue or fork the repository, create a feature/bugfix branch, and submit a pull request with a clear description of changes.

Contact:

For questions or backend integration assistance, contact the project author or repository maintainer.
