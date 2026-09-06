// ================================================================
// TRANEEM MODELS (الترانيم)
//
// Traneem is a TEXT-ONLY collection of hymn lyrics / words
// (no audio, no streaming). It follows the same content
// architecture as the Agpeya / Bible sections:
//
//   - A bilingual metadata list lives in the repository
//     (English + Arabic titles).
//   - The actual lyrics are loaded from JSON assets under
//     assets/traneem/{en,ar}/<id>.json on demand.
//
// Each language keeps its own JSON file (like the Agpeya),
// so nothing is hardcoded inside Dart widgets.
// ================================================================

/// Lightweight bilingual metadata for a hymn that appears in
/// the Traneem list. The lyrics themselves are loaded from
/// the JSON asset for the selected content language.
class TraneemHymnMeta {
  const TraneemHymnMeta({
    required this.id,
    required this.title,
    required this.arabicTitle,
    this.category,
    this.categoryAr,
  });

  /// Stable asset / route id (e.g. 'trisagion').
  final String id;

  /// English title.
  final String title;

  /// Arabic title.
  final String arabicTitle;

  /// Optional category label in English (e.g. 'Liturgical').
  final String? category;

  /// Optional category label in Arabic (e.g. 'طقسية').
  final String? categoryAr;
}

/// One chunk of a hymn — usually a verse, refrain or response.
class TraneemStanza {
  const TraneemStanza({
    this.title,
    this.lines = const [],
  });

  /// Optional label for this chunk (e.g. 'Refrain' / 'الخورية').
  final String? title;

  /// The hymn lines / words of this stanza.
  final List<String> lines;

  factory TraneemStanza.fromJson(Map<String, dynamic> json) {
    return TraneemStanza(
      title: json['title']?.toString(),
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

/// A fully loaded hymn (metadata + lyrics in one language).
class TraneemHymn {
  const TraneemHymn({
    required this.id,
    required this.title,
    required this.arabicTitle,
    this.category,
    this.categoryAr,
    this.stanzas = const [],
    this.language = 'en',
  });

  final String id;
  final String title;
  final String arabicTitle;
  final String? category;
  final String? categoryAr;

  /// The loaded stanzas / lyrics for the selected language.
  final List<TraneemStanza> stanzas;

  /// 'en' or 'ar' — the language of the loaded lyrics.
  final String language;

  factory TraneemHymn.fromJson(
    Map<String, dynamic> json, {
    required TraneemHymnMeta meta,
    String language = 'en',
  }) {
    return TraneemHymn(
      id: json['id']?.toString() ?? meta.id,
      title: json['title']?.toString() ?? meta.title,
      arabicTitle: json['arabicTitle']?.toString() ?? meta.arabicTitle,
      category: json['category']?.toString() ?? meta.category,
      categoryAr: json['categoryAr']?.toString() ?? meta.categoryAr,
      language: language,
      stanzas: (json['stanzas'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TraneemStanza.fromJson)
          .toList(),
    );
  }
}
