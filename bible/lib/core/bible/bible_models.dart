enum BibleTestament {
  old,
  newTestament,
}

class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.testament,
    required this.chapterCount,
  });

  final String id;
  final String name;
  final String arabicName;
  final BibleTestament testament;
  final int chapterCount;
}

class BibleChapter {
  const BibleChapter({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
  });

  final String bookId;
  final String bookName;
  final int chapterNumber;
  final List<BibleVerse> verses;
}

class BibleVerse {
  const BibleVerse({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;
}