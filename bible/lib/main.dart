import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/coptic_companion_app.dart';
import 'core/calendar/calendar_home_widget_service.dart';
import 'core/calendar/coptic_home_widget_service.dart';
import 'core/localization/daily_verse_home_widget_service.dart';
import 'core/notifications/daily_plan_notification_service.dart';
import 'core/preferences/preferences_provider.dart';
import 'core/sync/firebase_sync_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

try {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
} on FirebaseException catch (e) {
  if (e.code != 'duplicate-app') {
    rethrow;
  }
}

// ============================================================
// SHOW THE UI FIRST
//
// Everything that used to block before runApp() (Firestore
// sync, notification scheduling, the three home-screen
// widgets) now runs AFTER the first frame instead. On old /
// low-end devices those platform channels + the Firestore
// cold start could take many seconds, which showed as a
// frozen white screen. Now the UI paints immediately and the
// services warm up in the background.
// ============================================================

  runApp(
    const ProviderScope(
      child: CopticCompanionApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_bootstrapBackgroundServices());
  });
}

/// Background bootstrap: runs after the first frame so it can
/// never delay the UI. Every step is individually guarded — a
/// failure in one service must never prevent the others (or
/// the app) from working.
Future<void> _bootstrapBackgroundServices() async {
  // ============================================================
  // FIREBASE REAL-TIME SYNC
  //
  // Loads cached content instantly (so the app is usable offline
  // from the first open), then subscribes to Firestore for live
  // updates. The service never throws — if Firebase is down or the
  // user is offline, the bundled assets keep working as before.
  // ============================================================

  try {
    await FirebaseSyncService.instance.initialize();
  } catch (_) {
    // Never block startup on sync failures.
  }

  // ============================================================
  // DAILY PLAN NOTIFICATIONS
  //
  // Requests permissions and schedules the daily
  // "Today's Plan" notifications (normal + pop-up) using the
  // USER'S PERSISTED delivery time (falls back to the
  // defaults when nothing was stored yet). Scheduling cancels
  // the fixed-ID previous notifications first, so restarting
  // the app can never create duplicates.
  // ============================================================

  int notificationHour = DailyPlanNotificationService.defaultHour;
  int notificationMinute = DailyPlanNotificationService.defaultMinute;

  try {
    final storage = await SharedPreferences.getInstance();

    notificationHour = storage.getInt(
          PreferencesNotifier.notificationHourStorageKey,
        ) ??
        notificationHour;

    notificationMinute = storage.getInt(
          PreferencesNotifier.notificationMinuteStorageKey,
        ) ??
        notificationMinute;
  } catch (_) {
    // Storage unavailable -> schedule with defaults.
  }

  try {
    await DailyPlanNotificationService.instance.initialize(
      hour: notificationHour,
      minute: notificationMinute,
    );
  } catch (_) {
    // Notification failures must never crash the app.
  }

  // ============================================================
  // COPTIC CALENDAR WIDGET
  //
  // Pushes today's Coptic date to the Android home-screen
  // widget so it always shows fresh data whenever the app
  // opens. (Long-press home screen -> Widgets -> Soma.)
  // ============================================================

  try {
    await CopticHomeWidgetService.update();
  } catch (_) {}

  // ============================================================
  // FULL CALENDAR HOME WIDGET
  //
  // Whole-month grid (every day of the current month) with
  // the major fixed Coptic feasts highlighted and today's
  // event shown under the grid.
  // ============================================================

  try {
    await CalendarHomeWidgetService.update();
  } catch (_) {}

  // ============================================================
  // DAILY VERSE HOME WIDGET (آية اليوم)
  // ============================================================

  try {
    await DailyVerseHomeWidgetService.update();
  } catch (_) {}
}
