import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../sync/sync_holder.dart';
import 'agpeya_models.dart';

class AgpeyaContentProvider {
  const AgpeyaContentProvider();

  // ============================================================
  // Load a single Agpeya hour
  // ============================================================

  Future<AgpeyaHour> loadHour(
    String hourId, {
    String language = 'en',
  }) async {
    // OFFLINE-FIRST: prefer Firestore-synced content when present.
    final synced = await agpeyaSyncedHour(hourId, language);
    if (synced != null) return synced;

    final fileName = _fileNameForHour(hourId);

    final folder = _folderForLanguage(language);

    final path = 'assets/agpeya/$folder/$fileName.json';

    debugPrint('Loading Agpeya hour: $hourId ($language) -> $path');

    final jsonString = await rootBundle.loadString(path);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid Agpeya JSON format.',
      );
    }

    final hour = AgpeyaHour.fromJson(decoded);

    return hour;
  }

  /// Returns the Firestore-synced hour if present, else null.
  Future<AgpeyaHour?> agpeyaSyncedHour(String hourId, String language) async {
    try {
      final sync = SyncHolder.instance;
      if (sync == null) return null;
      return sync.agpeya(hourId, language);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // Map language code → asset folder
  //
  // The Arabic JSON files live under "arabic" while the
  // rest of the app uses the "ar" language code.
  // ============================================================

  String _folderForLanguage(String language) {
    switch (language) {
      case 'ar':
      case 'arabic':
        return 'arabic';

      case 'en':
      case 'english':
      default:
        return 'en';
    }
  }

  // ============================================================
  // Map route ID → JSON file
  // ============================================================

  String _fileNameForHour(String hourId) {
    switch (hourId) {
      case 'morning':
        return 'morning';

      case 'third':
        return 'third';

      case 'sixth':
        return 'sixth';

      case 'ninth':
        return 'ninth';

      case 'vespers':
        return 'vespers';

      case 'compline':
        return 'compline';

      case 'midnight':
        return 'midnight';

      default:
        throw ArgumentError(
          'Unknown Agpeya hour: $hourId',
        );
    }
  }
}