import 'package:flutter/material.dart';

// ================================================================
// BILINGUAL TEXT
//
// Shows a title in the CHOSEN interface language with the
// OTHER language right underneath (slightly smaller):
//
//   English mode:   Old Testament     <- primary
//                   العهد القديم      <- secondary
//
//   Arabic mode :   العهد القديم      <- primary
//                   Old Testament     <- secondary
// ================================================================

class BilingualText extends StatelessWidget {
  const BilingualText({
    super.key,
    required this.english,
    required this.arabic,
    required this.primaryIsArabic,
    this.style,
    this.secondaryStyle,
    this.textAlign,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 3,
  });

  /// Text shown when the interface language is English.
  final String english;

  /// Text shown when the interface language is Arabic.
  final String arabic;

  /// Whether the PRIMARY (top) line should be Arabic.
  final bool primaryIsArabic;

  /// Style of the primary (top) line.
  final TextStyle? style;

  /// Style of the secondary (bottom) line.
  /// Falls back to a smaller, faded version of [style].
  final TextStyle? secondaryStyle;

  final TextAlign? textAlign;

  final CrossAxisAlignment crossAxisAlignment;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    final primary = primaryIsArabic ? arabic : english;
    final secondary = primaryIsArabic ? english : arabic;

    final effectiveSecondaryStyle = secondaryStyle ??
        (style ?? const TextStyle()).copyWith(
          fontSize: (style?.fontSize ?? 14) * 0.72,
          fontWeight: FontWeight.w500,
          color: (style?.color ??
                  Theme.of(context).textTheme.bodyMedium?.color)
              ?.withValues(alpha: 0.75),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          primary,
          style: style,
          textAlign: textAlign,
        ),

        SizedBox(height: spacing),

        // Force the correct direction for the secondary
        // language regardless of the ambient directionality.
        Directionality(
          textDirection: primaryIsArabic
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Text(
            secondary,
            style: effectiveSecondaryStyle,
            textAlign: textAlign,
          ),
        ),
      ],
    );
  }
}