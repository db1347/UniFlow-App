package com.daniel.students_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.gson.Gson

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.daniel.students_app/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateTodos" -> {
                    @Suppress("UNCHECKED_CAST")
                    val todos = call.argument<List<Map<String, Any>>>("todos") as? List<Map<String, Any>> ?: emptyList()
                    saveTodosToSharedPrefs(todos)
                    updateWidget()
                    result.success(true)
                }
                "syncTodos" -> {
                    // Return current todos from SharedPreferences
                    val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    val jsonString = prefs.getString("flutter.countdown-app-todos", "[]") ?: "[]"
                    result.success(jsonString)
                }
                else -> result.notImplemented()
            }
        }

        // Post the intent handling to ensure method channel is ready
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            handleEditIntent(intent)
        }, 500)
    }

    override fun onResume() {
        super.onResume()
        // Sync todos from SharedPreferences in case widget made changes
        android.util.Log.d("MainActivity", "onResume: Syncing todos from widget changes")
        methodChannel?.invokeMethod("syncFromWidget", null)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        
        // Handle widget toggle events
        if (intent.action == "WIDGET_TODO_TOGGLED") {
            val todoId = intent.getIntExtra("todoId", -1)
            val completed = intent.getBooleanExtra("completed", false)
            
            if (todoId != -1) {
                // Notify Flutter about the toggle
                methodChannel?.invokeMethod("onTodoToggled", mapOf(
                    "todoId" to todoId,
                    "completed" to completed
                ))
            }
        }
        
        // Handle widget edit events
        handleEditIntent(intent)
    }

    private fun handleEditIntent(intent: Intent?) {
        android.util.Log.d("MainActivity", "handleEditIntent called with intent: $intent")
        
        val editTodoId = intent?.getIntExtra("editTodoId", -1) ?: -1
        if (editTodoId != -1) {
            android.util.Log.d("MainActivity", "Opening edit for todo: $editTodoId")
            // Notify Flutter to open edit screen
            methodChannel?.invokeMethod("onEditTodo", mapOf("todoId" to editTodoId))
        }

        val action = intent?.getStringExtra("action")
        android.util.Log.d("MainActivity", "handleEditIntent action: $action")
        if (action == "addTask") {
            android.util.Log.d("MainActivity", "Opening add task screen from widget, methodChannel=$methodChannel")
            methodChannel?.invokeMethod("onAddTask", null)
        }
    }

    private fun saveTodosToSharedPrefs(todos: List<Map<String, Any>>) {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val gson = Gson()
            val jsonString = gson.toJson(todos)
            android.util.Log.d("TodoWidget", "Saving ${todos.size} todos to SharedPreferences")
            android.util.Log.d("TodoWidget", "JSON: ${jsonString.take(500)}")
            prefs.edit().putString("flutter.countdown-app-todos", jsonString).apply()
            android.util.Log.d("TodoWidget", "Todos saved successfully")
        } catch (e: Exception) {
            android.util.Log.e("TodoWidget", "Error saving todos: ${e.message}", e)
        }
    }

    private fun updateWidget() {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(this, TodosAppWidgetProvider::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                TodosAppWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.todo_list)
            }
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Error updating widget", e)
        }
    }
}
