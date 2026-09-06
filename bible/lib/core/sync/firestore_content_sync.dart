// ================================================================
// FIRESTORE CONTENT SYNC
//
// Bridges the admin site (Firestore) with the app so that any
// content the admin edits flows into the app automatically while
// it is online.
//
// Design: OFFLINE-FIRST.
//   * Content loads from bundled assets instantly (works with no
//     internet, just like before).
//   * When online, Firestore updates are merged in and the UI
//     rebuilds to reflect the change.
//   * Fetched Firestore data is also persisted to SharedPreferences
//     so the next launch shows the latest content immediately,
//     before the network round-trip completes.
//
// The admin stores each language as a separate Firestore doc
// (e.g. trisagion_en, trisagion_ar). We group those by their base
// id so both languages of one item are synced together.
// ================================================================

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../agpeya/agpeya_models.dart';
import '../liturgy/liturgy_models.dart';
import '../traneem/traneem_models.dart';

class FirestoreContentSync {
  FirestoreContentSync({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _cacheKeyTraneem = 'sync_cache_traneem';
  static const _cacheKeyDesign = 'sync_cache_design';

  // Parsed content caches: id -> language -> model.
  final Map<String, Map<String, TraneemHymn>> _traneem = {};
  final Map<String, Map<String, AgpeyaHour>> _agpeya = {};
  final Map<String, Map<String, LiturgyDocument>> _liturgy = {};
  Map<String, dynamic>? _design;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  final _traneemCtrl = StreamController<void>.broadcast();
  final _agpeyaCtrl = StreamController<void>.broadcast();
  final _liturgyCtrl = StreamController<void>.broadcast();
  final _designCtrl = StreamController<void>.broadcast();

  Stream<void> get traneemUpdates => _traneemCtrl.stream;
  Stream<void> get agpeyaUpdates => _agpeyaCtrl.stream;
  Stream<void> get liturgyUpdates => _liturgyCtrl.stream;
  Stream<void> get designUpdates => _designCtrl.stream;

  // ============================================================
  // GETTERS
  // ============================================================

  TraneemHymn? traneem(String id, String lang) => _traneem[id]?[lang];
  Map<String, Map<String, TraneemHymn>> get allTraneem =>
      Map.unmodifiable(_traneem);

  AgpeyaHour? agpeya(String id, String lang) => _agpeya[id]?[lang];
  Map<String, Map<String, AgpeyaHour>> get allAgpeya =>
      Map.unmodifiable(_agpeya);

  LiturgyDocument? liturgy(String id, String lang) => _liturgy[id]?[lang];
  Map<String, Map<String, LiturgyDocument>> get allLiturgy =>
      Map.unmodifiable(_liturgy);

  Map<String, dynamic>? get design => _design;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadCached();

    _subscribeTraneem();
    _subscribeAgpeya();
    _subscribeLiturgy();
    _subscribeDesign();
  }

  void dispose() {
    _traneemCtrl.close();
    _agpeyaCtrl.close();
    _liturgyCtrl.close();
    _designCtrl.close();
  }

  // ============================================================
  // CACHE (SharedPreferences)
  // ============================================================

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();

    final traneemRaw = prefs.getString(_cacheKeyTraneem);
    if (traneemRaw != null) {
      try {
        _traneem.addAll(_parseTraneemCache(jsonDecode(traneemRaw)));
      } catch (_) {}
    }

    final designRaw = prefs.getString(_cacheKeyDesign);
    if (designRaw != null) {
      try {
        _design = (jsonDecode(designRaw) as Map).cast<String, dynamic>();
      } catch (_) {}
    }
  }

  Future<void> _persistTraneem() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = <String, Map<String, dynamic>>{};
    for (final entry in _traneem.entries) {
      raw[entry.key] = {
        for (final lang in entry.value.entries)
          lang.key: _hymnToCache(lang.value),
      };
    }
    await prefs.setString(_cacheKeyTraneem, jsonEncode(raw));
  }

  Future<void> _persistAgpeya() async {
    // AgpeyaHour has no toJson — persisting a partial stub would
    // shadow the full bundled asset on the next launch. The live
    // Firestore subscription + asset fallback are the source of
    // truth, so we intentionally do NOT cache agpeya content.
  }

  Future<void> _persistLiturgy() async {
    // Intentionally not persisted (same reason as agpeya): a partial
    // stub would replace the bundled liturgy asset offline.
  }

  Future<void> _persistDesign() async {
    if (_design == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyDesign, jsonEncode(_design));
  }

  // ============================================================
  // FIRESTORE SUBSCRIPTIONS
  // ============================================================

  void _subscribeTraneem() {
    _firestore.collection('traneem').snapshots().listen(
      (snap) {
        final parsed = <String, Map<String, TraneemHymn>>{};
        for (final doc in snap.docs) {
          final data = doc.data();
          final lang = (data['lang'] ?? _langFromDocId(doc.id)).toString();
          final id = _stripLangSuffix(doc.id, lang);
          final hymn = _parseTraneemDoc(data, lang);
          if (hymn == null) continue;
          parsed.putIfAbsent(id, () => {})[lang] = hymn;
        }
        _traneem
          ..clear()
          ..addAll(parsed);
        _persistTraneem();
        _traneemCtrl.add(null);
      },
      onError: (_) {},
    );
  }

  void _subscribeAgpeya() {
    _firestore.collection('agpeya').snapshots().listen(
      (snap) {
        final parsed = <String, Map<String, AgpeyaHour>>{};
        for (final doc in snap.docs) {
          final data = doc.data();
          final lang = (data['lang'] ?? _langFromDocId(doc.id)).toString();
          final id = _stripLangSuffix(doc.id, lang);
          AgpeyaHour? hour;
          try {
            hour = AgpeyaHour.fromJson(data);
          } catch (_) {
            continue;
          }
          parsed.putIfAbsent(id, () => {})[lang] = hour;
        }
        _agpeya
          ..clear()
          ..addAll(parsed);
        _persistAgpeya();
        _agpeyaCtrl.add(null);
      },
      onError: (_) {},
    );
  }

  void _subscribeLiturgy() {
    _firestore.collection('liturgy').snapshots().listen(
      (snap) {
        final parsed = <String, Map<String, LiturgyDocument>>{};
        for (final doc in snap.docs) {
          final data = doc.data();
          final lang = (data['lang'] ?? _langFromDocId(doc.id)).toString();
          final id = _stripLangSuffix(doc.id, lang);
          LiturgyDocument? document;
          try {
            document = LiturgyDocument.fromJson(data);
          } catch (_) {
            continue;
          }
          parsed.putIfAbsent(id, () => {})[lang] = document;
        }
        _liturgy
          ..clear()
          ..addAll(parsed);
        _persistLiturgy();
        _liturgyCtrl.add(null);
      },
      onError: (_) {},
    );
  }

  void _subscribeDesign() {
    _firestore.collection('settings').doc('design').snapshots().listen(
      (snap) {
        if (!snap.exists) return;
        final data = snap.data();
        if (data == null) return;
        _design = data;
        _persistDesign();
        _designCtrl.add(null);
      },
      onError: (_) {},
    );
  }

  // ============================================================
  // PARSING HELPERS
  // ============================================================

  /// Admin doc id is `<id>_<lang>` (e.g. trisagion_en). Fall back to
  /// this when the doc has no `lang` field.
  String _langFromDocId(String docId) {
    if (docId.endsWith('_ar') || docId.endsWith('_arabic')) return 'ar';
    return 'en';
  }

  String _stripLangSuffix(String docId, String lang) {
    final suffix = lang == 'ar' ? '_ar' : '_en';
    if (docId.endsWith(suffix)) {
      return docId.substring(0, docId.length - suffix.length);
    }
    return docId;
  }

  TraneemHymn? _parseTraneemDoc(Map<String, dynamic> data, String lang) {
    try {
      final meta = TraneemHymnMeta(
        id: (data['id'] ?? '').toString(),
        title: (data['title'] ?? '').toString(),
        arabicTitle: (data['arabicTitle'] ?? data['title'] ?? '').toString(),
        category: data['category']?.toString(),
        categoryAr: data['categoryAr']?.toString(),
      );
      return TraneemHymn.fromJson(data, meta: meta, language: lang);
    } catch (_) {
      return null;
    }
  }

  Map<String, Map<String, TraneemHymn>> _parseTraneemCache(dynamic raw) {
    final result = <String, Map<String, TraneemHymn>>{};
    if (raw is! Map) return result;
    for (final idEntry in raw.entries) {
      final langs = idEntry.value;
      if (langs is! Map) continue;
      for (final langEntry in langs.entries) {
        if (langEntry.value is! Map) continue;
        final hymn = _hymnFromCache(
          Map<String, dynamic>.from(langEntry.value as Map),
          langEntry.key.toString(),
        );
        if (hymn == null) continue;
        result.putIfAbsent(idEntry.key.toString(), () => {})[
            langEntry.key.toString()] = hymn;
      }
    }
    return result;
  }

  TraneemHymn? _hymnFromCache(Map<String, dynamic> data, String lang) {
    try {
      return TraneemHymn(
        id: (data['id'] ?? '').toString(),
        title: (data['title'] ?? '').toString(),
        arabicTitle: (data['arabicTitle'] ?? '').toString(),
        category: data['category']?.toString(),
        categoryAr: data['categoryAr']?.toString(),
        language: lang,
        stanzas: (data['stanzas'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(TraneemStanza.fromJson)
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _hymnToCache(TraneemHymn hymn) {
    return {
      'id': hymn.id,
      'title': hymn.title,
      'arabicTitle': hymn.arabicTitle,
      'category': hymn.category,
      'categoryAr': hymn.categoryAr,
      'stanzas': hymn.stanzas
          .map((s) => {
                'title': s.title,
                'lines': s.lines,
              })
          .toList(),
    };
  }
}
