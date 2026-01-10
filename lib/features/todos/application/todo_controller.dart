import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:students_app/core/providers/shared_prefs_provider.dart';
import 'package:students_app/features/todos/domain/task.dart';

final todoControllerProvider = NotifierProvider<TodoController, TodoState>(
  TodoController.new,
);

// Used to request opening the edit sheet when invoked from the widget
final pendingEditTodoIdProvider = StateProvider<int?>((ref) => null);

// Used to request opening the add task sheet when invoked from the widget
final pendingAddTaskProvider = StateProvider<bool>((ref) => false);

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
  static const _methodChannel = MethodChannel('com.daniel.students_app/widget');

  @override
  TodoState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_storageKey);
    late final TodoState initialState;

    if (stored != null) {
      final data = jsonDecode(stored) as List<dynamic>;
      final tasks = data
          .cast<Map<String, dynamic>>()
          .map(Task.fromJson)
          .toList(growable: false);
      initialState = TodoState(tasks);
    } else {
      initialState = TodoState(_defaultTasks);
    }

    // Set up method channel handler for widget callbacks
    _methodChannel.setMethodCallHandler(_handleMethodCall);

    // Update widget with initial todos
    final payload = initialState.tasks
        .map((task) => task.toJson())
        .toList(growable: false);
    _updateWidget(payload);

    return initialState;
  }

  // Call this when app resumes to sync any widget changes
  Future<void> syncFromStorage() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs
        .reload(); // ensure we read the latest values written by the widget
    final stored = prefs.getString(_storageKey);

    print('TodoController.syncFromStorage() called');

    if (stored != null) {
      try {
        final data = jsonDecode(stored) as List<dynamic>;
        final tasks = data
            .cast<Map<String, dynamic>>()
            .map(Task.fromJson)
            .toList(growable: false);

        print('Synced ${tasks.length} todos from storage');
        tasks.forEach((task) {
          print('  - ${task.title} (completed: ${task.completed})');
        });

        state = TodoState(tasks);
      } catch (e) {
        print('Error syncing from storage: $e');
      }
    } else {
      print('No todos found in storage');
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    print('TodoController._handleMethodCall: ${call.method}');

    if (call.method == 'onTodoToggled') {
      final todoId = call.arguments['todoId'] as int?;
      final completed = call.arguments['completed'] as bool?;

      if (todoId != null && completed != null) {
        print('Handling onTodoToggled: todoId=$todoId, completed=$completed');
        // Update the Flutter state to match the widget state
        final updated = state.tasks
            .map(
              (task) => task.id == todoId
                  ? task.copyWith(completed: completed)
                  : task,
            )
            .toList();
        state = state.copyWith(tasks: updated);

        // Persist to SharedPreferences
        final prefs = ref.read(sharedPreferencesProvider);
        final payload = state.tasks
            .map((task) => task.toJson())
            .toList(growable: false);
        prefs.setString(_storageKey, jsonEncode(payload));
      }
    } else if (call.method == 'onEditTodo') {
      final todoId = call.arguments['todoId'] as int?;
      if (todoId != null) {
        print('Widget requested to edit todo: $todoId');
        await syncFromStorage();
        final pending = ref.read(pendingEditTodoIdProvider.notifier);
        // Force change notification even if same id arrives repeatedly
        pending.state = null;
        // Defer to next microtask to ensure listeners see the change
        Future.microtask(() => pending.state = todoId);
      }
    } else if (call.method == 'onAddTask') {
      print('Widget requested to add new task');
      final pending = ref.read(pendingAddTaskProvider.notifier);
      // Force change notification even if already true
      pending.state = false;
      // Defer to next microtask to ensure listeners see the change
      Future.microtask(() => pending.state = true);
    } else if (call.method == 'syncFromWidget') {
      print('Handling syncFromWidget');
      // Reload todos from SharedPreferences in case widget made changes
      await syncFromStorage();
    }
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
        .map(
          (task) =>
              task.id == id ? task.copyWith(completed: !task.completed) : task,
        )
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

  void updateTask({
    required int id,
    required String title,
    DateTime? dueDate,
    TaskRepeat repeat = TaskRepeat.none,
  }) {
    final updated = state.tasks
        .map(
          (task) => task.id == id
              ? task.copyWith(title: title, dueDate: dueDate, repeat: repeat)
              : task,
        )
        .toList();
    state = state.copyWith(tasks: updated);
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    final payload = state.tasks
        .map((task) => task.toJson())
        .toList(growable: false);
    prefs.setString(_storageKey, jsonEncode(payload));

    // Update the widget with the new todos
    _updateWidget(payload);
  }

  void _updateWidget(List<Map<String, dynamic>> todos) {
    try {
      _methodChannel.invokeMethod('updateTodos', {'todos': todos});
    } catch (e) {
      // Widget might not be available, silently fail
    }
  }

  List<Task> get _defaultTasks => [
    Task(id: 1, title: 'Study for exams', repeat: TaskRepeat.daily),
    Task(id: 2, title: 'Call mom', dueDate: DateTime.utc(2025, 12, 20)),
    Task(id: 3, title: 'Finish project', completed: true),
  ];
}
