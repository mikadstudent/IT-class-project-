# Scheduler (mobile version)

A scheduling app with **alarms** and **timed checklists**, designed for a phone screen.

## Features
- **Alarms:** ring at the set time with a looping sound and a full-screen style pop-up with Stop / Snooze 5 min.
- **Checklists:** each one has a time, a name, a list of tick boxes, and a Finish Checklist button.
- Everything is saved automatically. Swipe left to delete, with Undo.
- Light and dark mode.

## Run it
1. Open this folder in Android Studio (or VS Code).
2. Generate the platform files (one time only):
   ```
   flutter create --project-name scheduler_app --platforms=android .
   ```
3. Install packages:
   ```
   flutter pub get
   ```
4. Start an Android emulator (Device Manager) or plug in a phone with USB debugging, then:
   ```
   flutter run
   ```
   In Android Studio: pick the device in the toolbar and press the green Run button.

Already have a working Flutter project called `scheduler_app`? Copy `lib/`, `assets/`, `test/` and `pubspec.yaml` from this folder into it, then run `flutter pub get`.

## Notes
- The alarm sound and pop-up work while the app is open. There is no system notification yet, and nothing rings if the app is closed.
- The first Android build downloads Gradle files and can take several minutes.

## Project structure
```
lib/
  main.dart
  models/      alarm.dart, checklist.dart
  screens/     home, checklist (+ form), alarms (+ form)
  services/    alarm_service.dart, storage_service.dart
  theme/       app_theme.dart
  utils/       time_format.dart
  widgets/     app_widgets.dart, ringing_dialog.dart
assets/alarm.wav
```
