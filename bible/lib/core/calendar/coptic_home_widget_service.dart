// ================================================================
// COPTIC CALENDAR HOME-SCREEN WIDGET SERVICE
//
// Pushes today's Coptic calendar data to the native
// Android widget (CopticCalendarWidgetProvider) via the
// home_widget plugin. Call update() whenever the app
// starts so the widget always shows fresh data.
//
// To USE the widget: long-press your phone's home
// screen -> Widgets -> Soma -> "Coptic Calendar".
// ================================================================

import 'package:home_widget/home_widget.dart';

import 'liturgical_calendar_service.dart';
import 'liturgical_day.dart';

class CopticHomeWidgetService {
  CopticHomeWidgetService._();

  /// Native receiver class name (Android).
  static const String _androidProviderName =
      'CopticCalendarWidgetProvider';

  static Future<void> update() async {
    try {
      final day = LiturgicalCalendarService().forDate(
        DateTime.now(),
      );

      final now = DateTime.now();

      await HomeWidget.saveWidgetData<String>(
        'coptic_date',
        day.copticDate.display,
      );

      await HomeWidget.saveWidgetData<String>(
        'coptic_date_ar',
        day.copticDate.displayArabic,
      );

      await HomeWidget.saveWidgetData<String>(
        'gregorian_date',
        '${now.day}/${now.month}/${now.year}',
      );

      await HomeWidget.saveWidgetData<String>(
        'season_name',
        _seasonName(day.season),
      );

      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
      );
    } catch (_) {
      // The widget must never crash the app.
    }
  }

  static String _seasonName(LiturgicalSeason season) {
    switch (season) {
      case LiturgicalSeason.nativityFast:
        return 'Nativity Fast • صوم الميلاد';

      case LiturgicalSeason.greatFast:
        return 'Great Fast • الصوم الكبير';

      case LiturgicalSeason.holyWeek:
        return 'Holy Week • أسبوع الآلام';

      case LiturgicalSeason.pentecost:
        return 'Pentecost • العنصرة';

      case LiturgicalSeason.annual:
        return 'Annual • السنوي';
    }
  }
}
