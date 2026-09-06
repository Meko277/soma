import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../calendar/liturgical_calendar_service.dart';
import '../calendar/liturgical_day.dart';
import '../preferences/preferences_provider.dart';

// ================================================================
// DAILY PLAN NOTIFICATION SERVICE
//
// Every day the app sends "Today's Plan" twice:
//
//   1. NORMAL notification  (08:00) - a regular tray
//      notification with the full plan (Coptic date,
//      season/fast and today's readings).
//
//   2. POP-UP notification  (08:05) - a high-importance
//      heads-up / full-screen style notification that
//      pops over whatever is on screen.
//
// Both repeat daily and survive device reboots.
// ================================================================

class DailyPlanNotificationService {
  DailyPlanNotificationService._();

  static final DailyPlanNotificationService instance =
      DailyPlanNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ------------------------------------------------------------
  // IDs & CHANNELS
  // ------------------------------------------------------------

  static const int _normalNotificationId = 1001;
  static const int _popupNotificationId = 1002;

  static const String _normalChannelId = 'daily_plan';
  static const String _popupChannelId = 'daily_plan_popup';

  /// Default delivery time (08:00 local time).
  static const int defaultHour = 8;
  static const int defaultMinute = 0;

  // ============================================================
  // INITIALIZE + SCHEDULE
  // ============================================================

  Future<void> initialize({
    int hour = defaultHour,
    int minute = defaultMinute,
  }) async {
    if (_initialized) {
      return;
    }

    try {
      // ------------------------------------------------------
      // TIME ZONES
      // ------------------------------------------------------

      tzdata.initializeTimeZones();
      tz.setLocalLocation(
        tz.getLocation(_detectTimeZoneName()),
      );

      // ------------------------------------------------------
      // PLUGIN
      // ------------------------------------------------------

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(
            '@mipmap/ic_launcher',
          ),
          iOS: DarwinInitializationSettings(),
        ),
      );

      // ------------------------------------------------------
      // ANDROID CHANNELS + PERMISSIONS
      // ------------------------------------------------------

      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            _normalChannelId,
            'Daily Plan',
            description:
                'Daily normal notification with the plan of the day.',
            importance: Importance.defaultImportance,
          ),
        );

        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            _popupChannelId,
            'Daily Plan Pop-up',
            description:
                'Daily pop-up (heads-up) notification with the plan of the day.',
            importance: Importance.max,
            enableVibration: true,
          ),
        );

        // Android 13+ runtime permission.
        await android.requestNotificationsPermission();

        // Exact alarms so the daily schedule is precise.
        await android.requestExactAlarmsPermission();
      }

      // ------------------------------------------------------
      // IOS PERMISSIONS
      // ------------------------------------------------------

      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // ------------------------------------------------------
      // SCHEDULE THE DAILY NOTIFICATIONS
      // ------------------------------------------------------

      await scheduleDailyPlan(hour: hour, minute: minute);

      _initialized = true;
    } catch (e) {
      // Notifications must never crash the app.
      debugPrint(
        'DailyPlanNotificationService init failed: $e',
      );
    }
  }

  // ============================================================
  // SCHEDULE BOTH DAILY NOTIFICATIONS
  //
  // Safe to call again at any time - it replaces the
  // previously scheduled notifications.
  // ============================================================

  Future<void> scheduleDailyPlan({
    int hour = defaultHour,
    int minute = defaultMinute,
  }) async {
    try {
      final isArabic = await _isInterfaceArabic();

      // Cancel any previous scheduling first.
      await _plugin.cancel(id: _normalNotificationId);
      await _plugin.cancel(id: _popupNotificationId);

      // ----------------------------------------------------
      // 1) NORMAL NOTIFICATION - full plan in the tray
      // ----------------------------------------------------

      await _plugin.zonedSchedule(
        id: _normalNotificationId,
        title: _planTitle(isArabic),
        body: _planBody(isArabic),
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _normalChannelId,
            'Daily Plan',
            channelDescription:
                'Daily normal notification with the plan of the day.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(
              _planBody(isArabic),
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_plan',
      );

      // ----------------------------------------------------
      // 2) POP-UP NOTIFICATION - heads-up / full screen
      // ----------------------------------------------------

      await _plugin.zonedSchedule(
        id: _popupNotificationId,
        title: _planTitle(isArabic),
        body: _popupBody(isArabic),
        scheduledDate: _nextInstanceOf(hour, minute + 5),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _popupChannelId,
            'Daily Plan Pop-up',
            channelDescription:
                'Daily pop-up (heads-up) notification with the plan of the day.',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
            interruptionLevel:
                InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_plan_popup',
      );
    } catch (e) {
      debugPrint(
        'DailyPlanNotificationService schedule failed: $e',
      );
    }
  }

  // ============================================================
  // SHOW TODAY'S PLAN IMMEDIATELY
  //
  // Handy for testing without waiting for 08:00.
  // ============================================================

  Future<void> showTodayPlanPreview() async {
    try {
      final isArabic = await _isInterfaceArabic();

      await _plugin.show(
        id: _normalNotificationId,
        title: _planTitle(isArabic),
        body: _planBody(isArabic),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _normalChannelId,
            'Daily Plan',
            channelDescription:
                'Daily normal notification with the plan of the day.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: BigTextStyleInformation(
              _planBody(isArabic),
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        payload: 'daily_plan',
      );

      await _plugin.show(
        id: _popupNotificationId,
        title: _planTitle(isArabic),
        body: _popupBody(isArabic),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _popupChannelId,
            'Daily Plan Pop-up',
            channelDescription:
                'Daily pop-up (heads-up) notification with the plan of the day.',
            importance: Importance.max,
            priority: Priority.max,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
            interruptionLevel:
                InterruptionLevel.timeSensitive,
          ),
        ),
        payload: 'daily_plan_popup',
      );
    } catch (e) {
      debugPrint(
        'DailyPlanNotificationService preview failed: $e',
      );
    }
  }

  // ============================================================
  // TODAY'S PLAN CONTENT
  // ============================================================

  String _planTitle(bool isArabic) =>
      isArabic ? 'خطة اليوم' : "Today's Plan";

  String _planBody(bool isArabic) {
    final day = LiturgicalCalendarService().forDate(
      DateTime.now(),
    );

    final buffer = StringBuffer();

    // Coptic date line.
    buffer.writeln(
      isArabic
          ? day.copticDate.displayArabic
          : day.copticDate.display,
    );

    // Season / fast line.
    final seasonLine = _seasonLine(day, isArabic);

    if (seasonLine.isNotEmpty) {
      buffer.writeln(seasonLine);
    }

    buffer.writeln('');

    // Readings references.
    buffer.write(
      day.readings.map((r) => r.reference).join(' • '),
    );

    return buffer.toString();
  }

  String _popupBody(bool isArabic) {
    final day = LiturgicalCalendarService().forDate(
      DateTime.now(),
    );

    return isArabic
        ? 'خطتك لليوم جاهزة - ${day.copticDate.displayArabic}'
        : "Your plan for today is ready - "
            '${day.copticDate.display}';
  }

  String _seasonLine(LiturgicalDay day, bool isArabic) {
    final parts = <String>[];

    parts.add(_seasonName(day.season, isArabic));

    if (day.fastName != null &&
        day.fastName!.isNotEmpty) {
      parts.add(day.fastName!);
    }

    return parts.join(' • ');
  }

  String _seasonName(
    LiturgicalSeason season,
    bool isArabic,
  ) {
    switch (season) {
      case LiturgicalSeason.nativityFast:
        return isArabic ? 'صوم الميلاد' : 'Nativity Fast';

      case LiturgicalSeason.greatFast:
        return isArabic ? 'الصوم الكبير' : 'Great Fast';

      case LiturgicalSeason.holyWeek:
        return isArabic ? 'أسبوع الآلام' : 'Holy Week';

      case LiturgicalSeason.pentecost:
        return isArabic ? 'العنصرة' : 'Pentecost';

      case LiturgicalSeason.annual:
        return isArabic ? 'السنوي' : 'Annual';
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Next occurrence of [hour]:[minute] in local time.
  /// If that time already passed today -> tomorrow.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Reads the stored interface language directly from
  /// SharedPreferences (works before Riverpod restores).
  Future<bool> _isInterfaceArabic() async {
    try {
      final storage =
          await SharedPreferences.getInstance();

      return storage.getString(
            PreferencesNotifier.interfaceLanguageStorageKey,
          ) ==
          'arabic';
    } catch (_) {
      return false;
    }
  }

  /// Finds an IANA time zone matching the device's
  /// current offset + local wall clock. Falls back to UTC.
  String _detectTimeZoneName() {
    final now = DateTime.now();

    for (final location
        in tz.timeZoneDatabase.locations.values) {
      final local = tz.TZDateTime.now(location);

      if (local.timeZoneOffset == now.timeZoneOffset &&
          local.hour == now.hour &&
          local.day == now.day &&
          local.month == now.month) {
        return location.name;
      }
    }

    return 'UTC';
  }
}