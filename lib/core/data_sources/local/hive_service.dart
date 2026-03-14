import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inspire/core/models/user/user_model.dart';

import 'local.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  static bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await hiveInit();
    _initialized = true;
  }

  Box<String> get _userSource => Hive.box<String>(HiveKey.userBox);
  Box<String> get _authSource => Hive.box<String>(HiveKey.authBox);
  Box<String> get _presensiHistorySource =>
      Hive.box<String>(HiveKey.presensiHistoryBox);
  Box<String> get _cacheSource => Hive.box<String>(HiveKey.cacheBox);

  Future<UserModel?> getUser() async {
    await ensureInitialized();
    _ensureUserBox();

    final raw = _userSource.get(HiveKey.user);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = json.decode(raw);
    if (decoded is Map<String, dynamic>) {
      return UserModel.fromJson(decoded);
    }
    if (decoded is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(decoded));
    }

    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await ensureInitialized();
    _ensureUserBox();
    await _userSource.put(HiveKey.user, json.encode(user.toJson()));
  }

  Future<void> deleteUser() async {
    await ensureInitialized();
    _ensureUserBox();
    await _userSource.delete(HiveKey.user);
  }

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

  Future<Map<String, dynamic>?> getCacheMap(String key) async {
    await ensureInitialized();
    _ensureCacheBox();
    final cachedValue = _cacheSource.get(key);

    if (cachedValue == null || cachedValue.isEmpty) {
      return null;
    }

    final decoded = json.decode(cachedValue);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  Future<void> saveCacheMap(String key, Map<String, dynamic> value) async {
    await ensureInitialized();
    _ensureCacheBox();
    await _cacheSource.put(key, json.encode(value));
  }

  Future<void> deleteCache(String key) async {
    await ensureInitialized();
    _ensureCacheBox();
    await _cacheSource.delete(key);
  }

  void _ensureAuthBox() {
    if (!Hive.isBoxOpen(HiveKey.authBox)) {
      throw Exception('Box auth belum dibuka. Pastikan hiveInit() sudah dipanggil.');
    }
  }

  void _ensureUserBox() {
    if (!Hive.isBoxOpen(HiveKey.userBox)) {
      throw Exception('Box user belum dibuka. Pastikan hiveInit() sudah dipanggil.');
    }
  }

  void _ensurePresensiHistoryBox() {
    if (!Hive.isBoxOpen(HiveKey.presensiHistoryBox)) {
      throw Exception(
        'Box presensi history belum dibuka. Pastikan hiveInit() sudah dipanggil.',
      );
    }
  }

  void _ensureCacheBox() {
    if (!Hive.isBoxOpen(HiveKey.cacheBox)) {
      throw Exception(
        'Box cache belum dibuka. Pastikan hiveInit() sudah dipanggil.',
      );
    }
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.userBox);
  await Hive.openBox<String>(HiveKey.presensiHistoryBox);
  await Hive.openBox<String>(HiveKey.cacheBox);
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

  static const String cacheBox = 'cacheBox';

}


//
// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });
//
