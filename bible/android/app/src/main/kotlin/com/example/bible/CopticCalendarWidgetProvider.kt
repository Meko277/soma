package com.example.bible

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * SOMA home-screen widget showing the Coptic calendar.
 *
 * Data is written from Flutter via the `home_widget`
 * plugin into the "HomeWidgetPreferences" shared prefs:
 *
 *   - coptic_date      e.g. "Tout 15 1743 AM"
 *   - coptic_date_ar   e.g. "توت ١٥ ١٧٤٣ للشهداء"
 *   - gregorian_date   e.g. "23/8/2026"
 *   - season_name      e.g. "Annual"
 *
 * Tapping the widget opens the app.
 */
class CopticCalendarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // First widget placed: render whatever data was
        // last saved by the Flutter side.
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            android.content.ComponentName(context, CopticCalendarWidgetProvider::class.java)
        )
        onUpdate(context, manager, ids)
    }

    companion object {
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(
                context.packageName,
                R.layout.coptic_calendar_widget
            )

            val prefs = context.getSharedPreferences(
                "HomeWidgetPreferences",
                Context.MODE_PRIVATE
            )

            val copticDate = prefs.getString("coptic_date", "") ?: ""
            val gregorianDate = prefs.getString("gregorian_date", "") ?: ""
            val seasonName = prefs.getString("season_name", "") ?: ""

            views.setTextViewText(R.id.widget_coptic_date, copticDate)
            views.setTextViewText(R.id.widget_gregorian_date, gregorianDate)
            views.setTextViewText(R.id.widget_season, seasonName)

            // Tap anywhere on the widget -> open the app.
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}