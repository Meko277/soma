import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AppPreferences>(
  (ref) => PreferencesNotifier(),
);

class PreferencesNotifier
    extends StateNotifier<AppPreferences> {
  PreferencesNotifier()
      : super(const AppPreferences()) {
    _restore();
  }

  /// Public so other services (e.g. notifications)
  /// can read the stored interface language directly.
  static const String interfaceLanguageStorageKey =
      'interface_language';

  /// Public so the notification service can read the
  /// user's preferred delivery time directly.
  static const String notificationHourStorageKey =
      'notification_hour';

  static const String notificationMinuteStorageKey =
      'notification_minute';

  static const String _themeKey = 'theme_mode';
  static const String _interfaceLanguageKey =
      interfaceLanguageStorageKey;
  static const String _contentLanguageKey =
      'content_language';
  static const String _fontScaleKey =
      'font_scale';
  static const String _lastReadingKey =
      'last_reading_chapter_id';
  static const String _readingHistoryKey =
      'reading_history';
  static const String _notificationHourKey =
      notificationHourStorageKey;
  static const String _notificationMinuteKey =
      notificationMinuteStorageKey;
  static const String _bibleDisplayModeKey =
      'bible_display_mode';
  static const String _presentationModeKey =
      'presentation_mode_enabled';

  // ============================================================
  // RESTORE SAVED PREFERENCES
  // ============================================================

  Future<void> _restore() async {
    final storage =
        await SharedPreferences.getInstance();

    final savedTheme =
        storage.getString(_themeKey);

    final savedInterfaceLanguage =
        storage.getString(_interfaceLanguageKey);

    final savedContentLanguage =
        storage.getString(_contentLanguageKey);

    final savedFontScale =
        storage.getDouble(_fontScaleKey);

    final savedLastReading =
        storage.getString(_lastReadingKey);

    final savedReadingHistory =
        storage.getStringList(_readingHistoryKey);

    final savedNotificationHour =
        storage.getInt(_notificationHourKey);

    final savedNotificationMinute =
        storage.getInt(_notificationMinuteKey);

    final savedDisplayMode =
        storage.getString(_bibleDisplayModeKey);

    final savedPresentation =
        storage.getBool(_presentationModeKey);

    ThemeMode themeMode = ThemeMode.light;

    if (savedTheme != null) {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.light,
      );
    }

    state = state.copyWith(
      themeMode: themeMode,
      interfaceLanguage:
          _languageFromStorage(
        savedInterfaceLanguage,
      ),
      contentLanguage:
          _languageFromStorage(
        savedContentLanguage,
      ),
      fontScale: savedFontScale ?? state.fontScale,
      lastReadingChapterId: savedLastReading,
      readingHistory:
          savedReadingHistory ?? state.readingHistory,
      // Defaults to 11:00 AM when nothing is stored.
      notificationHour:
          savedNotificationHour ?? state.notificationHour,
      notificationMinute:
          savedNotificationMinute ??
              state.notificationMinute,
      bibleDisplayMode: BibleDisplayModeX.fromStorage(
        savedDisplayMode,
      ),
      presentationModeEnabled:
          savedPresentation ??
              state.presentationModeEnabled,
    );
  }

  // ============================================================
  // THEME
  // ============================================================

  Future<void> setTheme(
    ThemeMode mode,
  ) async {
    state = state.copyWith(
      themeMode: mode,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setString(
      _themeKey,
      mode.name,
    );
  }

  // ============================================================
  // INTERFACE LANGUAGE
  // ============================================================

  Future<void> setInterfaceLanguage(
    AppLanguage language,
  ) async {
    state = state.copyWith(
      interfaceLanguage: language,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setString(
      _interfaceLanguageKey,
      language.name,
    );
  }

  // ============================================================
  // CONTENT LANGUAGE
  // ============================================================

  Future<void> setContentLanguage(
    AppLanguage language,
  ) async {
    state = state.copyWith(
      contentLanguage: language,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setString(
      _contentLanguageKey,
      language.name,
    );
  }

  // ============================================================
  // FONT SCALE (TEXT SIZE)
  // ============================================================

  Future<void> setFontScale(
    double scale,
  ) async {
    state = state.copyWith(
      fontScale: scale,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setDouble(
      _fontScaleKey,
      scale,
    );
  }

  // ============================================================
  // BIBLE READING HISTORY
  //
  // Remembers the chapters the user opened (most recent
  // first) so that:
  //
  //   - the Home page can offer a "Continue reading"
  //     shortcut (most recent entry), and
  //   - the reader AppBar can show a "Last reading"
  //     button beside the drawer button that jumps back
  //     to the previously read chapter.
  // ============================================================

  Future<void> recordReading(
    String chapterId,
  ) async {
    // Already recorded as the most recent reading?
    if (state.readingHistory.isNotEmpty &&
        state.readingHistory.first == chapterId &&
        state.lastReadingChapterId == chapterId) {
      return;
    }

    final history = <String>[
      chapterId,
      ...state.readingHistory.where(
        (id) => id != chapterId,
      ),
    ];

    // Keep the history small.
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    state = state.copyWith(
      lastReadingChapterId: chapterId,
      readingHistory: history,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setString(
      _lastReadingKey,
      chapterId,
    );

    await storage.setStringList(
      _readingHistoryKey,
      history,
    );
  }

  // ============================================================
  // NOTIFICATION TIME
  //
  // Preferred daily notification delivery time.
  // Default: 11:00 AM.
  // ============================================================

  Future<void> setNotificationTime(
    int hour,
    int minute,
  ) async {
    state = state.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );

    final storage =
        await SharedPreferences.getInstance();

    await storage.setInt(
      _notificationHourKey,
      hour,
    );

    await storage.setInt(
      _notificationMinuteKey,
      minute,
    );
  }

  // ============================================================
  // BIBLE DISPLAY MODE & PRESENTATION MODE
  // ============================================================

  Future<void> setBibleDisplayMode(
    BibleDisplayMode mode,
  ) async {
    state = state.copyWith(bibleDisplayMode: mode);

    final storage =
        await SharedPreferences.getInstance();

    await storage.setString(
      _bibleDisplayModeKey,
      mode.storageName,
    );
  }

  Future<void> setPresentationModeEnabled(
    bool enabled,
  ) async {
    state = state.copyWith(presentationModeEnabled: enabled);

    final storage =
        await SharedPreferences.getInstance();

    await storage.setBool(
      _presentationModeKey,
      enabled,
    );
  }

  // ============================================================
  // LANGUAGE FROM STORAGE
  // ============================================================

  AppLanguage _languageFromStorage(
    String? value,
  ) {
    switch (value) {
      case 'arabic':
        return AppLanguage.arabic;

      case 'english':
      default:
        return AppLanguage.english;
    }
  }
}