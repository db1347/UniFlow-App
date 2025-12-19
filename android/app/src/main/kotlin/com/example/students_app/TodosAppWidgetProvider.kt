package com.example.students_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

/**
 * Basic AppWidgetProvider template for the Todos widget.
 *
 * NOTE: This template reads from SharedPreferences and expects the Flutter
 * side to call `HomeWidget.saveWidgetData('todos', jsonString)` and
 * `HomeWidget.updateWidget(name: 'TodosWidget')` (see Dart helper).
 *
 * Customize the data keys and parsing logic below to match your payload.
 */
class TodosAppWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "io.flutter.plugins.home_widget" // may vary by plugin version
        private const val TODOS_KEY = "todos"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val todosJson = prefs.getString(TODOS_KEY, null)
            val count = if (todosJson.isNullOrEmpty()) {
                // fallback: read count key
                prefs.getString("todos_count", "0") ?: "0"
            } else {
                try {
                    // crude parsing to count array items (production: use org.json)
                    if (todosJson.trim().startsWith("[")) {
                        val listSize = todosJson.split("\},").size
                        listSize.toString()
                    } else "0"
                } catch (e: Exception) { "0" }
            }

            val views = RemoteViews(context.packageName, R.layout.todos_widget)
            views.setTextViewText(R.id.widget_count, count)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
