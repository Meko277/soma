import '../../models/coptic_date.dart';
import '../../models/daily_reading.dart';

enum LiturgicalSeason { annual, nativityFast, greatFast, holyWeek, pentecost }

class LiturgicalDay {
  const LiturgicalDay({required this.gregorianDate, required this.copticDate, required this.season, required this.fastName, required this.saintName, required this.readings});
  final DateTime gregorianDate;
  final CopticDate copticDate;
  final LiturgicalSeason season;
  final String? fastName;
  final String? saintName;
  final List<DailyReading> readings;
}
