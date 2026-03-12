import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:inspire/core/routing/app_routing.dart';

/// Handler for background messages — must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance = FirebaseNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Channel ID — must match AndroidManifest.xml meta-data
  static const String _channelId = 'inspire_notifications';
  static const String _channelName = 'Inspire Notifications';
  static const String _channelDesc = 'Notifikasi dari aplikasi Inspire';

  /// Initialize Firebase Messaging & local notification plugin
  Future<void> initialize() async {
    try {
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request permission (Android 13+ and iOS)
      await _requestPermission();

      // Setup local notifications for foreground display
      await _initLocalNotifications();

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background (not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app was terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Print FCM token for testing
      final token = await getToken();
      debugPrint('[FCM] Device token: $token');
    } catch (e) {
      debugPrint('[FCM] Initialization failed (Play Services not available?): $e');
    }
  }

  /// Request notification permission from user
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  /// Initialize flutter_local_notifications
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Show local notification when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      final targetRoute = _resolveRoute(message.data['route']?.toString());
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: targetRoute,
      );
    }
  }

  /// Handle notification tap (payload = route string, e.g. '/elearning')
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    final targetRoute = _resolveRoute(message.data['route']?.toString());
    if (targetRoute == null) return;
    _navigateToRoute(targetRoute);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Local notification tapped: ${response.payload}');
    final targetRoute = _resolveRoute(response.payload);
    if (targetRoute == null) return;
    _navigateToRoute(targetRoute);
  }

  String? _resolveRoute(String? rawRoute) {
    if (rawRoute == null || rawRoute.trim().isEmpty) {
      return null;
    }

    final cleaned = rawRoute.trim();

    if (cleaned.startsWith('/')) {
      return cleaned;
    }

    final normalized = cleaned.toLowerCase();
    switch (normalized) {
      case 'announcement':
      case 'announcements':
      case 'pengumuman':
        return '/announcement';
      case 'elearning':
      case 'e-learning':
        return '/elearning';
      case 'classroom':
      case 'google-classroom':
        return '/classroom-student';
      case 'schedule':
      case 'jadwal':
        return '/schedule';
      case 'khs':
        return '/khs';
      case 'transcript':
      case 'transkrip':
        return '/transcript';
      default:
        return '/$cleaned';
    }
  }

  void _navigateToRoute(String route, {int attempt = 0}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(route);
      debugPrint('[FCM] Navigated to: $route');
      return;
    }

    if (attempt >= 8) {
      debugPrint('[FCM] Gagal navigate, context belum tersedia: $route');
      return;
    }

    Future<void>.delayed(
      const Duration(milliseconds: 300),
      () => _navigateToRoute(route, attempt: attempt + 1),
    );
  }

  /// Get current FCM device token — send this to your backend to target notifications
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[FCM] Failed to get token: $e');
      return null;
    }
  }

  /// Subscribe to a topic (e.g. role-based: 'dosen', 'mahasiswa')
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('[FCM] Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('[FCM] Unsubscribed from topic: $topic');
  }
}
