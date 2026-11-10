import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../widgets/app_widgets.dart';

/// Used for both creating a new checklist (checklist == null)
/// and editing an existing one (checklist is passed in).
class ChecklistFormScreen extends StatefulWidget {
  final Checklist? checklist;

  const ChecklistFormScreen({super.key, this.checklist});

  @override
  State<ChecklistFormScreen> createState() => _ChecklistFormScreenState();
}

class _ChecklistFormScreenState extends State<ChecklistFormScreen> {
  late final TextEditingController _titleController;
  final TextEditingController _itemController = TextEditingController();
  final FocusNode _itemFocus = FocusNode();
  late TimeOfDay _time;
  late List<TodoItem> _items;

  @override
  void initState() {
    super.initState();
    final existing = widget.checklist;
    _titleController = TextEditingController(text: existing?.title ?? '');
    if (existing != null) {
      _time = TimeOfDay(hour: existing.hour, minute: existing.minute);
      // Copy the items so changes only apply when the user taps Save.
      _items = existing.items
          .map((item) => TodoItem(text: item.text, isDone: item.isDone))
          .toList();
    } else {
      _time = TimeOfDay.now();
      _items = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _itemFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (!mounted || picked == null) return;
    setState(() {
      _time = picked;
    });
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isEmpty) {
      showAppSnack(context, 'Please type an item first');
      return;
    }
    setState(() {
      _items.add(TodoItem(text: text));
      _itemController.clear();
    });
    _itemFocus.requestFocus();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showAppSnack(context, 'Please enter a checklist name');
      return;
    }
    if (_items.isEmpty) {
      showAppSnack(context, 'Add at least one item');
      return;
    }

    final existing = widget.checklist;
    final allDone = _items.every((item) => item.isDone);

    final result = Checklist(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      hour: _time.hour,
      minute: _time.minute,
      items: _items,
      isFinished: (existing?.isFinished ?? false) && allDone,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.checklist != null;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: buildAppBar(isEditing ? 'Edit Checklist' : 'New Checklist'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TimeBlock(hour: _time.hour, minute: _time.minute, onTap: _pickTime),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: appInputDecoration(
              context,
              label: 'Checklist name',
              hint: 'e.g. Morning routine',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'To-do items',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  focusNode: _itemFocus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: appInputDecoration(context, label: 'New item'),
                  onSubmitted: (_) => _addItem(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Add item',
                onPressed: _addItem,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _items.length; i++)
            AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_items[i].text)),
                  IconButton(
                    tooltip: 'Remove item',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _items.removeAt(i);
                      });
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save checklist'),
            ),
          ),
        ],
      ),
    );
  }
}
