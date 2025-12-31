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

  void _ensureAuthBox() {
    if (!Hive.isBoxOpen(HiveKey.authBox)) {
      throw Exception('Box auth belum dibuka. Pastikan hiveInit() sudah dipanggil.');
    }
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter('cache');
  await Hive.openBox<String>(HiveKey.authBox);
  await Hive.openBox<String>(HiveKey.userBox);
}

Future<void> hiveClose() async {
  await Hive.close();
}

class HiveKey {
  static const String userBox = 'userBox';
  static const String user = 'user';

  static const String authBox = 'authBox';
  static const String auth = 'auth';

}


//
// final hiveServiceProvider = Provider<HiveService>((ref) {
//   return HiveService();
// });
//
