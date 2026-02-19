package com.daniel.students_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

data class TodoItem(
    val id: Long,
    val title: String,
    val completed: Boolean,
    val dueDate: String? = null,
    val repeat: String? = "none",
)

class TodoWidgetRemoteViewsFactory(
    private val context: Context,
    private val intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {

    private var todos: List<TodoItem> = emptyList()
    private lateinit var sharedPreferences: SharedPreferences

    override fun onCreate() {
        // Try the default Flutter SharedPreferences
        sharedPreferences = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )
        loadTodos()
    }

    override fun onDataSetChanged() {
        android.util.Log.d("TodoWidget", "=== onDataSetChanged() called ===")
        loadTodos()
    }

    override fun onDestroy() {}

    override fun getCount(): Int = todos.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position < 0 || position >= todos.size) return null

        val todo = todos[position]
        val views = RemoteViews(context.packageName, R.layout.todo_widget_item)

        // Set the todo title
        views.setTextViewText(R.id.todo_title, todo.title)

        // Set strike-through if completed
        if (todo.completed) {
            views.setInt(R.id.todo_title, "setPaintFlags", android.graphics.Paint.STRIKE_THRU_TEXT_FLAG)
        } else {
            views.setInt(R.id.todo_title, "setPaintFlags", 0)
        }

        android.util.Log.d("TodoWidget", "========== Setting up item for todo ${todo.id} ==========")

        // Checkbox click - toggle task
        val toggleFillIntent = Intent().apply {
            putExtra("todoId", todo.id)
            putExtra("action", "toggle")
        }
        views.setOnClickFillInIntent(R.id.todo_checkbox, toggleFillIntent)
        
        // Title click - open edit
        val editFillIntent = Intent().apply {
            putExtra("todoId", todo.id)
            putExtra("action", "edit")
        }
        views.setOnClickFillInIntent(R.id.todo_title, editFillIntent)
        
        android.util.Log.d("TodoWidget", "Checkbox: toggle, Title: edit for todoId=${todo.id}")

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = todos[position].id

    override fun hasStableIds(): Boolean = true

    private fun loadTodos() {
        try {
            android.util.Log.d("TodoWidget", "loadTodos() called")
            
            // List of possible storage keys to try
            val possibleKeys = listOf(
                "flutter.countdown-app-todos",
                "countdown-app-todos",
                "flutter.todos",
                "todos",
            )

            var jsonString: String? = null
            var foundKey = ""

            // Try each possible key
            for (key in possibleKeys) {
                val value = sharedPreferences.getString(key, null)
                if (value != null) {
                    jsonString = value
                    foundKey = key
                    android.util.Log.d("TodoWidget", "Found todos with key: $key")
                    break
                }
            }

            // If still no data, log all available keys
            if (jsonString == null) {
                android.util.Log.d("TodoWidget", "No todos found. Available keys:")
                sharedPreferences.all.forEach { (key, value) ->
                    android.util.Log.d("TodoWidget", "  Key: $key, Value: ${value.toString().take(100)}")
                }
                todos = emptyList()
                return
            }

            android.util.Log.d("TodoWidget", "JSON String: ${jsonString.take(300)}")

            val type = object : TypeToken<List<Map<String, Any?>>>() {}.type
            val rawTodos: List<Map<String, Any?>> = Gson().fromJson(jsonString, type)

            val allTodos: List<TodoItem> = rawTodos.mapNotNull { item ->
                val idValue = item["id"]
                val id = when (idValue) {
                    is Number -> idValue.toLong()
                    is String -> idValue.toLongOrNull() ?: 0L
                    else -> 0L
                }

                if (id == 0L) return@mapNotNull null

                val title = item["title"] as? String ?: ""
                val completedValue = item["completed"]
                val completed = when (completedValue) {
                    is Boolean -> completedValue
                    is String -> completedValue.equals("true", ignoreCase = true)
                    is Number -> completedValue.toInt() != 0
                    else -> false
                }
                val dueDate = item["dueDate"] as? String
                val repeat = item["repeat"] as? String ?: "none"

                TodoItem(
                    id = id,
                    title = title,
                    completed = completed,
                    dueDate = dueDate,
                    repeat = repeat,
                )
            }
            
            android.util.Log.d("TodoWidget", "Total todos loaded: ${allTodos.size}")
            allTodos.forEachIndexed { index, item ->
                android.util.Log.d("TodoWidget", "  [$index] id=${item.id}, title=${item.title}, completed=${item.completed}")
            }

            // Filter to only open (non-completed) todos and limit to 10
            todos = allTodos.filter { !it.completed }.take(10)
            
            android.util.Log.d("TodoWidget", "Filtered open todos: ${todos.size}")
            todos.forEach { 
                android.util.Log.d("TodoWidget", "  - ${it.title} (completed: ${it.completed})")
            }

        } catch (e: Exception) {
            android.util.Log.e("TodoWidget", "Error loading todos: ${e.message}", e)
            e.printStackTrace()
            todos = emptyList()
        }
    }
}
