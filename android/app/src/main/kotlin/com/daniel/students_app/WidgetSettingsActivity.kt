package com.daniel.students_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.SeekBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SwitchCompat

class WidgetSettingsActivity : AppCompatActivity() {

    companion object {
        const val PREF_FILE = "widget_settings"
        const val PREF_OPACITY = "opacity"
        const val PREF_FONT_SIZE = "font_size"
        const val PREF_SHOW_COMPLETED = "show_completed"

        private val FONT_SIZES = listOf("Small", "Normal", "Large")

        fun getOpacity(context: Context): Int =
            context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
                .getInt(PREF_OPACITY, 80)

        fun getFontSize(context: Context): String =
            context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
                .getString(PREF_FONT_SIZE, "Normal") ?: "Normal"

        fun getShowCompleted(context: Context): Boolean =
            context.getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
                .getBoolean(PREF_SHOW_COMPLETED, false)
    }

    private lateinit var opacitySlider: SeekBar
    private lateinit var opacityValue: TextView
    private lateinit var fontSizeRow: View
    private lateinit var fontSizeValue: TextView
    private lateinit var showCompletedSwitch: SwitchCompat

    private var currentFontSizeIndex = 1  // "Normal" by default

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_widget_settings)

        opacitySlider = findViewById(R.id.opacity_slider)
        opacityValue = findViewById(R.id.opacity_value)
        fontSizeRow = findViewById(R.id.font_size_row)
        fontSizeValue = findViewById(R.id.font_size_value)
        showCompletedSwitch = findViewById(R.id.show_completed_switch)

        // Load saved settings
        val prefs = getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE)
        val savedOpacity = prefs.getInt(PREF_OPACITY, 80)
        val savedFontSize = prefs.getString(PREF_FONT_SIZE, "Normal") ?: "Normal"
        val savedShowCompleted = prefs.getBoolean(PREF_SHOW_COMPLETED, false)

        // Apply loaded values to UI
        opacitySlider.progress = savedOpacity
        opacityValue.text = "$savedOpacity%"
        currentFontSizeIndex = FONT_SIZES.indexOf(savedFontSize).takeIf { it >= 0 } ?: 1
        fontSizeValue.text = FONT_SIZES[currentFontSizeIndex]
        showCompletedSwitch.isChecked = savedShowCompleted

        // Opacity slider listener
        opacitySlider.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                opacityValue.text = "$progress%"
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        // Font size row: cycle through Small → Normal → Large
        fontSizeRow.setOnClickListener {
            currentFontSizeIndex = (currentFontSizeIndex + 1) % FONT_SIZES.size
            fontSizeValue.text = FONT_SIZES[currentFontSizeIndex]
        }

        // Dismiss when tapping the dim overlay outside the panel
        findViewById<View>(R.id.settings_overlay).setOnClickListener { saveAndClose() }
        findViewById<View>(R.id.settings_panel).setOnClickListener { /* consume, don't dismiss */ }
    }

    override fun onBackPressed() {
        saveAndClose()
    }

    private fun saveAndClose() {
        val opacity = opacitySlider.progress
        val fontSize = FONT_SIZES[currentFontSizeIndex]
        val showCompleted = showCompletedSwitch.isChecked

        getSharedPreferences(PREF_FILE, Context.MODE_PRIVATE).edit()
            .putInt(PREF_OPACITY, opacity)
            .putString(PREF_FONT_SIZE, fontSize)
            .putBoolean(PREF_SHOW_COMPLETED, showCompleted)
            .apply()

        // Trigger widget refresh
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val ids = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(this, TodosAppWidgetProvider::class.java)
        )
        for (id in ids) {
            TodosAppWidgetProvider.updateAppWidget(this, appWidgetManager, id)
        }

        finish()
    }
}
