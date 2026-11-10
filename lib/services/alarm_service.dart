import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm.dart';
import 'notifier.dart';
import 'storage_service.dart';

/// Keeps the list of alarms and checks the clock every second.
/// When an alarm is due it plays a sound and shows a notification.
class AlarmService extends ChangeNotifier {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  final List<Alarm> alarms = [];

  /// The alarm that is ringing right now (null when quiet).
  Alarm? ringingAlarm;

  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;

  Future<void> init() async {
    final saved = await StorageService.loadAlarms();
    alarms
      ..clear()
      ..addAll(saved);
    for (final alarm in alarms) {
      _schedule(alarm);
    }
    _sortAlarms();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  /// Works out the next time this alarm should ring.
  void _schedule(Alarm alarm) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, alarm.hour, alarm.minute);
    }
    alarm.nextRing = next;
  }

  void _sortAlarms() {
    alarms.sort(
      (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
    );
  }

  void _tick() {
    if (ringingAlarm != null) return;

    final now = DateTime.now();
    for (final alarm in alarms) {
      final next = alarm.nextRing;
      if (alarm.isOn && next != null && !now.isBefore(next)) {
        final lateBy = now.difference(next);
        _schedule(alarm); // ring again tomorrow
        if (lateBy.inMinutes < 5) {
          _ring(alarm);
          return;
        }
      }
    }
  }

  Future<void> _ring(Alarm alarm) async {
    ringingAlarm = alarm;
    notifyListeners();

    Notifier.show('Alarm ${alarm.timeText}', alarm.label);

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('alarm.wav'));
    } catch (e) {
      debugPrint('Could not play the alarm sound: $e');
    }
  }

  Future<void> stopRinging() async {
    ringingAlarm = null;
    notifyListeners();
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Could not stop the alarm sound: $e');
    }
  }

  /// The active alarm that will ring soonest (null if none).
  Alarm? get nextAlarm {
    Alarm? best;
    for (final alarm in alarms) {
      final next = alarm.nextRing;
      if (!alarm.isOn || next == null) continue;
      final bestNext = best?.nextRing;
      if (bestNext == null || next.isBefore(bestNext)) {
        best = alarm;
      }
    }
    return best;
  }

  /// Stops the sound and makes the alarm ring again after a few minutes.
  Future<void> snooze(Alarm alarm, {int minutes = 5}) async {
    alarm.nextRing = DateTime.now().add(Duration(minutes: minutes));
    await stopRinging();
  }

  /// Rings right now so you can check the sound and notification.
  Future<void> testRing() async {
    if (ringingAlarm != null) return;
    final now = DateTime.now();
    await _ring(
      Alarm(id: 'test', hour: now.hour, minute: now.minute, label: 'Test alarm'),
    );
  }

  Future<void> addAlarm(Alarm alarm) async {
    _schedule(alarm);
    alarms.add(alarm);
    _sortAlarms();
    notifyListeners();
    await StorageService.saveAlarms(alarms);
  }

  Future<void> updateAlarm(Alarm updated) async {
    final index = alarms.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _schedule(updated);
    alarms[index] = updated;
    _sortAlarms();
    notifyListeners();
    await StorageService.saveAlarms(alarms);
  }

  Future<void> setAlarmOn(Alarm alarm, bool value) async {
    alarm.isOn = value;
    if (value) _schedule(alarm);
    notifyListeners();
    await StorageService.saveAlarms(alarms);
  }

  Future<void> deleteAlarm(Alarm alarm) async {
    alarms.removeWhere((a) => a.id == alarm.id);
    notifyListeners();
    await StorageService.saveAlarms(alarms);
  }
}
