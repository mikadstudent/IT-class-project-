import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Desktop notifications through the browser's Notification API.
class Notifier {
  /// 'granted', 'denied', 'default' or 'unsupported'
  static String get permission {
    try {
      return web.Notification.permission;
    } catch (e) {
      return 'unsupported';
    }
  }

  static Future<String> requestPermission() async {
    try {
      final result = await web.Notification.requestPermission().toDart;
      return result.toDart;
    } catch (e) {
      return 'unsupported';
    }
  }

  static void show(String title, String body) {
    try {
      if (web.Notification.permission == 'granted') {
        web.Notification(title, web.NotificationOptions(body: body));
      }
    } catch (e) {
      // Notifications are not available; the in-app alarm still rings.
    }
  }
}
