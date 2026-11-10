/// Turns hour 18, minute 5 into "6:05 PM".
String formatTime(int hour, int minute) {
  return '${formatClock(hour, minute)} ${formatPeriod(hour)}';
}

/// Turns hour 18, minute 5 into "6:05" (no AM/PM).
String formatClock(int hour, int minute) {
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// "AM" or "PM".
String formatPeriod(int hour) => hour < 12 ? 'AM' : 'PM';

/// Turns a duration into text like "2h 15m", "45m" or "less than a minute".
String formatCountdown(Duration duration) {
  final totalMinutes = (duration.inSeconds / 60).ceil();
  if (totalMinutes < 1) return 'less than a minute';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Turns a date into text like "Monday, 9 November".
String formatDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
}
