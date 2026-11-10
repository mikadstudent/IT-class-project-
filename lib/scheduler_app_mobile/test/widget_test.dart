import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler_app/utils/time_format.dart';

void main() {
  test('formatTime shows 12-hour time with AM/PM', () {
    expect(formatTime(18, 5), '6:05 PM');
    expect(formatTime(0, 0), '12:00 AM');
    expect(formatTime(12, 30), '12:30 PM');
  });

  test('formatCountdown shows hours and minutes', () {
    expect(formatCountdown(const Duration(minutes: 135)), '2h 15m');
    expect(formatCountdown(const Duration(minutes: 45)), '45m');
    expect(formatCountdown(const Duration(seconds: 10)), '1m');
    expect(formatCountdown(Duration.zero), 'less than a minute');
  });
}
