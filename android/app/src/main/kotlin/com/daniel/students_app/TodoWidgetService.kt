package com.daniel.students_app

import android.content.Intent
import android.widget.RemoteViewsService

class TodoWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TodoWidgetRemoteViewsFactory(this.applicationContext, intent)
    }
}
