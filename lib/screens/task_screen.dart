import 'package:flutter/material.dart';
import '../models/task.dart';
 
class TaskDetailScreen extends StatefulWidget {
  final Task task;
 
  const TaskDetailScreen({super.key, required this.task});
 
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}
 
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String _statusText() {
    if (widget.task.isDone) {
      return 'Done. Nice work!';
    } else {
      return 'Not done yet';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
 
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(_statusText()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  task.isDone = !task.isDone;
                });
              },
              child: Text(task.isDone ? 'Mark as not done' : 'Mark as done'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
 
