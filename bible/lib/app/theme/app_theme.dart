import 'package:flutter/material.dart';

class AppTheme {
  static const _beigePrimary = Color(0xff5b2c22);
  static const _bluePrimary = Color(0xffd4af37);

  static ThemeData get beige => _build(
        brightness: Brightness.light,
        primary: _beigePrimary,
        surface: const Color(0xfffff9ef),
        surfaceContainer: const Color(0xfff6f1e7),
        onSurface: const Color(0xff1e1e1e),
      );

  static ThemeData get blue => _build(
        brightness: Brightness.dark,
        primary: _bluePrimary,
        surface: const Color(0xff071b3b),
        surfaceContainer: const Color(0xff0c2b58),
        onSurface: const Color(0xfff7ead4),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color surfaceContainer,
    required Color onSurface,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      surface: surface,
      onSurface: onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainer,
        indicatorColor: scheme.primary.withValues(alpha: .16),
      ),
      appBarTheme: AppBarTheme(backgroundColor: surface, surfaceTintColor: surface),
    );
  }
}
