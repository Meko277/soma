// ================================================================
// COPTIC TRANSLATOR SERVICE
//
// Clean service interface + implementations for Coptic <-> Arabic
// (and English glossary) translation. The UI talks to ONE type
// [CopticTranslatorService] via createCopticTranslatorService().
//
// Resolution is OFFLINE-FIRST:
//   1. Offline lexicon - exact phrase match, then word-by-word.
//   2. Coptic Compass  - optional online dict word-lookup (real
//      public API, no key). Only WORD lookup, never faked.
//   3. Generic gateway - optional online API configured via
//      --dart-define (sentence/phrase capable, if you have one).
//
// Network is touched ONLY during translate() calls from the
// translator screen. Bible / Agpeya / readings / Traneem etc.
// always work offline.
// ================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'coptic_lexicon.dart';
import 'translator_models.dart';

// ================================================================
// CONSTANTS
// ================================================================

/// Source labels shown in the UI.
const String kTranslatorSourceOffline = 'offline';
const String kTranslatorSourceOnline = 'online';

/// Language codes used across all translator backends.
class TCode {
  const TCode._();

  static const String coptic = 'copt';
  static const String arabic = 'ar';
  static const String english = 'en';
}

// ================================================================
// SERVICE INTERFACE
// ================================================================

abstract class CopticTranslatorService {
  /// Whether this backend supports the given direction.
  bool supports(String from, String to);

  /// Translate [request.text] from [request.from] to [request.to].
  ///
  /// Throws [TranslatorUnavailableException] when the backend
  /// cannot fulfil the request. Never throws for "not found" —
  /// return an empty [TranslationResult] instead so the UI can
  /// show a graceful "not in dictionary" row.
  Future<TranslationResult> translate(TranslationRequest request);
}

// ================================================================
// OFFLINE LEXICON (always available, no network)
// ================================================================

/// Normalises a word/token so lookups are accent-insensitive.
/// Uses a rune filter instead of \u escapes (the regex engine
/// in older Dart SDKs struggled with \uXXXX in patterns).
String _normalize(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    // Strip combining diacritics (U+0300-U+036F).
    if (rune >= 0x0300 && rune <= 0x036F) {
      continue;
    }
    // Strip combining Arabic diacritics (U+064B-U+065F).
    if (rune >= 0x064B && rune <= 0x065F) {
      continue;
    }
    // Strip the Coptic existential underscore mark.
    if (rune == 0x0333) {
      continue;
    }
    buffer.writeCharCode(rune);
  }
  // Collapse whitespace + trim + lowercase.
  return buffer
      .toString()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}

/// Offline lexicon translator backed by copticLexicon + copticPhrases.
class OfflineLexiconTranslatorService
    implements CopticTranslatorService {
  @override
  bool supports(String from, String to) =>
      (from == TCode.coptic &&
          (to == TCode.arabic || to == TCode.english)) ||
      (from == TCode.arabic && to == TCode.coptic) ||
      (from == TCode.english && to == TCode.coptic);

  @override
  Future<TranslationResult> translate(
    TranslationRequest request,
  ) async {
    final input = request.text.trim();
    if (input.isEmpty) {
      return const TranslationResult();
    }

    // Coptic -> X : check phrases first.
    if (request.from == TCode.coptic) {
      final norm = _normalize(input);

      // 1) Exact phrase match.
      for (final entry in copticPhrases) {
        if (_normalize(entry.coptic) == norm) {
          final value = request.to == TCode.arabic
              ? entry.arabic
              : entry.english;
          return TranslationResult(
            exactMatch: value,
            sourceLabel: kTranslatorSourceOffline,
          );
        }
      }

      // 2) Word-by-word lookup.
      final tokens = _tokenizeCoptic(input);
      final pairs = <TranslationWordPair>[];
      for (final token in tokens) {
                final match = _lookupCopticWord(token.normalized);
        if (match != null) {
          final value = request.to == TCode.arabic
              ? match.arabic
              : match.english;
          pairs.add((token.original, value));
        } else {
          pairs.add((token.original, ''));
        }
      }
      return TranslationResult(
        words: pairs,
        sourceLabel: kTranslatorSourceOffline,
      );
    }

    // Arabic / English -> Coptic : reverse lookup.
    if (request.from == TCode.arabic ||
        request.from == TCode.english) {
      final norm = _normalize(input);

      // 1) Exact phrase match (reverse).
      for (final entry in copticPhrases) {
        if (request.from == TCode.arabic &&
            _normalize(entry.arabic) == norm) {
          return TranslationResult(
            exactMatch: entry.coptic,
            sourceLabel: kTranslatorSourceOffline,
          );
        }
        if (request.from == TCode.english &&
            _normalize(entry.english) == norm) {
          return TranslationResult(
            exactMatch: entry.coptic,
            sourceLabel: kTranslatorSourceOffline,
          );
        }
      }

      // 2) Word-by-word reverse lookup.
      final tokens = input.split(RegExp(r'\s+'));
      final pairs = <TranslationWordPair>[];
      for (final token in tokens) {
        final match = _lookupReverseWord(token, request.from);
        if (match != null) {
          pairs.add((token, match.coptic));
        } else {
          pairs.add((token, ''));
        }
      }
      return TranslationResult(
        words: pairs,
        sourceLabel: kTranslatorSourceOffline,
      );
    }

    return const TranslationResult();
  }
}

/// A token + its original (pre-normalisation) surface form.
class _Token {
  const _Token(this.original, this.normalized);
  final String original;
  final String normalized;
}

/// Splits Coptic input into word tokens, keeping the original
/// surface text for display while normalising for lookup.
List<_Token> _tokenizeCoptic(String input) {
  final result = <_Token>[];
  for (final part in input.split(RegExp(r'\s+'))) {
    if (part.isEmpty) continue;
    result.add(_Token(part, _normalize(part)));
  }
  return result;
}

/// Looks up a single Coptic word in the offline lexicon.
CopticEntry? _lookupCopticWord(String normalizedToken) {
  for (final entry in copticLexicon) {
    if (_normalize(entry.coptic) == normalizedToken) {
      return entry;
    }
  }
  return null;
}

/// Reverse lookup: Arabic or English -> Coptic.
CopticEntry? _lookupReverseWord(
  String token,
  String from,
) {
  final norm = _normalize(token);
  for (final entry in copticLexicon) {
    if (from == TCode.arabic &&
        _normalize(entry.arabic) == norm) {
      return entry;
    }
    if (from == TCode.english &&
        _normalize(entry.english) == norm) {
      return entry;
    }
  }
  return null;
}

// ================================================================
// COPTIC COMPASS DICTIONARY (online word lookup)
// ================================================================

/// Wraps the real, documented Coptic Compass public dictionary API.
///
/// Endpoint (per official docs):
///   GET https://www.copticcompass.com/api/v1/dictionary/search
///   GET https://www.copticcompass.com/api/v1/dictionary/search-index
///
/// NO API key is required for the dictionary endpoints — the docs
/// state they are public. If a key becomes required, it is supplied
/// via --dart-define=COPTIC_COMPASS_API_KEY at build/run time; it is
/// never hard-coded in source.
///
/// Capabilities (honest, per the documented contract):
///   - WORD lookup: Coptic -> Arabic definitions + synonyms.
///   - NO sentence/phrase translation via these endpoints.
///
/// The UI must not pretend this returns full sentence translation.
class CopticCompassDictionaryService {
  CopticCompassDictionaryService({
    String? apiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  })  : _apiKey = (apiKey ??
            const String.fromEnvironment('COPTIC_COMPASS_API_KEY'))
            .trim(),
        _client = client ?? http.Client();

  static const String _baseUrl =
      'https://www.copticcompass.com/api/v1/dictionary';

  final String _apiKey;
  final http.Client _client;
  final Duration timeout;

  /// Whether this service is usable (always true; the public dict
  /// endpoints require no key, but we expose it for transparency).
  bool get isConfigured => true;

  /// Word-level lookup: Coptic -> Arabic.
  ///
  /// Returns the first definition's Arabic text, or null if the
  /// word is not in the dictionary.
  Future<String?> lookupArabic(String copticWord) async {
    if (copticWord.trim().isEmpty) {
      return null;
    }

    final uri = Uri.parse('$_baseUrl/search').replace(
      queryParameters: {'word': copticWord.trim()},
    );

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (_apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return null;
      }

      return _extractArabicDefinition(response.body);
    } catch (_) {
      return null; // Offline / timeout / parse error -> graceful.
    }
  }

  /// Extracts the first Arabic definition from the documented
  /// search response shape.
  String? _extractArabicDefinition(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      // Documented response shape (array of results):
      //   {"results": [{"definitions": [{"definition_ar": "..."}], ...], ...]}
      final results = decoded['results'];
      if (results is List && results.isNotEmpty) {
        final first = results.first;
        if (first is Map<String, dynamic>) {
          final defs = first['definitions'];
          if (defs is List && defs.isNotEmpty) {
            final d = defs.first;
            if (d is Map<String, dynamic>) {
              final ar = d['definition_ar'];
              if (ar is String && ar.trim().isNotEmpty) {
                return ar.trim();
              }
            }
          }
        }
      }

      // Single-result fallback shape:
      //   {"definition_ar": "...", "definitions": [...]}
      final direct = decoded['definition_ar'];
      if (direct is String && direct.trim().isNotEmpty) {
        return direct.trim();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

// ================================================================
// OPTIONAL ONLINE GATEWAY BACKEND (sentence/phrase capable)
// ================================================================

/// Endpoint + key are supplied at BUILD/RUN time via --dart-define:
///
///   flutter build apk --dart-define=COPTIC_TRANSLATOR_API_URL=https://...
///                      --dart-define=COPTIC_TRANSLATOR_API_KEY=your_key
///
/// No URL or key is hard-coded in source code. When no URL is
/// configured this backend reports [isConfigured] == false and is
/// never used by the composite service.
const String _kEnvApiUrl = String.fromEnvironment(
  'COPTIC_TRANSLATOR_API_URL',
);
const String _kEnvApiKey = String.fromEnvironment(
  'COPTIC_TRANSLATOR_API_KEY',
);

/// A generic online translation gateway for sentence/phrase work
/// (e.g. a custom Coptic LLM proxy or translation service).
///
/// Only used when COPTIC_TRANSLATOR_API_URL is supplied and supports
/// the requested direction. Never faked.
class RemoteCopticTranslatorService
    implements CopticTranslatorService {
  RemoteCopticTranslatorService({
    String? apiUrl,
    String? apiKey,
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  })  : _apiUrl = (apiUrl ?? _kEnvApiUrl).trim(),
        _apiKey = (apiKey ?? _kEnvApiKey).trim(),
        _client = client ?? http.Client();

  final String _apiUrl;
  final String _apiKey;
  final http.Client _client;

  final Duration timeout;

  static const int _maxCacheEntries = 128;
  final Map<String, TranslationResult> _cache = {};

  bool get isConfigured => _apiUrl.isNotEmpty;

  @override
  bool supports(String from, String to) =>
      isConfigured &&
      (from == TCode.coptic ||
          from == TCode.arabic ||
          from == TCode.english) &&
      (to == TCode.coptic ||
          to == TCode.arabic ||
          to == TCode.english) &&
      from != to;

  @override
  Future<TranslationResult> translate(
    TranslationRequest request,
  ) async {
    if (!isConfigured) {
      throw const TranslatorUnavailableException(
        'Translator endpoint is not configured for this build.',
      );
    }

    if (!supports(request.from, request.to)) {
      throw const TranslatorUnavailableException(
        'Direction not supported by the translator endpoint.',
      );
    }

    final text = request.text.trim();
    if (text.isEmpty) {
      return const TranslationResult();
    }

    final key = '${request.from}>${request.to}:$text';
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (_apiKey.isNotEmpty)
                'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'text': text,
              'from': request.from,
              'to': request.to,
            }),
          )
          .timeout(timeout);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw TranslatorUnavailableException(
          'Translator endpoint error (HTTP ${response.statusCode}).',
        );
      }

      final translated = _extractTranslation(response.body);

      if (translated == null || translated.isEmpty) {
        throw const TranslatorUnavailableException(
          'Translator endpoint returned an empty response.',
        );
      }

      final result = TranslationResult(
        exactMatch: translated,
        fromRemote: true,
        sourceLabel: kTranslatorSourceOnline,
      );

      if (_cache.length >= _maxCacheEntries) {
        _cache.clear();
      }
      _cache[key] = result;

      return result;
    } on TranslatorUnavailableException {
      rethrow;
    } on TimeoutException {
      throw const TranslatorUnavailableException(
        'The translation service took too long to respond.',
      );
    } catch (_) {
      throw const TranslatorUnavailableException(
        'Could not reach the translation service. '
        'Check your connection.',
      );
    }
  }

  String? _extractTranslation(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final key in const [
          'translation',
          'result',
          'translated',
          'text',
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      } else if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}

// ================================================================
// COMPOSITE FRONT DOOR (offline-first, optional upgrade)
// ================================================================

class CompositeCopticTranslatorService
    implements CopticTranslatorService {
  CompositeCopticTranslatorService({
    required this.offline,
    this.remote,
  });

  final CopticTranslatorService offline;
  final CopticTranslatorService? remote;

  bool get isRemoteConfigured => remote != null;

  final CopticCompassDictionaryService compass =
      CopticCompassDictionaryService();

  @override
  bool supports(String from, String to) =>
      offline.supports(from, to) ||
      (remote?.supports(from, to) ?? false);

  @override
  Future<TranslationResult> translate(
    TranslationRequest request,
  ) async {
    TranslationResult? offlineResult;
    if (offline.supports(request.from, request.to)) {
      offlineResult = await offline.translate(request);
    }

    if (offlineResult != null &&
        offlineResult.exactMatch != null &&
        offlineResult.exactMatch!.isNotEmpty) {
      return offlineResult;
    }

    if (request.from == TCode.coptic &&
        request.to == TCode.arabic) {
      final tokens = _tokenizeCoptic(request.text.trim());
      final words = tokens
          .map((t) => t.original)
          .where((w) => w.isNotEmpty)
          .toList();

      if (words.isNotEmpty) {
        final upgraded = await _lookupWordsViaCompass(words);

        final merged = <TranslationWordPair>[];
        final offlineWords = offlineResult?.words ?? [];

        if (offlineWords.isNotEmpty) {
          for (var i = 0; i < offlineWords.length; i++) {
            final pair = offlineWords[i];
            if (pair.$2.isNotEmpty) {
              merged.add(pair);
            } else if (i < upgraded.length &&
                upgraded[i] != null) {
              merged.add((pair.$1, upgraded[i]!));
            } else {
              merged.add(pair);
            }
          }
        } else {
          for (var i = 0; i < words.length; i++) {
            final def =
                (i < upgraded.length) ? upgraded[i] : null;
            merged.add((words[i], def ?? ''));
          }
        }

        final hasMatch =
            merged.any((p) => p.$2.trim().isNotEmpty);

        if (hasMatch) {
          return TranslationResult(
            words: merged,
            sourceLabel: hasMatch
                ? kTranslatorSourceOnline
                : kTranslatorSourceOffline,
            fromRemote: hasMatch,
          );
        }
      }
    }

    final remoteService = remote;
    if (remoteService != null &&
        remoteService.supports(request.from, request.to) &&
        offlineResult?.exactMatch == null) {
      try {
        final result =
            await remoteService.translate(request);
        if (result.exactMatch != null &&
            result.exactMatch!.trim().isNotEmpty) {
          return result;
        }
      } on TranslatorUnavailableException {
        // fall through
      } catch (_) {
        // fall through
      }
    }

    if (offlineResult != null && !offlineResult.isEmpty) {
      return offlineResult;
    }

    return const TranslationResult();
  }

  Future<List<String?>> _lookupWordsViaCompass(
    List<String> words,
  ) async {
    final results = <String?>[];
    for (final word in words) {
      results.add(await compass.lookupArabic(word));
    }
    return results;
  }

  void dispose() {
    compass.dispose();
    if (remote is RemoteCopticTranslatorService) {
      (remote as RemoteCopticTranslatorService).dispose();
    }
  }
}

CopticTranslatorService createCopticTranslatorService() {
  final remote = RemoteCopticTranslatorService();
  return CompositeCopticTranslatorService(
    offline: OfflineLexiconTranslatorService(),
    remote: remote.isConfigured ? remote : null,
  );
}

