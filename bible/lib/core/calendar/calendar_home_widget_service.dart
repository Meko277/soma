// ================================================================
// FULL CALENDAR HOME-SCREEN WIDGET SERVICE
//
// Builds a whole-month grid (all days / weeks) enriched with
// the major FIXED Coptic feasts and pushes it to the native
// FullCalendarWidgetProvider via the home_widget plugin:
//
//   - cal_title        e.g. "August 2026"
//   - cal_subtitle     e.g. "Mesori – Nasie • مسرى"
//   - cal_week_header  e.g. "S M T W T F S"
//   - cal_grid         JSON {offset, days, today,
//                          sundayCol, events{day:name}}
//   - cal_today_event  today's feast name ('' if none)
//
// To USE the widget: long-press home screen -> Widgets ->
// Soma -> "Full Calendar".
// ================================================================

import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../models/coptic_date.dart';
import '../../services/coptic_calendar_service.dart';

class CalendarHomeWidgetService {
  CalendarHomeWidgetService._();

  /// Native receiver class name (Android).
  static const String _androidProviderName =
      'FullCalendarWidgetProvider';

  /// Major FIXED feasts keyed by their COPTIC month/day.
  /// (Moveable feasts like Easter are not listed.)
  static const List<({int month, int day, String name})>
      _feasts = [
    (month: 1, day: 1, name: 'النيروز • Coptic New Year'),
    (
      month: 1,
      day: 16,
      name: 'عيد الصليب المجيد • Feast of the Cross',
    ),
    (
      month: 3,
      day: 21,
      name: 'دخول العذراء للهيكل • Entrance of the Theotokos',
    ),
    (
      month: 4,
      day: 7,
      name: 'عيد الميلاد المجيد • Nativity of Christ',
    ),
    (
      month: 4,
      day: 29,
      name: 'عيد الغطاس • Epiphany',
    ),
    (
      month: 7,
      day: 29,
      name: 'البشارة المجيدة • Annunciation',
    ),
    (
      month: 11,
      day: 5,
      name: 'نياحة بطرس وبولس • Peter & Paul',
    ),
    (
      month: 11,
      day: 23,
      name: 'استشهاد مار جرجس • Martyrdom of St. George',
    ),
    (
      month: 12,
      day: 13,
      name: 'عيد التجلي • Transfiguration',
    ),
    (
      month: 12,
      day: 15,
      name: 'انتقال جسد العذراء • Dormition of the Theotokos',
    ),
  ];

  static const List<String> _gregorianMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static Future<void> update() async {
    try {
      final now = DateTime.now();

      final year = now.year;
      final month = now.month;

      final firstOfMonth = DateTime(year, month, 1);

      final daysInMonth =
          DateTime(year, month + 1, 0).day;

      // Leading blank slots in a Sunday-first grid.
      final offset = firstOfMonth.weekday % 7;

      // Column index that always holds Sundays.
      final sundayCol = offset % 7;

      final copticCalendar = CopticCalendarService();

      // --------------------------------------------------------
      // Map feasts onto this Gregorian month through the
      // Coptic calendar conversion.
      // --------------------------------------------------------
      final events = <int, String>{};

      String? todayEvent;

      for (var day = 1;
          day <= daysInMonth;
          day++) {
        final copticDate = copticCalendar
            .fromGregorian(
                DateTime(year, month, day));

        for (final feast in _feasts) {
          if (feast.month == copticDate.month &&
              feast.day == copticDate.day) {
            events[day] = feast.name;

            if (day == now.day) {
              todayEvent = feast.name;
            }
          }
        }
      }

      // --------------------------------------------------------
      // Titles (bilingual, matching the app widget style).
      // --------------------------------------------------------
      final title =
          '${_gregorianMonths[month - 1]} $year';

      final copticFirst = copticCalendar
          .fromGregorian(firstOfMonth);

      final copticLast = copticCalendar
          .fromGregorian(DateTime(year, month, daysInMonth));

      final subtitle = copticFirst.month ==
              copticLast.month
          ? '${copticFirst.monthName} • عام ${copticFirst.year} للشهداء'
          : '${CopticDate.months[copticFirst.month - 1]} – ${CopticDate.months[copticLast.month - 1]} • عام ${copticLast.year} للشهداء';

      // --------------------------------------------------------
      // Push everything to the native widget.
      // --------------------------------------------------------
      await HomeWidget.saveWidgetData<String>(
        'cal_title',
        title,
      );

      await HomeWidget.saveWidgetData<String>(
        'cal_subtitle',
        subtitle,
      );

      await HomeWidget.saveWidgetData<String>(
        'cal_week_header',
        'S M T W T F S',
      );

      await HomeWidget.saveWidgetData<String>(
        'cal_grid',
        jsonEncode({
          'offset': offset,
          'days': daysInMonth,
          'today': now.day,
          'sundayCol': sundayCol,
          'events': events,
        }),
      );

      await HomeWidget.saveWidgetData<String>(
        'cal_today_event',
        todayEvent ?? '',
      );

      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
      );
    } catch (_) {
      // The widget must never crash the app.
    }
  }
}
