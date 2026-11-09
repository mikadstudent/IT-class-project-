import 'package:flutter/material.dart';
 
class Alarm {
  final TimeOfDay time;
  final String label;
  bool isOn;
 
  Alarm({required this.time, required this.label, this.isOn = true});
}
