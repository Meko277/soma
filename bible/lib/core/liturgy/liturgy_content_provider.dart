import 'dart:convert';

import 'package:flutter/services.dart';

import '../sync/sync_holder.dart';
import 'liturgy_models.dart';

// ============================================================
// LITURGY CONTENT PROVIDER
//
// Loads one of the three anaphoras from
// assets/liturgy/{ar|en}/{basil|gregory|cyril}.json
// ============================================================

class LiturgyContentProvider {
  const LiturgyContentProvider();

  Future<LiturgyDocument> loadDocument(
    String kindId, {
    String language = 'en',
  }) async {
    // Guard against unknown kinds coming from routes.
    final safeKind = switch (kindId) {
      'gregory' => 'gregory',
      'cyril' => 'cyril',
      _ => 'basil',
    };

    // The AR file is the canonical trilingual file: it embeds
    // content/contentEn/contentCo side by side, so 'ar', 'en'
    // and 'co' all load from ONE file (no pubspec changes).
    // We therefore ALWAYS load the AR file - the requested
    // language only sets the INITIAL display language in the
    // reader page, not which asset file is read.
    final folder = 'ar';

    final path = 'assets/liturgy/$folder/$safeKind.json';

    final jsonString = await rootBundle.loadString(path);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid liturgy JSON format.');
    }

    final bundled = LiturgyDocument.fromJson(decoded);

    // OFFLINE-FIRST: prefer Firestore-synced content when present,
    // but NEVER let a shorter synced doc shadow the bundled asset.
    // This keeps the FULL anaphora visible even if an old partial
    // copy (e.g. a 4-section basil) still exists in Firestore.
    final synced = await liturgySyncedDoc(kindId, language);
    if (synced != null &&
        synced.sections.length >= bundled.sections.length) {
      return synced;
    }

    return bundled;
  }

  /// Returns the Firestore-synced liturgy if present, else null.
  Future<LiturgyDocument?> liturgySyncedDoc(
      String kindId, String language) async {
    try {
      final sync = SyncHolder.instance;
      if (sync == null) return null;
      return sync.liturgy(kindId, language);
    } catch (_) {
      return null;
    }
  }
}
