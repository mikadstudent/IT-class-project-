/// Used on platforms without browser notifications (does nothing).
class Notifier {
  /// 'granted', 'denied', 'default' or 'unsupported'
  static String get permission => 'unsupported';

  static Future<String> requestPermission() async => 'unsupported';

  static void show(String title, String body) {}
}
