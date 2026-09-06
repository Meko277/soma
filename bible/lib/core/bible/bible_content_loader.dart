import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bible_models.dart';

class BibleContentLoader {
  const BibleContentLoader();

  Future<BibleChapter?> loadChapter({
    required String bookId,
    required int chapterNumber,
    String language = 'en',
  }) async {
    final fileName = _fileNameForBook(bookId);
    final path = 'assets/bible/$language/$fileName.json';

    if (kDebugMode) {
      debugPrint('========================================');
      debugPrint('Loading Bible chapter');
      debugPrint('Book ID: $bookId');
      debugPrint('Chapter: $chapterNumber');
      debugPrint('Language: $language');
      debugPrint('File: $path');
      debugPrint('========================================');
    }

    try {
      // ----------------------------------------------------------
      // Load JSON file
      // ----------------------------------------------------------

      final jsonString = await rootBundle.loadString(path);

      if (jsonString.trim().isEmpty) {
        debugPrint('ERROR: JSON file is empty: $path');
        return null;
      }

      // ----------------------------------------------------------
      // Decode JSON
      // ----------------------------------------------------------

      final decoded = json.decode(jsonString);

      if (decoded is! Map) {
        debugPrint('ERROR: Root JSON is not an object: $path');
        return null;
      }

      final data = Map<String, dynamic>.from(decoded);

      // ----------------------------------------------------------
      // Validate chapters
      // ----------------------------------------------------------

      final chaptersData = data['chapters'];

      if (chaptersData is! List) {
        debugPrint('ERROR: "chapters" is not a List in $path');
        debugPrint('Available keys: ${data.keys.toList()}');
        return null;
      }

      debugPrint(
        'Found ${chaptersData.length} chapters in $path',
      );

      // ----------------------------------------------------------
      // Find requested chapter
      // ----------------------------------------------------------

      Map<String, dynamic>? chapterData;

      for (final item in chaptersData) {
        if (item is! Map) {
          continue;
        }

        final chapter = Map<String, dynamic>.from(item);

        final number = chapter['chapterNumber'];

        int? parsedNumber;

        if (number is int) {
          parsedNumber = number;
        } else if (number is String) {
          parsedNumber = int.tryParse(number);
        }

        if (parsedNumber == chapterNumber) {
          chapterData = chapter;
          break;
        }
      }

      if (chapterData == null) {
        debugPrint(
          'ERROR: Chapter $chapterNumber not found in $path',
        );

        return null;
      }

      // ----------------------------------------------------------
      // Get verses
      // ----------------------------------------------------------

      final versesData = chapterData['verses'];

      if (versesData is! List) {
        debugPrint(
          'ERROR: "verses" is not a List in $path',
        );

        return null;
      }

      if (versesData.isEmpty) {
        debugPrint(
          'WARNING: Chapter $chapterNumber has no verses in $path',
        );
      }

      // ----------------------------------------------------------
      // Convert verses
      // ----------------------------------------------------------

      final List<BibleVerse> verses = [];

      for (final item in versesData) {
        if (item is! Map) {
          continue;
        }

        final verse = Map<String, dynamic>.from(item);

        final rawNumber = verse['number'];
        final rawText = verse['text'];

        int? verseNumber;

        if (rawNumber is int) {
          verseNumber = rawNumber;
        } else if (rawNumber is String) {
          verseNumber = int.tryParse(rawNumber);
        }

        if (verseNumber == null) {
          debugPrint(
            'WARNING: Invalid verse number in $path',
          );
          continue;
        }

        final text = rawText?.toString() ?? '';

        verses.add(
          BibleVerse(
            number: verseNumber,
            text: text,
          ),
        );
      }

      // ----------------------------------------------------------
      // Make sure we actually got verses
      // ----------------------------------------------------------

      if (verses.isEmpty) {
        debugPrint(
          'ERROR: No valid verses found in $path',
        );

        return null;
      }

      // ----------------------------------------------------------
      // Book name
      // ----------------------------------------------------------

      final jsonBookName =
          data['bookName']?.toString() ?? bookId;

      debugPrint(
        'SUCCESS: Loaded $bookId chapter $chapterNumber',
      );

      debugPrint(
        'Verses loaded: ${verses.length}',
      );

      // ----------------------------------------------------------
      // Return chapter
      // ----------------------------------------------------------

      return BibleChapter(
        bookId: bookId,
        bookName: jsonBookName,
        chapterNumber: chapterNumber,
        verses: verses,
      );
    } catch (e, stackTrace) {
      // Building the stack-trace string in release builds is pure
      // waste — keep this diagnostics block debug-only.
      if (kDebugMode) {
        debugPrint('========================================');
        debugPrint('FAILED TO LOAD BIBLE CHAPTER');
        debugPrint('File: $path');
        debugPrint('Book: $bookId');
        debugPrint('Chapter: $chapterNumber');
        debugPrint('Language: $language');
        debugPrint('Error: $e');
        debugPrint('StackTrace: $stackTrace');
        debugPrint('========================================');
      }

      return null;
    }
  }

  // ============================================================
  // FILE NAME MAPPING
  // ============================================================

  String _fileNameForBook(String bookId) {
    const fileNames = <String, String>{

      // ==========================================================
      // OLD TESTAMENT
      // ==========================================================

      'genesis': 'genesis',
      'exodus': 'exodus',
      'leviticus': 'leviticus',
      'numbers': 'numbers',
      'deuteronomy': 'deuteronomy',

      'joshua': 'joshua',
      'judges': 'judges',
      'ruth': 'ruth',

      '1samuel': '1-samuel',
      '2samuel': '2-samuel',

      '1kings': '1-kings',
      '2kings': '2-kings',

      '1chronicles': '1-chronicles',
      '2chronicles': '2-chronicles',

      'ezra': 'ezra',
      'nehemiah': 'nehemiah',
      'esther': 'esther',

      'job': 'job',
      'psalms': 'psalms',
      'proverbs': 'proverbs',
      'ecclesiastes': 'ecclesiastes',
      'songofsolomon': 'song-of-solomon',

      'isaiah': 'isaiah',
      'jeremiah': 'jeremiah',
      'lamentations': 'lamentations',
      'ezekiel': 'ezekiel',
      'daniel': 'daniel',

      'hosea': 'hosea',
      'joel': 'joel',
      'amos': 'amos',
      'obadiah': 'obadiah',
      'jonah': 'jonah',
      'micah': 'micah',
      'nahum': 'nahum',
      'habakkuk': 'habakkuk',
      'zephaniah': 'zephaniah',
      'haggai': 'haggai',
      'zechariah': 'zechariah',
      'malachi': 'malachi',

      // ==========================================================
      // NEW TESTAMENT
      // ==========================================================

      'matthew': 'matthew',
      'mark': 'mark',
      'luke': 'luke',
      'john': 'john',

      'acts': 'acts',

      'romans': 'romans',

      '1corinthians': '1-corinthians',
      '2corinthians': '2-corinthians',

      'galatians': 'galatians',
      'ephesians': 'ephesians',
      'philippians': 'philippians',
      'colossians': 'colossians',

      '1thessalonians': '1-thessalonians',
      '2thessalonians': '2-thessalonians',

      '1timothy': '1-timothy',
      '2timothy': '2-timothy',

      'titus': 'titus',
      'philemon': 'philemon',
      'hebrews': 'hebrews',
      'james': 'james',

      '1peter': '1-peter',
      '2peter': '2-peter',

      '1john': '1-john',
      '2john': '2-john',
      '3john': '3-john',

      'jude': 'jude',
      'revelation': 'revelation',
    };

    final result = fileNames[bookId];

    if (result == null) {
      debugPrint(
        'WARNING: No filename mapping found for bookId: $bookId',
      );

      return bookId;
    }

    return result;
  }
}
