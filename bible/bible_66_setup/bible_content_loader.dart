// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// import 'bible_models.dart';

// class BibleContentLoader {
//   const BibleContentLoader();

//   Future<BibleChapter?> loadChapter({
//     required String bookId,
//     required int chapterNumber,
//     String language = 'en',
//   }) async {
//     try {
//       final path = 'assets/bible/$language/$bookId.json';
//       final jsonString = await rootBundle.loadString(path);
//       final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

//       final chapters = jsonData['chapters'] as List<dynamic>? ?? [];

//       for (final rawChapter in chapters) {
//         final chapter = rawChapter as Map<String, dynamic>;
//         final number = (chapter['chapterNumber'] as num?)?.toInt();

//         if (number != chapterNumber) continue;

//         final rawVerses = chapter['verses'] as List<dynamic>? ?? [];

//         final verses = rawVerses.map((rawVerse) {
//           final verse = rawVerse as Map<String, dynamic>;

//           return BibleVerse(
//             number: (verse['number'] as num).toInt(),
//             text: verse['text'] as String? ?? '',
//           );
//         }).toList();

//         return BibleChapter(
//           bookId: bookId,
//           chapterNumber: chapterNumber,
//           verses: verses,
//         );
//       }

//       return null;
//     } catch (e, stackTrace) {
//       debugPrint('Bible content loading error: $e');
//       debugPrint('$stackTrace');
//       return null;
//     }
//   }
// }
