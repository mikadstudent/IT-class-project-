import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/checklist.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'checklist_form_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<Checklist> _checklists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.loadChecklists();
    if (!mounted) return;
    setState(() {
      _checklists.addAll(saved);
      _sort();
      _loading = false;
    });
  }

  /// Unfinished checklists first (by time), finished ones at the bottom.
  void _sort() {
    _checklists.sort((a, b) {
      if (a.isFinished != b.isFinished) {
        return a.isFinished ? 1 : -1;
      }
      return a.minutesOfDay.compareTo(b.minutesOfDay);
    });
  }

  Future<void> _saveAll() async {
    await StorageService.saveChecklists(_checklists);
  }

  /// Opens the form. With no argument it creates a new checklist;
  /// with a checklist it edits that one (the data goes in through the constructor).
  Future<void> _openForm([Checklist? existing]) async {
    final Checklist? result = await Navigator.push<Checklist>(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistFormScreen(checklist: existing),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      if (existing == null) {
        _checklists.add(result);
      } else {
        final index = _checklists.indexWhere((c) => c.id == existing.id);
        if (index != -1) _checklists[index] = result;
      }
      _sort();
    });
    await _saveAll();
  }

  void _toggleItem(TodoItem item, bool? value) {
    HapticFeedback.selectionClick();
    setState(() {
      item.isDone = value ?? false;
    });
    _saveAll();
  }

  void _deleteItem(Checklist checklist, TodoItem item) {
    setState(() {
      checklist.items.remove(item);
    });
    _saveAll();
  }

  void _finish(Checklist checklist) {
    if (checklist.items.isEmpty) {
      showAppSnack(context, 'This checklist has no items. Use Edit to add some.');
    } else if (!checklist.allDone) {
      final left = checklist.items.length - checklist.doneCount;
      showAppSnack(context, 'Tick the remaining $left item(s) first.');
    } else {
      setState(() {
        checklist.isFinished = true;
        _sort();
      });
      _saveAll();
      showAppSnack(context, 'Checklist finished. Nice work!');
    }
  }

  void _reopen(Checklist checklist) {
    setState(() {
      checklist.isFinished = false;
      _sort();
    });
    _saveAll();
  }

  void _deleteChecklist(Checklist checklist) {
    final index = _checklists.indexWhere((c) => c.id == checklist.id);
    if (index == -1) return;

    setState(() {
      _checklists.removeAt(index);
    });
    _saveAll();

    showAppSnack(
      context,
      '"${checklist.title}" deleted',
      actionLabel: 'Undo',
      onAction: () {
        if (!mounted) return;
        setState(() {
          _checklists.add(checklist);
          _sort();
        });
        _saveAll();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Checklists'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('New Checklist'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _checklists.isEmpty
              ? const EmptyState(
                  icon: Icons.checklist,
                  title: 'No checklists yet',
                  message:
                      'Create a checklist with a time and a list of things to do.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: _checklists.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildSummary();
                    final checklist = _checklists[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(checklist.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteChecklist(checklist),
                        background: _buildSwipeBackground(),
                        child: _buildChecklistCard(checklist),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildSummary() {
    final scheme = Theme.of(context).colorScheme;
    final total = _checklists.fold<int>(0, (sum, c) => sum + c.items.length);
    final done = _checklists.fold<int>(0, (sum, c) => sum + c.doneCount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        '${_checklists.length} checklists · $done of $total tasks done',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
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

  Widget _buildChecklistCard(Checklist checklist) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final finished = checklist.isFinished;
    final total = checklist.items.length;
    final progress = total == 0 ? 0.0 : checklist.doneCount / total;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: finished
                      ? scheme.surfaceContainerHighest
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      checklist.timeText,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (value) {
                  if (value == 'edit') {
                    _openForm(checklist);
                  } else {
                    _deleteChecklist(checklist);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 12),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Checklist name and progress
          Text(
            checklist.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              decoration:
                  finished ? TextDecoration.lineThrough : TextDecoration.none,
              color: finished ? scheme.onSurfaceVariant : null,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedProgressBar(
                  value: progress,
                  color: finished ? AppTheme.success : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${checklist.doneCount}/$total',
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Boxes (to-do list)
          for (final item in checklist.items)
            InkWell(
              key: ObjectKey(item),
              borderRadius: BorderRadius.circular(12),
              onTap: finished ? null : () => _toggleItem(item, !item.isDone),
              child: Row(
                children: [
                  Checkbox(
                    value: item.isDone,
                    shape: const CircleBorder(),
                    onChanged:
                        finished ? null : (value) => _toggleItem(item, value),
                  ),
                  Expanded(
                    child: Text(
                      item.text,
                      style: textTheme.bodyLarge?.copyWith(
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isDone ? scheme.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove item',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed:
                        finished ? null : () => _deleteItem(checklist, item),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // 4. Finish Checklist
          if (finished)
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success),
                const SizedBox(width: 8),
                Text(
                  'All done',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _reopen(checklist),
                  child: const Text('Reopen'),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _finish(checklist),
                icon: const Icon(Icons.flag),
                label: const Text('Finish Checklist'),
              ),
            ),
        ],
      ),
    );
  }
}
