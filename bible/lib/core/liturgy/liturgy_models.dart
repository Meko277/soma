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

/// The four visible movements of the Divine Liturgy.
enum LiturgySectionGroup { offering, word, faithful, distribution }

/// Who reads a liturgy section.
enum SectionReader { priest, deacons, people, all }

class LiturgyDocument {
  final String id;

  /// Display name from the JSON (already localized).
  final String name;

  final String englishName;
  final String usedWhen;
  final String introduction;

  /// Optional parallel-language metadata embedded in the
  /// same JSON file (no extra asset paths needed).
  final String nameCo;
  final String usedWhenEn;
  final String introductionEn;
  final String introductionCo;

  final List<LiturgySection> sections;

  const LiturgyDocument({
    required this.id,
    required this.name,
    required this.englishName,
    required this.usedWhen,
    required this.introduction,
    this.nameCo = '',
    this.usedWhenEn = '',
    this.introductionEn = '',
    this.introductionCo = '',
    required this.sections,
  });

  factory LiturgyDocument.fromJson(Map<String, dynamic> json) {
    return LiturgyDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      usedWhen: json['usedWhen']?.toString() ?? '',
      introduction: json['introduction']?.toString() ?? '',
      nameCo: json['nameCo']?.toString() ?? '',
      usedWhenEn: json['usedWhenEn']?.toString() ?? '',
      introductionEn: json['introductionEn']?.toString() ?? '',
      introductionCo: json['introductionCo']?.toString() ?? '',

      sections: (json['sections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LiturgySection.fromJson)
          .toList(),
    );
  }
}

class LiturgySection {
  final String title;

  final LiturgySectionGroup group;

  /// Who reads this section (priest / deacons / people /
  /// all). Defaults to priest when missing.
  final SectionReader reader;

  final List<String> content;

  /// Parallel-language content embedded in the same file.
  /// Falls back to [content] when empty.
  final String titleEn;
  final String titleCo;
  final List<String> contentEn;
  final List<String> contentCo;

  /// Optional reading marker (pauline / catholic / acts /
  /// synaxar / psalm / gospel) used by the admin panel.
  final String readingType;

  const LiturgySection({
    required this.title,
    this.group = LiturgySectionGroup.faithful,
    this.reader = SectionReader.priest,
    this.content = const [],
    this.titleEn = '',
    this.titleCo = '',
    this.contentEn = const [],
    this.contentCo = const [],
    this.readingType = '',
  });

  factory LiturgySection.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? '';
    final titleEn = json['titleEn']?.toString() ?? '';
    return LiturgySection(
      title: title,

      group: _parseGroup(json['group'], title, titleEn),

      reader: _parseReader(json['reader']),

      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),

      titleEn: titleEn,
      titleCo: json['titleCo']?.toString() ?? '',
      contentEn: (json['contentEn'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      contentCo: (json['contentCo'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      readingType: json['readingType']?.toString() ?? '',
    );
  }

  static LiturgySectionGroup _parseGroup(
    dynamic raw,
    String title,
    String titleEn,
  ) {
    switch (raw?.toString()) {
      case 'offering':
        return LiturgySectionGroup.offering;
      case 'word':
        return LiturgySectionGroup.word;
      case 'distribution':
        return LiturgySectionGroup.distribution;
      case 'faithful':
        return LiturgySectionGroup.faithful;
    }

    final value = '$title $titleEn'.toLowerCase();
    if (value.contains('تقديم الحمل') ||
        value.contains('offering of the lamb') ||
        value.contains('offering')) {
      return LiturgySectionGroup.offering;
    }
    if (value.contains('البولس') ||
        value.contains('الكاثوليكون') ||
        value.contains('الإبركسيس') ||
        value.contains('السنكسار') ||
        value.contains('المزمور') ||
        value.contains('الإنجيل') ||
        value.contains('epistle') ||
        value.contains('acts') ||
        value.contains('psalm') ||
        value.contains('gospel') ||
        value.contains('synax')) {
      return LiturgySectionGroup.word;
    }
    if (value.contains('المناولة') ||
        value.contains('communion') ||
        value.contains('distribution')) {
      return LiturgySectionGroup.distribution;
    }
    return LiturgySectionGroup.faithful;
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
