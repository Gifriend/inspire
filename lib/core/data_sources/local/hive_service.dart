import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'local.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  static bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await hiveInit();
    _initialized = true;
  }

  // Box<String> get _userSource => Hive.box<String>(HiveKey.userBox);
  Box<String> get _authSource => Hive.box<String>(HiveKey.authBox);
  Box<String> get _presensiHistorySource =>
      Hive.box<String>(HiveKey.presensiHistoryBox);

  Future<AuthData?> getAuth() async {
    await ensureInitialized();
    _ensureAuthBox();
    final auth = _authSource.get(HiveKey.auth);

    if (auth == null) {
      dev.log("[HIVE SERVICE] access token not saved");
      return null;
    }

    return AuthData.fromJson(json.decode(auth));
  }

  Future saveAuth(AuthData value) async {
    await ensureInitialized();
    _ensureAuthBox();
    await _authSource.put(HiveKey.auth, json.encode(value.toJson()));
  }

  Future deleteAuth() async {
    await ensureInitialized();
    _ensureAuthBox();
    await _authSource.delete(HiveKey.auth);
  }

  Future<String?> getPresensiHistory(String key) async {
    await ensureInitialized();
    _ensurePresensiHistoryBox();
    return _presensiHistorySource.get(key);
  }

  Future<void> savePresensiHistory(String key, String value) async {
    await ensureInitialized();
    _ensurePresensiHistoryBox();
    await _presensiHistorySource.put(key, value);
  }

  void _ensureAuthBox() {
    if (!Hive.isBoxOpen(HiveKey.authBox)) {
      throw Exception('Box auth belum dibuka. Pastikan hiveInit() sudah dipanggil.');
    }
  }

  void _ensurePresensiHistoryBox() {
    if (!Hive.isBoxOpen(HiveKey.presensiHistoryBox)) {
      throw Exception(
        'Box presensi history belum dibuka. Pastikan hiveInit() sudah dipanggil.',
      );
    }
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.userBox);
  await Hive.openBox<String>(HiveKey.presensiHistoryBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}

class HiveKey {
  static const String userBox = 'userBox';
  static const String user = 'user';

  static const String authBox = 'authBox';
  static const String auth = 'auth';

  static const String presensiHistoryBox = 'presensiHistoryBox';

}


//
// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });
//
