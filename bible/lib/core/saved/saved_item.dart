import 'package:flutter/material.dart';

// ================================================================
// SAVED ITEM (المحفوظات / العلامات المرجعية)
//
// A minimal, URL-able description of one saved page. We store
// enough to REOPEN the original content (a stable id + the
// go_router path) but never the full content itself — the
// content stays in the existing offline asset repositories.
// ================================================================

/// The kind of content a saved item points at.
enum SavedContentKind {
  bibleChapter,
  agpeya,
  traneem,
  liturgy,
  document,

  /// A daily reading reference (e.g. a psalm from today's plan).
  reading,
}

extension SavedContentKindX on SavedContentKind {
  /// Stable serialized name.
  String get storageName => name;

  static SavedContentKind fromStorage(String? value) {
    return SavedContentKind.values.firstWhere(
      (k) => k.name == value,
      orElse: () => SavedContentKind.document,
    );
  }

  /// Icon for list tiles.
  IconData get icon => switch (this) {
        SavedContentKind.bibleChapter => Icons.menu_book_outlined,
        SavedContentKind.agpeya => Icons.auto_stories_outlined,
        SavedContentKind.traneem => Icons.music_note_outlined,
        SavedContentKind.liturgy => Icons.church_outlined,
        SavedContentKind.document => Icons.description_outlined,
        SavedContentKind.reading => Icons.bookmark_outline,
      };
}

class SavedItem {
  SavedItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.routePath,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();

  /// Stable unique id (e.g. 'bible:genesis-1', 'traneem:trisagion').
  final String id;

  final SavedContentKind kind;

  /// Primary display title.
  final String title;

  /// Secondary display line (reference / chapter / hour).
  final String subtitle;

  /// go_router path used to reopen the content.
  final String routePath;

  /// When the item was saved (for ordering).
  final DateTime savedAt;

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id']?.toString() ?? '',
      kind: SavedContentKindX.fromStorage(json['kind']?.toString()),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      routePath: json['route']?.toString() ?? '',
      savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.storageName,
        'title': title,
        'subtitle': subtitle,
        'route': routePath,
        'savedAt': savedAt.toIso8601String(),
      };

  @override
  String toString() => 'SavedItem($id, ${kind.name})';
}