import 'package:flutter/foundation.dart';
import 'bible_content_loader.dart';
import 'bible_models.dart';

class BibleContentRepository {
  BibleContentRepository({
    BibleContentLoader? loader,
  }) : _loader =
            loader ?? const BibleContentLoader();

  final BibleContentLoader _loader;

  List<BibleBook> get books => _books;

  final _books = const [
    // =========================
    // OLD TESTAMENT
    // =========================

    BibleBook(
      id: 'genesis',
      name: 'Genesis',
      arabicName: 'التكوين',
      testament: BibleTestament.old,
      chapterCount: 50,
    ),

    BibleBook(
      id: 'exodus',
      name: 'Exodus',
      arabicName: 'الخروج',
      testament: BibleTestament.old,
      chapterCount: 40,
    ),

    BibleBook(
      id: 'leviticus',
      name: 'Leviticus',
      arabicName: 'اللاويين',
      testament: BibleTestament.old,
      chapterCount: 27,
    ),

    BibleBook(
      id: 'numbers',
      name: 'Numbers',
      arabicName: 'العدد',
      testament: BibleTestament.old,
      chapterCount: 36,
    ),

    BibleBook(
      id: 'deuteronomy',
      name: 'Deuteronomy',
      arabicName: 'التثنية',
      testament: BibleTestament.old,
      chapterCount: 34,
    ),

    BibleBook(
      id: 'joshua',
      name: 'Joshua',
      arabicName: 'يشوع',
      testament: BibleTestament.old,
      chapterCount: 24,
    ),

    BibleBook(
      id: 'judges',
      name: 'Judges',
      arabicName: 'القضاة',
      testament: BibleTestament.old,
      chapterCount: 21,
    ),

    BibleBook(
      id: 'ruth',
      name: 'Ruth',
      arabicName: 'راعوث',
      testament: BibleTestament.old,
      chapterCount: 4,
    ),

    BibleBook(
      id: '1-samuel',
      name: '1 Samuel',
      arabicName: 'صموئيل الأول',
      testament: BibleTestament.old,
      chapterCount: 31,
    ),

    BibleBook(
      id: '2-samuel',
      name: '2 Samuel',
      arabicName: 'صموئيل الثاني',
      testament: BibleTestament.old,
      chapterCount: 24,
    ),

    BibleBook(
      id: '1-kings',
      name: '1 Kings',
      arabicName: 'الملوك الأول',
      testament: BibleTestament.old,
      chapterCount: 22,
    ),

    BibleBook(
      id: '2-kings',
      name: '2 Kings',
      arabicName: 'الملوك الثاني',
      testament: BibleTestament.old,
      chapterCount: 25,
    ),

    BibleBook(
      id: '1-chronicles',
      name: '1 Chronicles',
      arabicName: 'أخبار الأيام الأول',
      testament: BibleTestament.old,
      chapterCount: 29,
    ),

    BibleBook(
      id: '2-chronicles',
      name: '2 Chronicles',
      arabicName: 'أخبار الأيام الثاني',
      testament: BibleTestament.old,
      chapterCount: 36,
    ),

    BibleBook(
      id: 'ezra',
      name: 'Ezra',
      arabicName: 'عزرا',
      testament: BibleTestament.old,
      chapterCount: 10,
    ),

    BibleBook(
      id: 'nehemiah',
      name: 'Nehemiah',
      arabicName: 'نحميا',
      testament: BibleTestament.old,
      chapterCount: 13,
    ),

    BibleBook(
      id: 'esther',
      name: 'Esther',
      arabicName: 'أستير',
      testament: BibleTestament.old,
      chapterCount: 10,
    ),

    BibleBook(
      id: 'job',
      name: 'Job',
      arabicName: 'أيوب',
      testament: BibleTestament.old,
      chapterCount: 42,
    ),

    BibleBook(
      id: 'psalms',
      name: 'Psalms',
      arabicName: 'المزامير',
      testament: BibleTestament.old,
      chapterCount: 150,
    ),

    BibleBook(
      id: 'proverbs',
      name: 'Proverbs',
      arabicName: 'الأمثال',
      testament: BibleTestament.old,
      chapterCount: 31,
    ),

    BibleBook(
      id: 'ecclesiastes',
      name: 'Ecclesiastes',
      arabicName: 'الجامعة',
      testament: BibleTestament.old,
      chapterCount: 12,
    ),

    BibleBook(
      id: 'song-of-solomon',
      name: 'Song of Solomon',
      arabicName: 'نشيد الأنشاد',
      testament: BibleTestament.old,
      chapterCount: 8,
    ),

    BibleBook(
      id: 'isaiah',
      name: 'Isaiah',
      arabicName: 'إشعياء',
      testament: BibleTestament.old,
      chapterCount: 66,
    ),

    BibleBook(
      id: 'jeremiah',
      name: 'Jeremiah',
      arabicName: 'إرميا',
      testament: BibleTestament.old,
      chapterCount: 52,
    ),

    BibleBook(
      id: 'lamentations',
      name: 'Lamentations',
      arabicName: 'مراثي إرميا',
      testament: BibleTestament.old,
      chapterCount: 5,
    ),

    BibleBook(
      id: 'ezekiel',
      name: 'Ezekiel',
      arabicName: 'حزقيال',
      testament: BibleTestament.old,
      chapterCount: 48,
    ),

    BibleBook(
      id: 'daniel',
      name: 'Daniel',
      arabicName: 'دانيال',
      testament: BibleTestament.old,
      chapterCount: 12,
    ),

    BibleBook(
      id: 'hosea',
      name: 'Hosea',
      arabicName: 'هوشع',
      testament: BibleTestament.old,
      chapterCount: 14,
    ),

    BibleBook(
      id: 'joel',
      name: 'Joel',
      arabicName: 'يوئيل',
      testament: BibleTestament.old,
      chapterCount: 3,
    ),

    BibleBook(
      id: 'amos',
      name: 'Amos',
      arabicName: 'عاموس',
      testament: BibleTestament.old,
      chapterCount: 9,
    ),

    BibleBook(
      id: 'obadiah',
      name: 'Obadiah',
      arabicName: 'عوبديا',
      testament: BibleTestament.old,
      chapterCount: 1,
    ),

    BibleBook(
      id: 'jonah',
      name: 'Jonah',
      arabicName: 'يونان',
      testament: BibleTestament.old,
      chapterCount: 4,
    ),

    BibleBook(
      id: 'micah',
      name: 'Micah',
      arabicName: 'ميخا',
      testament: BibleTestament.old,
      chapterCount: 7,
    ),

    BibleBook(
      id: 'nahum',
      name: 'Nahum',
      arabicName: 'ناحوم',
      testament: BibleTestament.old,
      chapterCount: 3,
    ),

    BibleBook(
      id: 'habakkuk',
      name: 'Habakkuk',
      arabicName: 'حبقوق',
      testament: BibleTestament.old,
      chapterCount: 3,
    ),

    BibleBook(
      id: 'zephaniah',
      name: 'Zephaniah',
      arabicName: 'صفنيا',
      testament: BibleTestament.old,
      chapterCount: 3,
    ),

    BibleBook(
      id: 'haggai',
      name: 'Haggai',
      arabicName: 'حجي',
      testament: BibleTestament.old,
      chapterCount: 2,
    ),

    BibleBook(
      id: 'zechariah',
      name: 'Zechariah',
      arabicName: 'زكريا',
      testament: BibleTestament.old,
      chapterCount: 14,
    ),

    BibleBook(
      id: 'malachi',
      name: 'Malachi',
      arabicName: 'ملاخي',
      testament: BibleTestament.old,
      chapterCount: 4,
    ),

    // =========================
    // NEW TESTAMENT
    // =========================

    BibleBook(
      id: 'matthew',
      name: 'Matthew',
      arabicName: 'متى',
      testament: BibleTestament.newTestament,
      chapterCount: 28,
    ),

    BibleBook(
      id: 'mark',
      name: 'Mark',
      arabicName: 'مرقس',
      testament: BibleTestament.newTestament,
      chapterCount: 16,
    ),

    BibleBook(
      id: 'luke',
      name: 'Luke',
      arabicName: 'لوقا',
      testament: BibleTestament.newTestament,
      chapterCount: 24,
    ),

    BibleBook(
      id: 'john',
      name: 'John',
      arabicName: 'يوحنا',
      testament: BibleTestament.newTestament,
      chapterCount: 21,
    ),

    BibleBook(
      id: 'acts',
      name: 'Acts',
      arabicName: 'أعمال الرسل',
      testament: BibleTestament.newTestament,
      chapterCount: 28,
    ),

    BibleBook(
      id: 'romans',
      name: 'Romans',
      arabicName: 'رومية',
      testament: BibleTestament.newTestament,
      chapterCount: 16,
    ),

    BibleBook(
      id: '1-corinthians',
      name: '1 Corinthians',
      arabicName: 'كورنثوس الأولى',
      testament: BibleTestament.newTestament,
      chapterCount: 16,
    ),

    BibleBook(
      id: '2-corinthians',
      name: '2 Corinthians',
      arabicName: 'كورنثوس الثانية',
      testament: BibleTestament.newTestament,
      chapterCount: 13,
    ),

    BibleBook(
      id: 'galatians',
      name: 'Galatians',
      arabicName: 'غلاطية',
      testament: BibleTestament.newTestament,
      chapterCount: 6,
    ),

    BibleBook(
      id: 'ephesians',
      name: 'Ephesians',
      arabicName: 'أفسس',
      testament: BibleTestament.newTestament,
      chapterCount: 6,
    ),

    BibleBook(
      id: 'philippians',
      name: 'Philippians',
      arabicName: 'فيلبي',
      testament: BibleTestament.newTestament,
      chapterCount: 4,
    ),

    BibleBook(
      id: 'colossians',
      name: 'Colossians',
      arabicName: 'كولوسي',
      testament: BibleTestament.newTestament,
      chapterCount: 4,
    ),

    BibleBook(
      id: '1-thessalonians',
      name: '1 Thessalonians',
      arabicName: 'تسالونيكي الأولى',
      testament: BibleTestament.newTestament,
      chapterCount: 5,
    ),

    BibleBook(
      id: '2-thessalonians',
      name: '2 Thessalonians',
      arabicName: 'تسالونيكي الثانية',
      testament: BibleTestament.newTestament,
      chapterCount: 3,
    ),

    BibleBook(
      id: '1-timothy',
      name: '1 Timothy',
      arabicName: 'تيموثاوس الأولى',
      testament: BibleTestament.newTestament,
      chapterCount: 6,
    ),

    BibleBook(
      id: '2-timothy',
      name: '2 Timothy',
      arabicName: 'تيموثاوس الثانية',
      testament: BibleTestament.newTestament,
      chapterCount: 4,
    ),

    BibleBook(
      id: 'titus',
      name: 'Titus',
      arabicName: 'تيطس',
      testament: BibleTestament.newTestament,
      chapterCount: 3,
    ),

    BibleBook(
      id: 'philemon',
      name: 'Philemon',
      arabicName: 'فليمون',
      testament: BibleTestament.newTestament,
      chapterCount: 1,
    ),

    BibleBook(
      id: 'hebrews',
      name: 'Hebrews',
      arabicName: 'العبرانيين',
      testament: BibleTestament.newTestament,
      chapterCount: 13,
    ),

    BibleBook(
      id: 'james',
      name: 'James',
      arabicName: 'يعقوب',
      testament: BibleTestament.newTestament,
      chapterCount: 5,
    ),

    BibleBook(
      id: '1-peter',
      name: '1 Peter',
      arabicName: 'بطرس الأولى',
      testament: BibleTestament.newTestament,
      chapterCount: 5,
    ),

    BibleBook(
      id: '2-peter',
      name: '2 Peter',
      arabicName: 'بطرس الثانية',
      testament: BibleTestament.newTestament,
      chapterCount: 3,
    ),

    BibleBook(
      id: '1-john',
      name: '1 John',
      arabicName: 'يوحنا الأولى',
      testament: BibleTestament.newTestament,
      chapterCount: 5,
    ),

    BibleBook(
      id: '2-john',
      name: '2 John',
      arabicName: 'يوحنا الثانية',
      testament: BibleTestament.newTestament,
      chapterCount: 1,
    ),

    BibleBook(
      id: '3-john',
      name: '3 John',
      arabicName: 'يوحنا الثالثة',
      testament: BibleTestament.newTestament,
      chapterCount: 1,
    ),

    BibleBook(
      id: 'jude',
      name: 'Jude',
      arabicName: 'يهوذا',
      testament: BibleTestament.newTestament,
      chapterCount: 1,
    ),

    BibleBook(
      id: 'revelation',
      name: 'Revelation',
      arabicName: 'رؤيا يوحنا',
      testament: BibleTestament.newTestament,
      chapterCount: 22,
    ),
  ];

 BibleBook? bookById(String id) {
  // Diagnostic output is debug-only: building the full book list
  // string on every navigation is wasted work in release builds.
  if (kDebugMode) {
    debugPrint('========== BOOK SEARCH ==========');
    debugPrint('Searching for book ID: "$id"');
    debugPrint('Available books: ${_books.map((e) => e.id).join(', ')}');
  }

  try {
    final book = _books.firstWhere(
      (e) => e.id == id,
    );

    if (kDebugMode) {
      debugPrint('FOUND BOOK: ${book.name}');
    }
    return book;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('BOOK NOT FOUND: "$id"');
    }
    return null;
  }
}

  Future<BibleChapter?> loadChapter({
    required String bookId,
    required int chapterNumber,
    String language = 'en',
  }) {
    return _loader.loadChapter(
      bookId: bookId,
      chapterNumber: chapterNumber,
      language: language,
    );
  }
}