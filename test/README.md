# Login Testing Scripts

## Widget Tests (Unit Tests)
Menjalankan widget test tanpa emulator:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/login/login_screen_test.dart

# Run with coverage
flutter test --coverage

# View coverage report (requires genhtml)
genhtml coverage/lcov.info -o coverage/html
```

## Integration Tests
Menjalankan integration test dengan backend yang nyala:

### Persiapan:
1. Pastikan backend API sudah running di URL yang ada di .env
2. Pastikan ada user test dengan credentials:
   - NIM: 12345678
   - Password: password123

### Menjalankan Integration Test:

```bash
# Tanpa emulator (headless)
flutter test integration_test/login_integration_test.dart

# Dengan Chrome (web)
flutter test integration_test/login_integration_test.dart -d chrome

# Dengan emulator/device yang terhubung
flutter test integration_test/login_integration_test.dart -d <device_id>
```

## Generate Mock Classes
Jika ada perubahan pada interface yang di-mock:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing Checklist

### Widget Tests ✅
- [x] Display all UI elements
- [x] Validate empty NIM field
- [x] Validate empty password field
- [x] Call login service with valid inputs
- [x] Show loading indicator during login
- [x] Show error message on failure
- [x] Password field is obscured
- [x] NIM field has number keyboard

### Controller Tests ✅
- [x] Initial state is correct
- [x] Emit loading and success states
- [x] Emit loading and error states
- [x] Reset state functionality

### Integration Tests ✅
- [x] Complete login flow with valid credentials
- [x] Login with invalid credentials shows error
- [x] Token is saved after successful login
- [x] Form validation prevents empty submission
- [x] Password field is obscured
- [x] Login service saves auth data correctly

## Test Coverage Commands

```bash
# Generate coverage
flutter test --coverage

# Filter coverage to only lib files
lcov --remove coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.freezed.dart' -o coverage/lcov_filtered.info

# Generate HTML report
genhtml coverage/lcov_filtered.info -o coverage/html

# Open in browser
start coverage/html/index.html  # Windows
open coverage/html/index.html   # macOS
xdg-open coverage/html/index.html  # Linux
```

## Troubleshooting

### Test Gagal Koneksi ke Backend
- Pastikan backend running di URL yang benar
- Check .env file: BASE_URL=https://zpzbzpbq-3333.asse.devtunnels.ms
- Pastikan tidak ada firewall yang blocking

### Hive Error
- Hapus folder test_cache jika ada error
- Restart test

### Mock Generation Gagal
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```
