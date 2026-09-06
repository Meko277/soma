import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  arabic,
}

/// Which language version(s) of a Bible chapter to
/// display, and in what order.
enum BibleDisplayMode {
  /// Only the chosen CONTENT language (previous behavior).
  single,

  /// English block first, then Arabic.
  englishArabic,

  /// Arabic block first, then English.
  arabicEnglish,

  /// Coptic block first, then Arabic.
  copticArabic,

  /// Coptic block first, then English.
  copticEnglish,

  /// English, Arabic and Coptic stacked.
  all,
}

extension BibleDisplayModeX on BibleDisplayMode {
  String get storageName {
    switch (this) {
      case BibleDisplayMode.single:
        return 'single';

      case BibleDisplayMode.englishArabic:
        return 'english_arabic';

      case BibleDisplayMode.arabicEnglish:
        return 'arabic_english';

      case BibleDisplayMode.copticArabic:
        return 'coptic_arabic';

      case BibleDisplayMode.copticEnglish:
        return 'coptic_english';

      case BibleDisplayMode.all:
        return 'all';
    }
  }

  static BibleDisplayMode fromStorage(String? value) {
    switch (value) {
      case 'english_arabic':
        return BibleDisplayMode.englishArabic;

      case 'arabic_english':
        return BibleDisplayMode.arabicEnglish;

      case 'coptic_arabic':
        return BibleDisplayMode.copticArabic;

      case 'coptic_english':
        return BibleDisplayMode.copticEnglish;

      case 'all':
        return BibleDisplayMode.all;

      case 'single':
      default:
        return BibleDisplayMode.single;
    }
  }

  /// Ordered language codes to load/display.
  List<String> codes(String contentLanguage) {
    switch (this) {
      case BibleDisplayMode.single:
        return [contentLanguage];

      case BibleDisplayMode.englishArabic:
        return const ['en', 'ar'];

      case BibleDisplayMode.arabicEnglish:
        return const ['ar', 'en'];

      case BibleDisplayMode.copticArabic:
        return const ['copt', 'ar'];

      case BibleDisplayMode.copticEnglish:
        return const ['copt', 'en'];

      case BibleDisplayMode.all:
        return const ['en', 'ar', 'copt'];
    }
  }
}

extension AppLanguageX on AppLanguage {
  bool get isRtl => this == AppLanguage.arabic;

  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.arabic => 'العربية',
      };
}

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.light,
    this.interfaceLanguage = AppLanguage.english,
    this.contentLanguage = AppLanguage.english,
    this.fontScale = 1,
    this.lastReadingChapterId,
    this.readingHistory = const [],
    this.notificationHour = 11,
    this.notificationMinute = 0,
    this.bibleDisplayMode = BibleDisplayMode.single,
    this.presentationModeEnabled = true,
  });

  final ThemeMode themeMode;

  final AppLanguage interfaceLanguage;

  final AppLanguage contentLanguage;

  final double fontScale;

  /// Chapter id of the last Bible chapter the user
  /// opened (e.g. 'genesis-1').
  ///
  /// Null until the user opens their first chapter.
  final String? lastReadingChapterId;

  /// Recently read chapter ids, most recent FIRST
  /// (no duplicates). Powers the "Last reading"
  /// button beside the drawer button in the reader.
  final List<String> readingHistory;

  /// Preferred daily notification time.
  /// Defaults to 11:00 AM.
  final int notificationHour;

  final int notificationMinute;

  /// Which language version(s) of a chapter to display
  /// (single / EN+AR / AR+EN / Coptic combos / all).
  final BibleDisplayMode bibleDisplayMode;

  /// When the phone is in LANDSCAPE and a reading is
  /// open, show one verse per screen (presentation).
  /// Defaults to true — can be turned off in settings.
  final bool presentationModeEnabled;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    AppLanguage? interfaceLanguage,
    AppLanguage? contentLanguage,
    double? fontScale,
    String? lastReadingChapterId,
    List<String>? readingHistory,
    int? notificationHour,
    int? notificationMinute,
    BibleDisplayMode? bibleDisplayMode,
    bool? presentationModeEnabled,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      interfaceLanguage:
          interfaceLanguage ?? this.interfaceLanguage,
      contentLanguage:
          contentLanguage ?? this.contentLanguage,
      fontScale: fontScale ?? this.fontScale,
      lastReadingChapterId:
          lastReadingChapterId ??
              this.lastReadingChapterId,
      readingHistory:
          readingHistory ?? this.readingHistory,
      notificationHour:
          notificationHour ?? this.notificationHour,
      notificationMinute:
          notificationMinute ?? this.notificationMinute,
      bibleDisplayMode:
          bibleDisplayMode ?? this.bibleDisplayMode,
      presentationModeEnabled: presentationModeEnabled ??
          this.presentationModeEnabled,
    );
  }
}