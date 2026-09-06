import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/preferences/app_preferences.dart';
import '../core/preferences/preferences_provider.dart';

// ================================================================
// FLOATING TEXT ZOOM (تكبير النص)
//
// A small, unobtrusive floating pill that lets the reader
// quickly increase / decrease the reading text size without
// opening the settings drawer.
//
//   - Collapsed: a tiny "A+" floating button.
//   - Expanded:   A- | 100% | A+  (with a collapse handle).
//
// It reuses the app's existing, already-persisted text-size
// system (preferences.fontScale + MediaQuery textScaler) instead
// of introducing a second font-size system, so the value kept in
// sync everywhere (Home, Bible reader, Agpeya, Traneem, ...).
//
// Place one inside a Stack in any reading screen:
//
//   Stack(children: [
//     ...reader body...,
//     const Positioned(
//       right: 16,
//       bottom: 24,
//       child: FloatingTextZoom(),
//     ),
//   ])
//
// In presentation (landscape slide) mode simply omit it by not
// building the Stack — Screen readers shouldn't float opaque
// chrome over the black slide screens.
// ================================================================

/// Minimum / maximum font scale — must match the reading settings
/// drawer slider.
const double kTextZoomMin = 0.8;
const double kTextZoomMax = 1.6;

/// Step used by the + / - buttons (one step of the slider).
const double kTextZoomStep = 0.1;

class FloatingTextZoom extends ConsumerStatefulWidget {
  const FloatingTextZoom({super.key});

  @override
  ConsumerState<FloatingTextZoom> createState() => _FloatingTextZoomState();
}

class _FloatingTextZoomState extends ConsumerState<FloatingTextZoom> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // Scoped watch: ONLY this widget rebuilds when the font scale
    // changes (the readers below receive the new MediaQuery scale
    // but their own build logic is untouched).
    final fontScale = ref.watch(
      preferencesProvider.select((p) => p.fontScale),
    );

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    // ------------------------------------------------------------
    // COLLAPSED: a single floating "A+" button.
    // ------------------------------------------------------------

    if (!_expanded) {
      return FloatingActionButton.small(
        heroTag: 'text_zoom',
        tooltip: 'تغيير حجم الخط' /* covered by Directionality
            below; Arabic tooltip is used regardless of language
            for consistency with the readers' bilingual chrome. */,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        onPressed: () => setState(() => _expanded = true),
        child: const Icon(Icons.text_increase),
      );
    }

    // ------------------------------------------------------------
    // EXPANDED: A- | % | A+ pill.
    // ------------------------------------------------------------

    final isArabic = _isInterfaceArabic;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      color: colorScheme.primaryContainer,
      child: Directionality(
        textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isArabic ? 'تصغير' : 'Decrease text size',
                icon: const Icon(Icons.text_decrease),
                color: colorScheme.onPrimaryContainer,
                onPressed: fontScale > kTextZoomMin
                    ? () => _changeScale(-kTextZoomStep)
                    : null,
              ),
              Text(
                '${(fontScale * 100).round()}%',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              IconButton(
                tooltip: isArabic ? 'تكبير' : 'Increase text size',
                icon: const Icon(Icons.text_increase),
                color: colorScheme.onPrimaryContainer,
                onPressed: fontScale < kTextZoomMax
                    ? () => _changeScale(kTextZoomStep)
                    : null,
              ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: isArabic ? 'إغلاق' : 'Close',
                icon: const Icon(Icons.close),
                color: colorScheme.onPrimaryContainer,
                onPressed: () => setState(() => _expanded = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isInterfaceArabic =>
      ref.read(preferencesProvider).interfaceLanguage.isRtl;

  Future<void> _changeScale(double delta) async {
    final controller = ref.read(preferencesProvider.notifier);

    final current = ref.read(preferencesProvider).fontScale;

    final next = (current + delta).clamp(kTextZoomMin, kTextZoomMax);

    // Persisted via the existing preferences system.
    await controller.setFontScale(next);
  }
}