package com.daniel.students_app.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.daniel.students_app.TodosAppWidgetProvider

class TodoWidgetUpdateWorker(
    context: Context,
    params: WorkerParameters,
) : Worker(context, params) {

    override fun doWork(): Result {
        return try {
            val context = applicationContext
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, TodosAppWidgetProvider::class.java)
            )

            // Update all widgets
            for (appWidgetId in appWidgetIds) {
                TodosAppWidgetProvider.updateAppWidget(context, appWidgetManager, appWidgetId)
            }

            // Notify RemoteViews adapters of data change
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, android.R.id.list)

            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
