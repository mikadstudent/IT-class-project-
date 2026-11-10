import '../utils/time_format.dart';

class TodoItem {
  String text;
  bool isDone;

  TodoItem({required this.text, this.isDone = false});

  Map<String, dynamic> toJson() => {'text': text, 'isDone': isDone};

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      text: json['text'] as String,
      isDone: json['isDone'] as bool,
    );
  }
}

class Checklist {
  final String id;
  final String title;
  final int hour;
  final int minute;
  final List<TodoItem> items;
  bool isFinished;

  Checklist({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.items,
    this.isFinished = false,
  });

  String get timeText => formatTime(hour, minute);

  int get minutesOfDay => hour * 60 + minute;

  int get doneCount => items.where((item) => item.isDone).length;

  bool get allDone => items.isNotEmpty && doneCount == items.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hour': hour,
        'minute': minute,
        'items': items.map((item) => item.toJson()).toList(),
        'isFinished': isFinished,
      };

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'] as String,
      title: json['title'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      items: (json['items'] as List)
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFinished: json['isFinished'] as bool,
    );
  }
}
