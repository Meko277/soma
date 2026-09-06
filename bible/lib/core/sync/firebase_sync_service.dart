// Firebase Sync Service for Coptic Companion
// Real-time data sync with offline caching via SharedPreferences.
//
// Firestore collections (traneem, bible, agpeya, liturgy, readings,
// settings/design) are mirrored into SharedPreferences for instant offline
// rendering, while online listeners update in real time.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result wrapper so callers never handle raw Firestore errors.
class SyncResult {
  final bool ok;
  final String? error;
  final Map<String, dynamic>? data;
  const SyncResult._({required this.ok, this.error, this.data});

  factory SyncResult.ok([Map<String, dynamic>? data]) =>
      SyncResult._(ok: true, data: data);

  factory SyncResult.fail(String error) =>
      SyncResult._(ok: false, error: error);
}

/// Handles real-time sync between Firebase Firestore and local cache.
class FirebaseSyncService {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  /// Shared singleton accessor.
  static FirebaseSyncService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;
  bool _isOnline = true;

  // Cache keys (SharedPreferences)
  static const String cacheTraneem = 'cache_traneem';
  static const String cacheBible = 'cache_bible';
  static const String cacheAgpeya = 'cache_agpeya';
  static const String cacheLiturgy = 'cache_liturgy';
  static const String cacheReadings = 'cache_readings';
  static const String cacheDesign = 'cache_design';
  static const String cacheLastSync = 'cache_last_sync';

  // Broadcast controllers for real-time UI updates.
  final _traneem = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _bible = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _agpeya = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _liturgy = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _readings = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _design = StreamController<Map<String, dynamic>>.broadcast();
  final _conn = StreamController<bool>.broadcast();

  Stream<List<Map<String, dynamic>>> get traneemStream => _traneem.stream;
  Stream<List<Map<String, dynamic>>> get bibleStream => _bible.stream;
  Stream<List<Map<String, dynamic>>> get agpeyaStream => _agpeya.stream;
  Stream<List<Map<String, dynamic>>> get liturgyStream => _liturgy.stream;
  Stream<List<Map<String, dynamic>>> get readingsStream => _readings.stream;
  Stream<Map<String, dynamic>> get designStream => _design.stream;
  Stream<bool> get connectionStream => _conn.stream;

  bool get isOnline => _isOnline;
  bool get isInitialized => _initialized;

  /// Initialize: load cache immediately, then start Firestore listeners.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Enable Firestore offline persistence (non-web).
    try {
      _firestore.settings = const Settings(persistenceEnabled: true);
    } catch (_) {
      // Already set or unsupported on this platform.
    }

    // Load the cache in the background — never block the caller
    // (live listeners push fresh data as soon as it arrives anyway).
    unawaited(_loadCachedData());

    // Start real-time listeners. Firestore SDK auto-reconnects when offline.
    _setupListeners();

    _isOnline = await _checkConnectivity();
    _conn.add(_isOnline);
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'firestore.googleapis.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  void _setupListeners() {
    // NOTE: the 'bible' collection is intentionally NOT synced.
    // It holds all 66 books x 2 languages with every chapter
    // (tens of MB in Firestore). The app reads the Bible from the
    // bundled assets (assets/bible/...), so listening to this
    // collection on every startup only burned data, memory and
    // battery (painfully slow on old devices) while nothing in
    // the app consumes the stream.
    _listen(_firestore.collection('traneem'), _traneem, cacheTraneem);
    _listen(_firestore.collection('agpeya'), _agpeya, cacheAgpeya);
    _listen(_firestore.collection('liturgy'), _liturgy, cacheLiturgy);
    _listen(_firestore.collection('readings'), _readings, cacheReadings);

    _firestore.collection('settings').doc('design').snapshots().listen(
      (snap) {
        if (!snap.exists) return;
        final data = snap.data()!;
        _design.add(data);
        _cacheJson(cacheDesign, [data]);
      },
      onError: (Object e) => _conn.add(false),
    );
  }

  void _listen(
    CollectionReference<Map<String, dynamic>> ref,
    StreamController<List<Map<String, dynamic>>> controller,
    String cacheKey,
  ) {
    ref.snapshots().listen(
      (snap) {
        final data = snap.docs.map((d) => d.data()).toList();
        controller.add(data);
        _cacheJson(cacheKey, data);
        _conn.add(true);
      },
      onError: (Object e) {
        _conn.add(false);
      },
    );
  }

  // ================================================================
  // CACHE (SharedPreferences)
  // ================================================================

  Future<void> _cacheJson(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();

    final pairs = <(String, StreamController)>[
      (cacheTraneem, _traneem),
      // cacheBible intentionally NOT pre-loaded: decoding tens of
      // MB of JSON here janked old devices for seconds. The Bible
      // is served from bundled assets instead (see _setupListeners).
      (cacheAgpeya, _agpeya),
      (cacheLiturgy, _liturgy),
      (cacheReadings, _readings),
    ];

    for (final (key, controller) in pairs) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        (controller as StreamController<List<Map<String, dynamic>>>).add(list);
      } catch (_) {}
    }

    final designRaw = prefs.getString(cacheDesign);
    if (designRaw != null) {
      try {
        final list = (jsonDecode(designRaw) as List).cast<Map<String, dynamic>>();
        if (list.isNotEmpty) _design.add(list.first);
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> getCached(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCachedDesign() async {
    final list = await getCached(cacheDesign);
    return list.isNotEmpty ? list.first : null;
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cacheLastSync);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<SyncResult> saveDoc(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheLastSync, DateTime.now().toIso8601String());
      return SyncResult.ok();
    } catch (e) {
      return SyncResult.fail(e.toString());
    }
  }

  Future<SyncResult> deleteDoc(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return SyncResult.ok();
    } catch (e) {
      return SyncResult.fail(e.toString());
    }
  }

  Future<SyncResult> syncAll() async {
    try {
      final snap = await _firestore.collection('traneem').get();
      final data = snap.docs.map((d) => d.data()).toList();
      _traneem.add(data);
      await _cacheJson(cacheTraneem, data);
      return SyncResult.ok();
    } catch (e) {
      return SyncResult.fail(e.toString());
    }
  }

  void dispose() {
    _traneem.close();
    _bible.close();
    _agpeya.close();
    _liturgy.close();
    _readings.close();
    _design.close();
    _conn.close();
  }
}
