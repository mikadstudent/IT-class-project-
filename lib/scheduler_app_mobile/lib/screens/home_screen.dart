import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../models/checklist.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import '../widgets/app_widgets.dart';
import '../widgets/ringing_dialog.dart';
import 'alarms_screen.dart';
import 'checklist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dialogOpen = false;
  List<Checklist> _checklists = [];
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // The Home screen is always at the bottom of the stack, so it can show
    // the "alarm is ringing" popup on top of whatever screen is open.
    AlarmService.instance.addListener(_onAlarmChanged);
    _loadChecklists();
    // Refresh the "in 2h 15m" text every 30 seconds.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    AlarmService.instance.removeListener(_onAlarmChanged);
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _loadChecklists() async {
    final saved = await StorageService.loadChecklists();
    if (!mounted) return;
    setState(() {
      _checklists = saved;
    });
  }

  void _onAlarmChanged() {
    if (!mounted) return;
    setState(() {});
    final alarm = AlarmService.instance.ringingAlarm;
    if (alarm != null && !_dialogOpen) {
      _showRingingDialog(alarm);
    }
  }

  Future<void> _showRingingDialog(Alarm alarm) async {
    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RingingDialog(alarm: alarm),
    );
    _dialogOpen = false;
  }

  /// Opens a screen, then refreshes the summary when coming back.
  Future<void> _open(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (!mounted) return;
    _loadChecklists();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextAlarm = AlarmService.instance.nextAlarm;
    final activeAlarms =
        AlarmService.instance.alarms.where((a) => a.isOn).length;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNextAlarmCard(nextAlarm),
                const SizedBox(height: 12),
                _buildProgressCard(),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildNavTile(
                        icon: Icons.checklist,
                        title: 'Checklists',
                        subtitle:
                            '${_checklists.length} ${_checklists.length == 1 ? 'list' : 'lists'}',
                        screen: const ChecklistScreen(),
                        background: scheme.secondaryContainer,
                        foreground: scheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNavTile(
                        icon: Icons.alarm,
                        title: 'Alarms',
                        subtitle: '$activeAlarms active',
                        screen: const AlarmsScreen(),
                        background: scheme.tertiaryContainer,
                        foreground: scheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 28, 24, 32),
      decoration: const BoxDecoration(
        gradient: AppTheme.gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            formatDate(DateTime.now()),
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay on top of your day',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAlarmCard(Alarm? alarm) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Widget details;
    if (alarm == null) {
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No alarms set',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Tap to add one',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    } else {
      final next = alarm.nextRing;
      final countdown = next == null
          ? ''
          : ' · in ${formatCountdown(next.difference(DateTime.now()))}';
      details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alarm.timeText,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${alarm.label}$countdown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return AppCard(
      onTap: () => _open(const AlarmsScreen()),
      child: Row(
        children: [
          _IconBadge(icon: Icons.alarm),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next alarm',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                details,
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total = _checklists.fold<int>(0, (sum, c) => sum + c.items.length);
    final done = _checklists.fold<int>(0, (sum, c) => sum + c.doneCount);
    final finishedLists = _checklists.where((c) => c.isFinished).length;
    final progress = total == 0 ? 0.0 : done / total;

    return AppCard(
      onTap: () => _open(const ChecklistScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: Icons.checklist),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task progress',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      total == 0
                          ? 'No checklists yet'
                          : '$done of $total tasks done',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Text(
                  '${(progress * 100).round()}%',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            AnimatedProgressBar(value: progress),
            const SizedBox(height: 8),
            Text(
              '$finishedLists of ${_checklists.length} checklists finished',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
    required Color background,
    required Color foreground,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => _open(screen),
      color: background,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: foreground),
          const SizedBox(height: 24),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: scheme.onPrimaryContainer),
    );
  }
}
