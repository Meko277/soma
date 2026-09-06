import 'dart:convert';

import 'package:flutter/services.dart';

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

    final folder = language == 'ar' ? 'ar' : 'en';

    final path = 'assets/liturgy/$folder/$safeKind.json';

    final jsonString = await rootBundle.loadString(path);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid liturgy JSON format.');
    }

    return LiturgyDocument.fromJson(decoded);
  }
}
