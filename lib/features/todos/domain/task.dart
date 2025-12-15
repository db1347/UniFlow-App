import 'package:equatable/equatable.dart';

enum TaskRepeat { none, daily, weekly, monthly }

class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.repeat = TaskRepeat.none,
    this.completed = false,
  });

  final int id;
  final String title;
  final DateTime? dueDate;
  final TaskRepeat repeat;
  final bool completed;

  Task copyWith({
    int? id,
    String? title,
    DateTime? dueDate,
    TaskRepeat? repeat,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      repeat: repeat ?? this.repeat,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate?.toIso8601String(),
        'repeat': repeat.name,
        'completed': completed,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      repeat: TaskRepeat.values.firstWhere(
        (element) => element.name == json['repeat'],
        orElse: () => TaskRepeat.none,
      ),
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, dueDate, repeat, completed];
}
