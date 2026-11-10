import 'package:flutter/material.dart';
import '../utils/time_format.dart';

class Alarm {
  final String id;
  final int hour;
  final int minute;
  final String label;
  bool isOn;

  /// Not saved. The next moment this alarm should ring.
  DateTime? nextRing;

  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    this.isOn = true,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get timeText => formatTime(hour, minute);

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'isOn': isOn,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String,
      isOn: json['isOn'] as bool,
    );
  }
}
