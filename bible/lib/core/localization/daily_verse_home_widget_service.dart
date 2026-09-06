// ================================================================
// DAILY VERSE HOME-SCREEN WIDGET SERVICE
//
// Pushes آية اليوم (the deterministic verse-of-the-day from
// DailyVerseRepository) to the native DailyVerseWidgetProvider.
//
// To USE the widget: long-press home screen -> Widgets ->
// Soma -> "Daily Verse".
// ================================================================

import 'package:home_widget/home_widget.dart';

import 'daily_verse.dart';

class DailyVerseHomeWidgetService {
  DailyVerseHomeWidgetService._();

  /// Native receiver class name (Android).
  static const String _androidProviderName =
      'DailyVerseWidgetProvider';

  static Future<void> update() async {
    try {
      final verse = DailyVerseRepository.today;

      await HomeWidget.saveWidgetData<String>(
        'verse_text',
        verse.text,
      );

      await HomeWidget.saveWidgetData<String>(
        'verse_ref',
        verse.reference,
      );

      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
      );
    } catch (_) {
      // The widget must never crash the app.
    }
  }
}
