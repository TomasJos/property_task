

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'web_notification_helper_stub.dart'
if (dart.library.html) 'web_notification_helper.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (!kIsWeb) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      const init = InitializationSettings(android: android, iOS: ios);
      await _plugin.initialize(init);
    }
  }

  Future<void> showSimple(String title, String body) async {
    if (kIsWeb) {
      showWebNotification(title, body);
    } else {
      const android = AndroidNotificationDetails(
        'default',
        'General',
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      const details = NotificationDetails(android: android, iOS: ios);
      await _plugin.show(0, title, body, details);
    }
  }
}
