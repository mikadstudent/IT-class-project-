import 'package:flutter/material.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
 
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});
 
  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}
 
class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<Task> _tasks = [];
 
  Future<void> _openAddTask() async {
    // The Add Task screen sends the new title back with Navigator.pop.
    final String? title = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );
 
    if (!mounted) return;
    if (title != null) {
      setState(() {
        _tasks.add(Task(title: title));
      });
    }
  }
 
  Future<void> _openDetail(Task task) async {
    // Data goes to the detail screen through its constructor.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
 
    // The detail screen may have changed the task, so refresh the list.
    if (!mounted) return;
    setState(() {});
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checklist')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (value) {
                      setState(() {
                        task.isDone = value ?? false;
                      });
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDetail(task),
                );
              },
            ),
    );
  }
}
