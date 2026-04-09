package com.daniel.students_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.daniel.students_app.widget.TodoWidgetUpdateWorker

/**
 * Implementation of App Widget functionality.
 * Displays a scrollable list of open TODO items on the home screen.
 */
class TodosAppWidgetProvider : AppWidgetProvider() {
    private fun extractTodoId(intent: Intent): Long {
        val longExtra = intent.getLongExtra("todoId", Long.MIN_VALUE)
        if (longExtra != Long.MIN_VALUE && longExtra != -1L) {
            return longExtra
        }

        val intExtra = intent.getIntExtra("todoId", -1)
        if (intExtra != -1) {
            return intExtra.toLong()
        }

        val stringExtra = intent.getStringExtra("todoId")
        return stringExtra?.toLongOrNull() ?: -1L
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        // Update each widget
        for (appWidgetId in appWidgetIds) {
            try {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            } catch (e: Exception) {
                android.util.Log.e("TodoWidget", "Error updating widget $appWidgetId", e)
            }
        }
    }

    override fun onReceive(
        context: Context?,
        intent: Intent?,
    ) {
        super.onReceive(context, intent)
        
        if (context == null || intent == null) return
        
        android.util.Log.d("TodoWidget", "========================================")
        android.util.Log.d("TodoWidget", "onReceive called with action: ${intent.action}")
        android.util.Log.d("TodoWidget", "Intent extras: ${intent.extras?.let { extras ->
            extras.keySet().joinToString { key -> "$key=${extras.get(key)}" }
        } ?: "none"}")
        android.util.Log.d("TodoWidget", "========================================")
        
        try {
            when (intent.action) {
                ACTION_UPDATE_TODOS -> {
                    android.util.Log.d("TodoWidget", "Handling UPDATE_TODOS")
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(context, TodosAppWidgetProvider::class.java)
                    )
                    for (appWidgetId in appWidgetIds) {
                        updateAppWidget(context, appWidgetManager, appWidgetId)
                    }
                }
                ACTION_TOGGLE_TODO -> {
                    android.util.Log.d("TodoWidget", "Handling TOGGLE_TODO")
                    val todoId = extractTodoId(intent)
                    val action = intent.getStringExtra("action")
                    android.util.Log.d("TodoWidget", "TodoId: $todoId, Action: $action")
                    
                    if (todoId != -1L) {
                        when (action) {
                            "toggle" -> {
                                android.util.Log.d("TodoWidget", "Calling toggleTodo for id $todoId")
                                toggleTodo(context, todoId)
                            }
                            "star" -> {
                                android.util.Log.d("TodoWidget", "Starring todo id $todoId")
                                toggleStar(context, todoId)
                            }
                            "edit" -> {
                                android.util.Log.d("TodoWidget", "Opening edit for id $todoId")
                                val mainActivityIntent = Intent(context, MainActivity::class.java).apply {
                                    putExtra("editTodoId", todoId)
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                                }
                                context.startActivity(mainActivityIntent)
                            }
                            else -> {
                                android.util.Log.e("TodoWidget", "Unknown action: $action")
                            }
                        }
                    } else {
                        android.util.Log.e("TodoWidget", "Invalid todoId: $todoId")
                    }
                }
                else -> {
                    android.util.Log.d("TodoWidget", "Unhandled action: ${intent.action}")
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("TodoWidget", "Error in onReceive", e)
            e.printStackTrace()
        }
    }

    companion object {
        const val ACTION_UPDATE_TODOS = "com.daniel.students_app.UPDATE_TODOS"
        const val ACTION_TOGGLE_TODO = "com.daniel.students_app.TOGGLE_TODO"
        private const val PREF_FILE = "FlutterSharedPreferences"
        private const val PREF_KEY = "flutter.countdown-app-todos"

        private fun toggleTodo(context: Context, todoId: Long) {
            try {
                android.util.Log.d("TodoWidget", "toggleTodo called for id: $todoId")
                val prefs = context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
                val jsonString = prefs.getString(PREF_KEY, "[]") ?: "[]"
                
                val gson = com.google.gson.Gson()
                val type = object : com.google.gson.reflect.TypeToken<List<MutableMap<String, Any>>>() {}.type
                val todos: MutableList<MutableMap<String, Any>> = gson.fromJson(jsonString, type)
                
                android.util.Log.d("TodoWidget", "Loaded ${todos.size} todos from SharedPreferences")
                
                // Find and toggle the todo
                val todo = todos.find {
                    val idValue = it["id"]
                    val id = when (idValue) {
                        is Number -> idValue.toLong()
                        is String -> idValue.toLongOrNull() ?: 0L
                        else -> 0L
                    }
                    id == todoId
                }
                if (todo != null) {
                    val currentCompleted = todo["completed"] as? Boolean ?: false
                    todo["completed"] = !currentCompleted
                    todo["id"] = todoId // ensure id stored as long
                    
                    // Save back to SharedPreferences
                    val updatedJson = gson.toJson(todos)
                    prefs.edit().putString(PREF_KEY, updatedJson).apply()
                    
                    android.util.Log.d("TodoWidget", "Toggled todo $todoId from $currentCompleted to ${!currentCompleted}")
                    android.util.Log.d("TodoWidget", "Saved to SharedPreferences")
                    
                    // Refresh the widget
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(context, TodosAppWidgetProvider::class.java)
                    )
                    
                    for (appWidgetId in appWidgetIds) {
                        android.util.Log.d("TodoWidget", "Refreshing widget $appWidgetId")
                        // updateAppWidget will handle both notifyAppWidgetViewDataChanged and re-setting the adapter
                        updateAppWidget(context, appWidgetManager, appWidgetId)
                    }
                    
                    android.util.Log.d("TodoWidget", "Widget refresh complete")
                } else {
                    android.util.Log.e("TodoWidget", "Todo with id $todoId not found")
                }
            } catch (e: Exception) {
                android.util.Log.e("TodoWidget", "Error toggling todo", e)
                e.printStackTrace()
            }
        }

        private fun toggleStar(context: Context, todoId: Long) {
            try {
                val prefs = context.getSharedPreferences("widget_settings", Context.MODE_PRIVATE)
                val starredIds = prefs.getStringSet("starred_ids", emptySet())?.toMutableSet() ?: mutableSetOf()
                val idStr = todoId.toString()
                if (starredIds.contains(idStr)) starredIds.remove(idStr) else starredIds.add(idStr)
                prefs.edit().putStringSet("starred_ids", starredIds).apply()

                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(context, TodosAppWidgetProvider::class.java)
                )
                for (appWidgetId in appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId)
                }
            } catch (e: Exception) {
                android.util.Log.e("TodoWidget", "Error toggling star", e)
            }
        }

        internal fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            try {
                android.util.Log.d("TodoWidget", "updateAppWidget called for widget $appWidgetId")
                
                // Create the RemoteViews object
                val views = RemoteViews(context.packageName, R.layout.todo_widget_layout)

                // CRITICAL: First notify that data changed to trigger onDataSetChanged()
                // This MUST be done before setting the remote adapter
                android.util.Log.d("TodoWidget", "Notifying data changed for widget $appWidgetId")
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.todo_list)

                // Set up the list view adapter - this creates a new factory instance
                val serviceIntent = Intent(context, TodoWidgetService::class.java)
                views.setRemoteAdapter(R.id.todo_list, serviceIntent)
                views.setEmptyView(R.id.todo_list, R.id.empty_view)

                // Set up template PendingIntent for list item clicks
                val clickIntentTemplate = Intent(context, TodosAppWidgetProvider::class.java).apply {
                    action = ACTION_TOGGLE_TODO
                }
                val clickPendingIntentTemplate = PendingIntent.getBroadcast(
                    context,
                    0,
                    clickIntentTemplate,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                )
                views.setPendingIntentTemplate(R.id.todo_list, clickPendingIntentTemplate)
                android.util.Log.d("TodoWidget", "Set PendingIntent template with action: $ACTION_TOGGLE_TODO")

                // Set up the app open action on header
                val openAppIntent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    openAppIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_header, pendingIntent)

                // Set up add task button
                val addTaskIntent = Intent(context, MainActivity::class.java).apply {
                    putExtra("action", "addTask")
                }
                val addTaskPendingIntent = PendingIntent.getActivity(
                    context,
                    1,
                    addTaskIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_add_button, addTaskPendingIntent)

                // Set up refresh button
                val refreshIntent = Intent(context, TodosAppWidgetProvider::class.java).apply {
                    action = ACTION_UPDATE_TODOS
                }
                val refreshPendingIntent = PendingIntent.getBroadcast(
                    context,
                    2,
                    refreshIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_refresh_button, refreshPendingIntent)

                // Set up settings button → launch WidgetSettingsActivity
                val settingsIntent = Intent(context, WidgetSettingsActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                val settingsPendingIntent = PendingIntent.getActivity(
                    context,
                    3,
                    settingsIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_settings_button, settingsPendingIntent)

                // Apply background opacity from settings
                val opacity = WidgetSettingsActivity.getOpacity(context)
                val alpha = (opacity / 100f * 255).toInt()
                val bgColor = (alpha shl 24) or 0x1A1A1A
                views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)

                // Update the widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
                android.util.Log.d("TodoWidget", "Widget $appWidgetId updated successfully")
            } catch (e: Exception) {
                android.util.Log.e("TodoWidget", "Error in updateAppWidget", e)
                throw e
            }
        }

        fun scheduleUpdate(context: Context) {
            try {
                val updateRequest = OneTimeWorkRequestBuilder<TodoWidgetUpdateWorker>().build()
                WorkManager.getInstance(context).enqueue(updateRequest)
            } catch (e: Exception) {
                android.util.Log.e("TodoWidget", "Error scheduling update", e)
            }
        }
    }
}
