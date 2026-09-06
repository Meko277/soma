import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

// ============================================================
// LITURGY HOME (اختيار نوع القداس)
//
// Shown when tapping القداس in the bottom navigation:
// lets the user choose which of the three Coptic
// anaphoras to open:
//
//   - قداس الباسيلي     (most days of the year)
//   - قداس الغريغوري     (feasts of our Lord)
//   - القداس الكيرلسي    (Great Lent / Nineveh fast)
// ============================================================

class LiturgyHomePage extends ConsumerWidget {
  const LiturgyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final theme = Theme.of(context);

    final kinds = [
      (
        'basil',
        strings.basilName,
        strings.basilSubtitle,
        Icons.church_outlined,
      ),
      (
        'gregory',
        strings.gregoryName,
        strings.gregorySubtitle,
        Icons.celebration_outlined,
      ),
      (
        'cyril',
        strings.cyrilName,
        strings.cyrilSubtitle,
        Icons.self_improvement_outlined,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Text(
          strings.liturgy,

          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          strings.liturgyChooseSubtitle,

          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // THE THREE ANAPHORAS
        // ------------------------------------------------------

        for (final kind in kinds) ...[
          SectionCard(
            title: kind.$2,
            subtitle: kind.$3,
            icon: kind.$4,
            onTap: () => context.push('/liturgy/${kind.$1}'),
          ),

          const SizedBox(height: 4),
        ],
      ],
    );
  }
}
