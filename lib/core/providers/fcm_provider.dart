import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Provider untuk menyimpan FCM Token
final fcmTokenProvider = StateProvider<String?>((ref) => null);

/// Provider untuk mendapatkan FCM Token
final fcmTokenFutureProvider = FutureProvider<String?>((ref) async {
  final token = await FirebaseMessaging.instance.getToken();
  
  // Update state provider
  if (token != null) {
    ref.read(fcmTokenProvider.notifier).state = token;
  }
  
  return token;
});

/// Provider untuk refresh FCM Token
final refreshFcmTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  final token = await FirebaseMessaging.instance.getToken();
  
  if (token != null) {
    ref.read(fcmTokenProvider.notifier).state = token;
  }
  
  return token;
});
