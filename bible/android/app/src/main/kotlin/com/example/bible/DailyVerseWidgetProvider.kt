package com.example.bible

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * SOMA DAILY VERSE (آية اليوم) home-screen widget.
 *
 * Shows the verse of the day (Arabic Van Dyke text +
 * reference). A new verse arrives every day because the
 * Flutter side re-runs DailyVerseHomeWidgetService.update()
 * whenever the app opens and the widget re-renders at least
 * every 30 minutes via updatePeriodMillis.
 *
 * Data keys ("HomeWidgetPreferences"):
 *
 *   - verse_text   e.g. «الربّ راعيَّ فلا يعوزني شيء.»
 *   - verse_ref    e.g. مزمور ٢٣: ١
 *
 * Tapping the widget opens the app.
 */
class DailyVerseWidgetProvider : AppWidgetProvider() {

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
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            android.content.ComponentName(context, DailyVerseWidgetProvider::class.java)
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
                R.layout.daily_verse_widget
            )

            val prefs = context.getSharedPreferences(
                "HomeWidgetPreferences",
                Context.MODE_PRIVATE
            )

            views.setTextViewText(
                R.id.verse_text,
                prefs.getString("verse_text", "") ?: ""
            )
            views.setTextViewText(
                R.id.verse_ref,
                prefs.getString("verse_ref", "") ?: ""
            )

            // Tap anywhere on the widget -> open the app.
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                2,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.verse_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
