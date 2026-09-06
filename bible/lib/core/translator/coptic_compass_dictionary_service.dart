// ================================================================
// COPTIC COMPASS DICTIONARY SERVICE
//
// Real online word-lookup via the Coptic Compass public API.
// This is the ONLY part of the app that touches the internet
// during translation. Used as an upgrade path by the composite
// translator when the offline lexicon does not have a word.
//
// API: https://copticcompass.com/api/lookup?word=<coptic_word>
// Returns JSON: { "word": "...", "definition": "...", "arabic": "..." }
// ================================================================

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CopticCompassDictionaryService {
  CopticCompassDictionaryService({
    http.Client? client,
    this.timeout = const Duration(seconds: 6),
    this.baseUrl = 'https://copticcompass.com/api',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;
  final String baseUrl;

  static const int _maxCacheEntries = 256;
  final Map<String, String?> _cache = {};

  /// Looks up a single Coptic word and returns its Arabic meaning.
  /// Returns null when the word is not in the dictionary.
  Future<String?> lookupArabic(String copticWord) async {
    final word = copticWord.trim();
    if (word.isEmpty) return null;

    final cached = _cache[word];
    if (cached != null) return cached;

    try {
      final uri = Uri.parse('$baseUrl/lookup').replace(
        queryParameters: {'word': word, 'lang': 'ar'},
      );

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'CopticCompanion/1.0',
        },
      ).timeout(timeout);

      if (response.statusCode != 200) {
        _cache[word] = null;
        if (_cache.length > _maxCacheEntries) _cache.clear();
        return null;
      }

      final dynamic decoded = jsonDecode(response.body);
      String? arabic;

      if (decoded is Map<String, dynamic>) {
        final arabicValue = decoded['arabic'] ?? decoded['definition'] ?? decoded['meaning'];
        if (arabicValue is String && arabicValue.trim().isNotEmpty) {
          arabic = arabicValue.trim();
        }
      }

      _cache[word] = arabic;
      if (_cache.length > _maxCacheEntries) _cache.clear();
      return arabic;
    } on TimeoutException {
      _cache[word] = null;
      return null;
    } catch (_) {
      // Network error, parse error, anything: never crash.
      _cache[word] = null;
      return null;
    }
  }

  /// Releases the HTTP client.
  void dispose() {
    _client.close();
  }
}
