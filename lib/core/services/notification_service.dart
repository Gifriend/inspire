import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 1. Handler untuk Background (Harus fungsi Top-Level, di luar class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Menangani pesan background: ${message.messageId}");
}

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Setup Local Notification (agar muncul saat app dibuka)
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    try {
      // 2. Request Permission
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true)
          .timeout(const Duration(seconds: 5)); // Proteksi timeout

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User mengizinkan notifikasi');

        // 3. Ambil FCM Token dengan proteksi Error
        try {
          final fcmToken = await _firebaseMessaging.getToken().timeout(
            const Duration(seconds: 10),
          );
          print('=======================================');
          print('FCM TOKEN: $fcmToken');
          print('=======================================');
        } catch (e) {
          // Jika gagal ambil token, cetak error tapi JANGAN hentikan aplikasi
          print('Gagal mengambil FCM Token: $e');
        }

        // 4. Setup Local Notification Channel
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.max,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);

        // 5. Listeners
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          final android = message.notification?.android;

          if (notification != null && android != null) {
            _localNotifications.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Error umum pada NotificationService: $e");
      // Aplikasi tetap lanjut ke runApp() karena error sudah ditangkap
    }
  }
}
