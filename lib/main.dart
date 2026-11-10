import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/alarm_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved alarms and start the clock check before the app appears.
  await AlarmService.instance.init();
  runApp(const SchedulerApp());
}

class SchedulerApp extends StatelessWidget {
  const SchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scheduler',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // Phone-first layout: on a wide screen (like Chrome) the app stays
      // in a centered, phone-width column.
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
