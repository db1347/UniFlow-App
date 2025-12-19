import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:students_app/features/todos/domain/task.dart';

/// Helper that serializes a subset of todo data and pushes it to the
/// native home screen widget using the `home_widget` plugin.
class HomeWidgetHelper {
  /// Saves the most relevant todo information and triggers a widget update.
  ///
  /// We keep the payload small: an array of up to 3 task maps with title and
  /// completion flag. Native widget layouts should expect this key.
  static Future<void> saveTodosAndUpdate(List<Task> tasks) async {
    try {
      final payload = tasks
          .take(3)
          .map((t) => {'title': t.title, 'completed': t.completed})
          .toList(growable: false);

      await HomeWidget.saveWidgetData<String>('todos', jsonEncode(payload));
      // Optional: save a small human-readable summary as well
      await HomeWidget.saveWidgetData<String>('todos_count', '${tasks.length}');

      // Trigger the native update; widgetName/iOSName depend on your native registration
      await HomeWidget.updateWidget(
        name: 'TodosWidget',
        iOSName: 'TodosWidget',
      );
    } catch (_) {
      // Don't crash the app if the plugin isn't available on the platform
    }
  }
}
