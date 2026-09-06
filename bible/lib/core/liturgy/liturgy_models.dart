import 'package:flutter/foundation.dart';

// ============================================================
// LITURGY (القداس) MODELS
//
// The Coptic Church uses three main anaphoras:
//   basil   -> most days of the year
//   gregory -> feasts of our Lord
//   cyril   -> Great Lent / Nineveh fast (the original
//              Markan liturgy of the Church of Alexandria)
//
// Every section is TYPED with who reads it, following the
// Coptic rite: the priest, the deacons, the congregation,
// or everyone together.
// ============================================================

enum LiturgyKind { basil, gregory, cyril }

/// Who reads a liturgy section.
enum SectionReader { priest, deacons, people, all }

class LiturgyDocument {
  final String id;

  /// Display name from the JSON (already localized).
  final String name;

  final String englishName;
  final String usedWhen;
  final String introduction;
  final List<LiturgySection> sections;

  const LiturgyDocument({
    required this.id,
    required this.name,
    required this.englishName,
    required this.usedWhen,
    required this.introduction,
    required this.sections,
  });

  factory LiturgyDocument.fromJson(Map<String, dynamic> json) {
    return LiturgyDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      usedWhen: json['usedWhen']?.toString() ?? '',
      introduction: json['introduction']?.toString() ?? '',

      sections: (json['sections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LiturgySection.fromJson)
          .toList(),
    );
  }
}

class LiturgySection {
  final String title;

  /// Who reads this section (priest / deacons / people /
  /// all). Defaults to priest when missing.
  final SectionReader reader;

  final List<String> content;

  const LiturgySection({
    required this.title,
    this.reader = SectionReader.priest,
    this.content = const [],
  });

  factory LiturgySection.fromJson(Map<String, dynamic> json) {
    return LiturgySection(
      title: json['title']?.toString() ?? '',

      reader: _parseReader(json['reader']),

      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  static SectionReader _parseReader(dynamic raw) {
    switch (raw?.toString()) {
      case 'deacons':
        return SectionReader.deacons;
      case 'people':
        return SectionReader.people;
      case 'all':
        return SectionReader.all;
      case 'priest':
      default:
        if (kDebugMode && raw == null) {
          debugPrint('LiturgySection: no reader set, using priest');
        }
        return SectionReader.priest;
    }
  }
}
