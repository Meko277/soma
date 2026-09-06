package com.example.bible

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews

import org.json.JSONObject

/**
 * SOMA FULL CALENDAR home-screen widget.
 *
 * Shows a whole-month grid (every day of the current
 * month, week by week) with:
 *
 *   - today highlighted with a golden ring,
 *   - Sundays tinted gold,
 *   - fixed Coptic feasts tinted soft red,
 *   - today's feast / event written under the grid.
 *
 * Data comes from Flutter via the `home_widget` plugin
 * ("HomeWidgetPreferences" shared prefs):
 *
 *   - cal_title        "August 2026"
 *   - cal_subtitle     "Mesori • عام ١٧٤٣ للشهداء"
 *   - cal_week_header  "S M T W T F S"
 *   - cal_grid         JSON {offset, days, today,
 *                           sundayCol, events{day:name}}
 *   - cal_today_event  today's feast ('' if none)
 *
 * Tapping anywhere opens the app.
 */
class FullCalendarWidgetProvider : AppWidgetProvider() {

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
            android.content.ComponentName(context, FullCalendarWidgetProvider::class.java)
        )
        onUpdate(context, manager, ids)
    }

    companion object {
        private const val COLOR_DAY = -0x171609   // #E8E9F7 off-white
        private const val COLOR_GOLD = -0x206886  // #FFD97A gold
        private const val COLOR_EVENT = -0x7575A0 // #FF8A80 soft red

        /** Pre-declared cell ids in ROW-MAJOR order (6 rows x 7 cols). */
        private val CELL_IDS = intArrayOf(
            R.id.cal_cell0, R.id.cal_cell1, R.id.cal_cell2, R.id.cal_cell3,
            R.id.cal_cell4, R.id.cal_cell5, R.id.cal_cell6,
            R.id.cal_cell7, R.id.cal_cell8, R.id.cal_cell9, R.id.cal_cell10,
            R.id.cal_cell11, R.id.cal_cell12, R.id.cal_cell13,
            R.id.cal_cell14, R.id.cal_cell15, R.id.cal_cell16, R.id.cal_cell17,
            R.id.cal_cell18, R.id.cal_cell19, R.id.cal_cell20,
            R.id.cal_cell21, R.id.cal_cell22, R.id.cal_cell23, R.id.cal_cell24,
            R.id.cal_cell25, R.id.cal_cell26, R.id.cal_cell27,
            R.id.cal_cell28, R.id.cal_cell29, R.id.cal_cell30, R.id.cal_cell31,
            R.id.cal_cell32, R.id.cal_cell33, R.id.cal_cell34,
            R.id.cal_cell35, R.id.cal_cell36, R.id.cal_cell37, R.id.cal_cell38,
            R.id.cal_cell39, R.id.cal_cell40, R.id.cal_cell41
        )

        private val HEADER_IDS = intArrayOf(
            R.id.cal_h0, R.id.cal_h1, R.id.cal_h2, R.id.cal_h3,
            R.id.cal_h4, R.id.cal_h5, R.id.cal_h6
        )

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(
                context.packageName,
                R.layout.full_calendar_widget
            )

            val prefs = context.getSharedPreferences(
                "HomeWidgetPreferences",
                Context.MODE_PRIVATE
            )

            views.setTextViewText(
                R.id.cal_title,
                prefs.getString("cal_title", "") ?: ""
            )
            views.setTextViewText(
                R.id.cal_subtitle,
                prefs.getString("cal_subtitle", "") ?: ""
            )

            // Week-day header letters.
            val headerTokens =
                (prefs.getString("cal_week_header", "") ?: "")
                    .split(" ")

            for (i in HEADER_IDS.indices) {
                views.setTextViewText(
                    HEADER_IDS[i],
                    headerTokens.getOrNull(i) ?: ""
                )
            }

            // Parse the month grid payload.
            var offset = 0
            var daysInMonth = 31
            var today = -1
            var sundayCol = -1
            var events: JSONObject? = null

            try {
                val grid = JSONObject(
                    prefs.getString("cal_grid", "{}") ?: "{}"
                )
                offset = grid.optInt("offset", 0)
                daysInMonth = grid.optInt("days", 31)
                today = grid.optInt("today", -1)
                sundayCol = grid.optInt("sundayCol", -1)
                events = grid.optJSONObject("events")
            } catch (_: Exception) {
                // Fall back to the empty defaults above.
            }

            // Fill the 42 cells (6 weeks x 7 days).
            for (slot in CELL_IDS.indices) {
                val cellId = CELL_IDS[slot]
                val column = slot % 7
                val dayNumber = slot + 1 - offset

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                    views.setViewVisibility(cellId, View.GONE)
                    continue
                }

                views.setViewVisibility(cellId, View.VISIBLE)
                views.setTextViewText(cellId, dayNumber.toString())

                val hasEvent =
                    events != null && events.has(dayNumber.toString())

                when {
                    dayNumber == today -> {
                        // Golden ring around today.
                        views.setTextColor(cellId, COLOR_GOLD)
                        views.setInt(
                            cellId,
                            "setBackgroundResource",
                            R.drawable.cal_cell_today
                        )
                    }

                    hasEvent -> {
                        // Fixed Coptic feast -> soft red.
                        views.setTextColor(cellId, COLOR_EVENT)
                    }

                    column == sundayCol -> {
                        // Liturgical Sunday -> gold text.
                        views.setTextColor(cellId, COLOR_GOLD)
                    }

                    else -> {
                        views.setTextColor(cellId, COLOR_DAY)
                    }
                }
            }

            // Today's feast / event under the grid.
            val todayEvent =
                prefs.getString("cal_today_event", "") ?: ""

            if (todayEvent.isEmpty()) {
                views.setViewVisibility(R.id.cal_event, View.GONE)
            } else {
                views.setViewVisibility(R.id.cal_event, View.VISIBLE)
                views.setTextViewText(R.id.cal_event, "✦ $todayEvent")
            }

            // Tap anywhere on the widget -> open the app.
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.cal_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

    }
}
