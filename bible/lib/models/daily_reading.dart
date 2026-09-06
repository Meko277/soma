/// Who reads this part of the service,
/// following the Coptic rite (like the
/// Coptic Reader app).
enum ReadingRole {
  people,
  deacons,
  priests,
}

class DailyReading {
  const DailyReading({
    required this.title,
    this.titleAr,
    required this.reference,
    this.excerpt = '',
    this.excerptAr,
    this.bookId,
    this.chapter,
    this.readBy = ReadingRole.deacons,
  });

  /// Reading name in English (e.g. 'Psalm').
  final String title;

  /// Reading name in Arabic (e.g. 'المزمور').
  final String? titleAr;

  /// Scripture reference (e.g. 'Psalm 23:1-6').
  final String reference;

  /// Short verse preview in English.
  final String excerpt;

  /// Short verse preview in Arabic.
  final String? excerptAr;

  /// Bible book id used to OPEN the reading in the
  /// reader (e.g. 'psalms'). Null = not openable.
  final String? bookId;

  /// Chapter number to open with [bookId].
  final int? chapter;

  /// Who reads this reading: the people, the
  /// deacons or the priests.
  final ReadingRole readBy;
}

class DailyOffice {
  const DailyOffice({required this.dateLabel, required this.season, required this.readings});

  final String dateLabel;
  final String season;
  final List<DailyReading> readings;
}