// ================================================================
// BIBLE CONTENT SYNC (admin edits -> app)
//
// The admin website stores each Bible book as ONE Firestore doc:
//
//   bible/<bookId>_<en|ar>
//   {
//     bookId, bookName, lang,
//     chapters: [ { chapterNumber, verses: [ {number, text} ] } ],
//     updatedAt
//   }
//
// The app reads the Bible from its bundled assets for instant
// offline rendering. This service layers the admin's Firestore
// content on top of that:
//
//   * On-demand: only the book the user is actually reading is
//     fetched (never the whole collection - that would be tens of
//     MB and jank old devices).
//   * Offline-first: the last fetched book is cached in
//     SharedPreferences, so an edit made in the admin website is
//     already visible the next time the app opens, even offline,
//     and it is refreshed whenever the app is online.
//   * Fallback: when Firestore has no doc for a book (it was never
//     edited), [BibleContentRepository] falls back to the bundled
//     asset, so the classic offline Bible keeps working.
// ================================================================

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bible_models.dart';

/// Lazily syncs admin-edited Bible books from Firestore.
class BibleContentSync {
  BibleContentSync({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// In-memory cache: "<bookId>_<lang>" -> Firestore doc data.
  final Map<String, Map<String, dynamic>> _books = {};

  /// Doc ids that already have a live snapshot listener attached.
  final Set<String> _subscribed = {};

  static const Duration _fetchTimeout = Duration(seconds: 8);

  static String _docId(String bookId, String language) =>
      '${bookId}_$language';

  static String _cacheKey(String docId) => 'sync_cache_bible_$docId';

  // ============================================================
  // PUBLIC API
  // ============================================================

  /// Returns the admin-edited chapter for [bookId]/[chapterNumber]
  /// in [language], or `null` when Firestore has nothing for it.
  ///
  /// While online this re-fetches the book so the latest admin edit
  /// is shown; while offline the last cached copy is returned.
  Future<BibleChapter?> syncedChapter({
    required String bookId,
    required int chapterNumber,
    String language = 'en',
  }) async {
    try {
      final data = await _bookData(bookId, language);
      if (data == null) return null;
      return _parseChapter(data, bookId, chapterNumber);
    } catch (_) {
      return null;
    }
  }
// ============================================================
  // FIRESTORE FETCH + SHAREDPREFERENCES CACHE
  // ============================================================

  Future<Map<String, dynamic>?> _bookData(
    String bookId,
    String language,
  ) async {
    final docId = _docId(bookId, language);

    // Fast path: this session already has the book.
    final memory = _books[docId];
    if (memory != null) return memory;

    // Persistent cache from a previous session.
    final cached = await _readCache(docId);
    if (cached != null) _books[docId] = cached;

    // Firestore (on demand) - admin edits win when online.
    final fresh = await _fetchBook(docId);
    if (fresh != null) {
      _books[docId] = fresh;
      unawaited(_writeCache(docId, fresh));
      _subscribeLive(docId);
      return fresh;
    }

    return cached;
  }

  Future<Map<String, dynamic>?> _fetchBook(String docId) async {
    try {
      final snap = await _firestore
          .collection('bible')
          .doc(docId)
          .get()
          .timeout(_fetchTimeout);

      if (!snap.exists) return null;

      final data = snap.data();
      return data == null ? null : Map<String, dynamic>.from(data);
    } catch (_) {
      // Offline, permission denied, or the request timed out.
      // The callers fall back to the cached/bundled content.
      return null;
    }
  }

  /// Keeps the in-memory + persisted cache of one book fresh while
  /// the app is online, so a chapter opened later (or after a
  /// restart) already shows admin edits.
  void _subscribeLive(String docId) {
    if (_subscribed.contains(docId)) return;
    _subscribed.add(docId);

    _firestore
        .collection('bible')
        .doc(docId)
        .snapshots()
        .listen(
          (snap) {
            if (!snap.exists) return;
            final data = snap.data();
            if (data == null) return;
            final book = Map<String, dynamic>.from(data);
            _books[docId] = book;
            unawaited(_writeCache(docId, book));
          },
          onError: (_) {},
        );
  }
// ============================================================
  // CACHE (SharedPreferences)
  // ============================================================

  Future<Map<String, dynamic>?> _readCache(String docId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(docId));
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String docId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey(docId), jsonEncode(data));
    } catch (_) {
      // Cache is best-effort; the bundled assets still work.
    }
  }

  // ============================================================
  // PARSING
  // ============================================================

  BibleChapter? _parseChapter(
    Map<String, dynamic> data,
    String bookId,
    int chapterNumber,
  ) {
    final chapters = data['chapters'];
    if (chapters is! List) return null;

    for (final item in chapters) {
      if (item is! Map) continue;
      final chapter = Map<String, dynamic>.from(item);

      final num = chapter['chapterNumber'];
      final parsed = num is int
          ? num
          : (num is String ? int.tryParse(num) : null);
      if (parsed != chapterNumber) continue;

      final versesData = chapter['verses'];
      if (versesData is! List) return null;

      final verses = <BibleVerse>[];
      for (final v in versesData) {
        if (v is! Map) continue;
        final bibleVerse = _parseVerse(Map<String, dynamic>.from(v));
        if (bibleVerse != null) verses.add(bibleVerse);
      }

      return BibleChapter(
        bookId: bookId,
        bookName: (data['bookName'] ?? bookId).toString(),
        chapterNumber: chapterNumber,
        verses: verses,
      );
    }

    return null;
  }

  BibleVerse? _parseVerse(Map<String, dynamic> v) {
    final num = v['number'];
    final text = (v['text'] ?? '').toString();
    final number = num is int
        ? num
        : (num is String ? int.tryParse(num) : null);
    return BibleVerse(number: number ?? 0, text: text);
  }

  void dispose() {
    _books.clear();
    _subscribed.clear();
  }
}