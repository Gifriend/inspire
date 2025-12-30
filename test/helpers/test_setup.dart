import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inspire/core/data_sources/local/hive_service.dart';

Future<void> setupTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for testing
  await Hive.initFlutter('test_hive');
  
  // Open boxes if not already open
  if (!Hive.isBoxOpen(HiveKey.authBox)) {
    await Hive.openBox<String>(HiveKey.authBox);
  }
  if (!Hive.isBoxOpen(HiveKey.userBox)) {
    await Hive.openBox<String>(HiveKey.userBox);
  }
}

Future<void> cleanupTestEnvironment() async {
  // Clear all boxes
  final authBox = Hive.box<String>(HiveKey.authBox);
  final userBox = Hive.box<String>(HiveKey.userBox);
  
  await authBox.clear();
  await userBox.clear();
  
  // Close Hive
  await Hive.close();
}
