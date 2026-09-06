import 'dart:convert';

import 'package:flutter/services.dart';

import 'traneem_models.dart';

/// Loads a single hymn's lyrics from the bundled JSON assets.
///
/// Mirrors the Agpeya / Bible content providers:
///   --path `assets/traneem/en/<id>.json`
///   - Arabic `assets/traneem/ar/<id>.json`
///
/// All loading is fully offline (bundled assets).
class TraneemContentProvider {
  const TraneemContentProvider();

  /// Load the lyrics of one hymn in [language] ('en' | 'ar').
  ///
  /// Throws [TraneemContentException] when the hymn / language
  /// has no bundled content so callers can handle it gracefully.
  Future<TraneemHymn> loadHymn(
    TraneemHymnMeta meta, {
    String language = 'en',
  }) async {
    final folder = language == 'ar' || language == 'arabic' ? 'ar' : 'en';

    final path = 'assets/traneem/$folder/${meta.id}.json';

    final jsonString = await rootBundle.loadString(path);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const TraneemContentException(
        'Invalid Traneem JSON format.',
      );
    }

    final hymn = TraneemHymn.fromJson(
      decoded,
      meta: meta,
      language: folder,
    );

    if (hymn.stanzas.isEmpty) {
      throw TraneemContentException(
        'Hymn "${meta.id}" has no lyrics in $language.',
      );
    }

    return hymn;
  }
}

/// Raised when a hymn cannot be loaded (missing/invalid content).
/// The UI turns this into a friendly error state instead of
/// crashing.
class TraneemContentException implements Exception {
  const TraneemContentException(this.message);

  final String message;

  @override
  String toString() => message;
}
