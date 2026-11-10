import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';
import '../utils/time_format.dart';
import '../widgets/app_widgets.dart';
import 'alarm_form_screen.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final AlarmService _service = AlarmService.instance;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _service.addListener(_refresh);
    // Refresh the "rings in ..." text every 30 seconds.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    _clock?.cancel();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// Opens the form. With no argument it creates a new alarm;
  /// with an alarm it edits that one (the data goes in through the constructor).
  Future<void> _openForm([Alarm? existing]) async {
    final Alarm? result = await Navigator.push<Alarm>(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmFormScreen(alarm: existing),
      ),
    );
    if (!mounted || result == null) return;

    if (existing == null) {
      await _service.addAlarm(result);
    } else {
      await _service.updateAlarm(result);
    }
  }

  Future<void> _deleteAlarm(Alarm alarm) async {
    await _service.deleteAlarm(alarm);
    if (!mounted) return;
    showAppSnack(
      context,
      'Alarm deleted',
      actionLabel: 'Undo',
      onAction: () {
        _service.addAlarm(alarm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final alarms = _service.alarms;

    return Scaffold(
      appBar: buildAppBar(
        'Alarms',
        actions: [
          IconButton(
            tooltip: 'Test alarm sound',
            icon: const Icon(Icons.volume_up),
            onPressed: () => _service.testRing(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_alarm),
        label: const Text('New Alarm'),
      ),
      body: alarms.isEmpty
          ? const EmptyState(
              icon: Icons.alarm,
              title: 'No alarms yet',
              message: 'Add an alarm and it will ring with a sound.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: alarms.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildNextAlarmSummary();
                final alarm = alarms[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey(alarm.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteAlarm(alarm),
                    background: _buildSwipeBackground(),
                    child: _buildAlarmTile(alarm),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNextAlarmSummary() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final next = _service.nextAlarm?.nextRing;

    final String text;
    if (next == null) {
      text = 'No active alarms';
    } else {
      text =
          'Next alarm rings in ${formatCountdown(next.difference(DateTime.now()))}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        color: scheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.schedule, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(Icons.delete, color: scheme.onError),
    );
  }

  Widget _buildAlarmTile(Alarm alarm) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final on = alarm.isOn;
    final next = alarm.nextRing;

    final String status;
    if (!on) {
      status = 'Off';
    } else if (next == null) {
      status = 'On';
    } else {
      status = 'Rings in ${formatCountdown(next.difference(DateTime.now()))}';
    }

    final Color? timeColor = on ? null : scheme.onSurfaceVariant;

    return AppCard(
      onTap: () => _openForm(alarm),
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: formatClock(alarm.hour, alarm.minute),
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: timeColor,
                        ),
                      ),
                      TextSpan(
                        text: ' ${formatPeriod(alarm.hour)}',
                        style: textTheme.titleMedium?.copyWith(color: timeColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${alarm.label} · $status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: on,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              _service.setAlarmOn(alarm, value);
            },
          ),
          IconButton(
            tooltip: 'Delete alarm',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteAlarm(alarm),
          ),
        ],
      ),
    );
  }
}
