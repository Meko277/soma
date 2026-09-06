import '../../models/daily_reading.dart';
import '../../services/coptic_calendar_service.dart';
import 'daily_readings_plan.dart';
import 'liturgical_day.dart';

class LiturgicalCalendarService {
  LiturgicalCalendarService({CopticCalendarService? copticCalendar}) : _copticCalendar = copticCalendar ?? CopticCalendarService();
  final CopticCalendarService _copticCalendar;

  LiturgicalDay forDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final copticDate = _copticCalendar.fromGregorian(normalized);
    return LiturgicalDay(gregorianDate: normalized, copticDate: copticDate, season: _seasonFor(copticDate.month), fastName: _fastFor(copticDate.month), saintName: null, readings: _readingsFor(normalized));
  }

  LiturgicalSeason _seasonFor(int month) {
    if (month == 4) return LiturgicalSeason.nativityFast;
    if (month >= 8 && month <= 9) return LiturgicalSeason.greatFast;
    return LiturgicalSeason.annual;
  }
  String? _fastFor(int month) => month == 4 ? 'Nativity Fast' : null;

  /// Real per-day readings: a deterministic daily
  /// rotation so every day has its own unique plan.
  List<DailyReading> _readingsFor(DateTime date) =>
      buildDailyReadings(date);
}
