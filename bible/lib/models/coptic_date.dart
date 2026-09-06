class CopticDate {
  const CopticDate({required this.day, required this.month, required this.year});

  final int day;
  final int month;
  final int year;

  static const months = [
    'Tout', 'Paopi', 'Hathor', 'Kiahk', 'Tobi', 'Meshir', 'Paremhat',
    'Paremoude', 'Pashons', 'Paoni', 'Epip', 'Mesori', 'Nasie',
  ];

  String get monthName => months[month - 1];
  String get display => '$day $monthName $year AM';
  String get displayArabic {
    const arabicMonths = ['توت', 'بابه', 'هاتور', 'كيهك', 'طوبه', 'أمشير', 'برمهات', 'برموده', 'بشنس', 'بؤونه', 'أبيب', 'مسرى', 'النسيء'];
    return '$day ${arabicMonths[month - 1]} $year للشهداء';
  }
}
