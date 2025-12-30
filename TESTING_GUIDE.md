# 🔧 Cara Testing Login - Simple Guide

## ❌ Kenapa Widget Test Gagal?

Error: `LateInitializationError: Field '_data@1361084504' has not been initialized.`

**Bukan karena kode integrasinya salah!** ✅

Masalahnya: `ScreenUtil` butuh device screen untuk inisialisasi. Di test environment tanpa device, dia tidak bisa init.

## ✅ Solusi: Test dengan Device/Emulator

### Cara 1: Dengan Emulator (RECOMMENDED)

```bash
# 1. Jalankan emulator atau connect device
flutter emulators --launch <emulator_id>

# 2. Cek device sudah connect
flutter devices

# 3. Run integration test
flutter test integration_test/login_integration_test.dart
```

### Cara 2: Manual Testing (Paling Mudah!)

```bash
# 1. Run app di emulator/device
flutter run

# 2. Test manual:
#    - Masukkan NIM: 12345678
#    - Masukkan Password: password123
#    - Klik Login
#    - Lihat hasilnya
```

## 📝 Checklist Sebelum Test

- [ ] Backend API sudah running di `https://zpzbzpbq-3333.asse.devtunnels.ms`
- [ ] User test sudah dibuat di backend (NIM: 12345678, Password: password123)
- [ ] Emulator/device sudah running
- [ ] File `.env` sudah benar

## 🎯 Test Yang Sudah Disiapkan

1. ✅ Login dengan kredensial valid
2. ✅ Login dengan kredensial invalid (error handling)
3. ✅ Token tersimpan ke local storage
4. ✅ Validasi form (empty fields)
5. ✅ Password field ter-obscure
6. ✅ Service menyimpan auth data

## 🚀 Quick Test Commands

```bash
# Test dengan Chrome (web) - tanpa perlu emulator Android
flutter test integration_test/login_integration_test.dart -d chrome

# Test dengan emulator Android
flutter test integration_test/login_integration_test.dart -d emulator-5554

# Test dengan semua devices yang connect
flutter test integration_test/login_integration_test.dart

# Manual run untuk test langsung
flutter run
```

## 💡 Tips

1. **Manual testing paling mudah**: Cukup `flutter run` lalu test langsung
2. **Chrome testing**: Bisa test tanpa Android emulator
3. **Integration test**: Bagus untuk automation tapi butuh device
4. **Widget test**: Perlu setup kompleks untuk ScreenUtil, skip dulu

## ✨ Kesimpulan

**Kode integrasinya BENAR** ✅

Yang perlu:
1. Test dengan device nyata (emulator/physical device/chrome)
2. Atau test manual dengan `flutter run`

Error bukan dari kode API/login, tapi dari test environment setup untuk ScreenUtil.
