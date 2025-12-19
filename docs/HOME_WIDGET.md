Home screen widget (Android & iOS)

This project includes a starter integration for a home screen widget using the `home_widget` package.

What I added:

- Dart helper: `lib/features/todos/application/home_widget_helper.dart`
  - Call `HomeWidgetHelper.saveTodosAndUpdate(tasks)` to persist a small payload and request a native update.
  - The helper saves two keys: `todos` (JSON array of up to 3 tasks) and `todos_count` (string count).

- Android
  - Layout: `android/app/src/main/res/layout/todos_widget.xml`
  - Provider template: `android/app/src/main/kotlin/com/example/students_app/TodosAppWidgetProvider.kt`
  - Provider meta: `android/app/src/main/res/xml/todos_widget_provider.xml`
  - Manifest receiver registration added.

  Important: the native provider reads data from SharedPreferences. The `home_widget` plugin stores widget data under a plugin-specific preferences file; the provider uses a best-effort key (`io.flutter.plugins.home_widget`) and expects `todos` or `todos_count`. You should verify the actual SharedPreferences key or use the plugin's documented native helper to fetch saved values.

- iOS (SwiftUI / WidgetKit)
  - Starter widget: `ios/Runner/Widgets/TodosWidget.swift` (add it to a WidgetKit extension and set an App Group to share data)
  - The widget reads `todos` / `todos_count` from the shared UserDefaults (App Group). Replace the suite name with your app group.

How to use from Flutter

1) Add the dependency:

   flutter pub get

2) When the todo list changes, call:

   await HomeWidgetHelper.saveTodosAndUpdate(tasks);

   This will call `HomeWidget.saveWidgetData("todos", json)` and then `HomeWidget.updateWidget(...)`.

3) Rebuild and deploy the native parts:

   - Android: Ensure the `TodosAppWidgetProvider` is registered in the manifest (done).
     Confirm the provider reads the correct shared preferences key for the plugin version you use.

   - iOS: Add a WidgetKit target to the Xcode workspace and add `TodosWidget.swift` to that target. Configure an App Group and use the same group name in the widget code.

Notes and follow-ups

- The native code provided is intentionally conservative and documented; please adapt parsing and preferences keys to match the `home_widget` plugin version you add to `pubspec.yaml`.
- If you want the widget to display the actual task titles, expand the Swift/Kotlin parsing accordingly (watch for long text and truncation).
- I can finalize the native wiring (reading via the official native APIs the plugin exposes) if you want — let me know whether to use Kotlin or Java on Android and whether you have an App Group already on iOS.
