import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../widgets/app_widgets.dart';

/// Used for both creating a new alarm (alarm == null)
/// and editing an existing one (alarm is passed in).
class AlarmFormScreen extends StatefulWidget {
  final Alarm? alarm;

  const AlarmFormScreen({super.key, this.alarm});

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  static const List<String> _suggestions = [
    'Wake up',
    'Take medicine',
    'Study',
    'Meeting',
    'Workout',
  ];

  late final TextEditingController _labelController;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    final existing = widget.alarm;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _time = existing?.time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (!mounted || picked == null) return;
    setState(() {
      _time = picked;
    });
  }

  void _useSuggestion(String text) {
    _labelController.text = text;
    _labelController.selection = TextSelection.collapsed(offset: text.length);
  }

  void _save() {
    final label = _labelController.text.trim();
    final alarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _time.hour,
      minute: _time.minute,
      label: label.isEmpty ? 'Alarm' : label,
    );
    Navigator.pop(context, alarm);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.alarm != null;

    return Scaffold(
      appBar: buildAppBar(isEditing ? 'Edit Alarm' : 'New Alarm'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TimeBlock(hour: _time.hour, minute: _time.minute, onTap: _pickTime),
          const SizedBox(height: 16),
          TextField(
            controller: _labelController,
            textCapitalization: TextCapitalization.sentences,
            decoration: appInputDecoration(
              context,
              label: 'Label (optional)',
              hint: 'e.g. Take medicine',
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in _suggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () => _useSuggestion(suggestion),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save alarm'),
            ),
          ),
        ],
      ),
    );
  }
}
