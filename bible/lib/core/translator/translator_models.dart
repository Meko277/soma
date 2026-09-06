// ================================================================
// COPTIC TRANSLATOR MODELS
//
// Shared request/result types for every Coptic translator backend
// (offline lexicon, optional online gateway)so the UI talks to
// ONE clean interface instead of touching parsers or networks.
// ================================================================

/// Language code passed to the translation backends.
///
///   - 'cop'  → Coptic (Sahidic/Bohairic)
///   - 'ar'   → Arabic
///   - 'en'   → English (lexicon glossary)
class TranslationRequest {
  const TranslationRequest({
    required this.text,
    required this.from,
    required this.to,
  });

  final String text;
  final String from;
  final String to;
}

/// One word-by-word lookup result.
typedef TranslationWordPair = (String, String);

/// Result of a translation attempt.
class TranslationResult {
  const TranslationResult({
    this.exactMatch,
    this.words = const [],
    this.fromRemote = false,
    this.sourceLabel = '',
  });

  /// Whole-input translation (e.g. a matched phrase or the
  /// online API response). Null when only word-by-word results
  /// are available.

  final String? exactMatch;

  /// Word-by-word results: (source word, translation).
  final List<TranslationWordPair> words;

  /// Whether the result came from the optional ONLINE gateway.
  final bool fromRemote;

  /// Human-readable source label ('Offline lexicon' / 'Online API').
  final String sourceLabel;

  bool get isEmpty =>
      (exactMatch == null || exactMatch!.isEmpty) && words.isEmpty;

  /// Whether any actual translation content was found (an exact
  /// match or at least one resolved word). Rows with empty
  /// translations ("not in dictionary") do NOT count - the composite
  /// service uses this to decide whether to fall back.
  bool get hasMatches =>
      (exactMatch != null && exactMatch!.isNotEmpty) ||
      words.any((pair) => pair.$2.isNotEmpty);
}

/// Raised when a translation backend cannot fulfil a request.
/// The composite service turns this into a graceful offline fallback,
/// so it can never crash the UI.
class TranslatorUnavailableException implements Exception {
  const TranslatorUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}