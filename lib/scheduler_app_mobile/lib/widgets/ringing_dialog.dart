import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';

/// The popup shown while an alarm is ringing.
class RingingDialog extends StatefulWidget {
  final Alarm alarm;

  const RingingDialog({super.key, required this.alarm});

  @override
  State<RingingDialog> createState() => _RingingDialogState();
}

class _RingingDialogState extends State<RingingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _stop() {
    AlarmService.instance.stopRinging();
    Navigator.pop(context);
  }

  void _snooze() {
    AlarmService.instance.snooze(widget.alarm);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isTest = widget.alarm.id == 'test';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: const Icon(Icons.alarm, size: 72, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.alarm.timeText,
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.alarm.label,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.gradientStart,
                ),
                onPressed: _stop,
                child: const Text('Stop'),
              ),
            ),
            if (!isTest)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: _snooze,
                child: const Text('Snooze 5 min'),
              ),
          ],
        ),
      ),
    );
  }
}
