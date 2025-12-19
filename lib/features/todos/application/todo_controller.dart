import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/todos/domain/task.dart';
import 'package:students_app/features/todos/application/home_widget_helper.dart';

final todoControllerProvider = NotifierProvider<TodoController, TodoState>(
  TodoController.new,
);

class TodoState {
  const TodoState(this.tasks);

  final List<Task> tasks;

  List<Task> get openTasks =>
      tasks.where((task) => task.completed == false).toList();

  List<Task> get completedTasks =>
      tasks.where((task) => task.completed).toList();

  List<Task> get openTasksWithDueDate =>
      openTasks.where((task) => task.dueDate != null).toList();

  TodoState copyWith({List<Task>? tasks}) {
    return TodoState(tasks ?? this.tasks);
  }
}

class TodoController extends Notifier<TodoState> {
  static const _storageKey = 'countdown-app-todos';

  @override
  TodoState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    if (stored != null) {
      final data = jsonDecode(stored) as List<dynamic>;
      final tasks = data
          .cast<Map<String, dynamic>>()
          .map(Task.fromJson)
          .toList(growable: false);
      return TodoState(tasks);
    }
    return TodoState(_defaultTasks);
  }

  void addTask({
    required String title,
    DateTime? dueDate,
    TaskRepeat repeat = TaskRepeat.none,
  }) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      dueDate: dueDate,
      repeat: repeat,
      completed: false,
    );
    state = state.copyWith(tasks: [...state.tasks, newTask]);
    _persist();
  }

  void toggleTask(int id) {
    final updated = state.tasks
        .map((task) =>
            task.id == id ? task.copyWith(completed: !task.completed) : task)
        .toList();
    state = state.copyWith(tasks: updated);
    _persist();
  }

  void deleteTask(int id) {
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != id).toList(),
    );
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    final payload =
        state.tasks.map((task) => task.toJson()).toList(growable: false);
    prefs.setString(_storageKey, jsonEncode(payload));
    // Update home screen widget with latest tasks (best-effort).
    try {
      // ignore: unawaited_futures
      HomeWidgetHelper.saveTodosAndUpdate(state.tasks);
    } catch (_) {}

  }

  List<Task> get _defaultTasks => [
        Task(id: 1, title: 'Study for exams', repeat: TaskRepeat.daily),
        Task(
          id: 2,
          title: 'Call mom',
          dueDate: DateTime.utc(2025, 12, 20),
        ),
        Task(
          id: 3,
          title: 'Finish project',
          completed: true,
        ),
      ];
}
