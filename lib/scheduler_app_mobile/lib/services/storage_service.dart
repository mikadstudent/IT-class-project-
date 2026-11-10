import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../models/checklist.dart';

/// Saves and loads data so it is still there next time the app opens.
class StorageService {
  static const String _alarmsKey = 'alarms';
  static const String _checklistsKey = 'checklists';

  static Future<List<Alarm>> loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_alarmsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Alarm.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If saved data is unreadable, start with an empty list.
      return [];
    }
  }

  static Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_alarmsKey, raw);
  }

  static Future<List<Checklist>> loadChecklists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_checklistsKey);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Checklist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveChecklists(List<Checklist> checklists) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(checklists.map((c) => c.toJson()).toList());
    await prefs.setString(_checklistsKey, raw);
  }
}
