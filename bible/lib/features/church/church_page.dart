import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content_providers.dart';
import '../../core/content/library_item.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

class ChurchPage extends ConsumerWidget {
  const ChurchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(contentRepositoryProvider).churchItems();

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        Text(
          strings.church,

          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(strings.churchDescription),

        const SizedBox(height: 16),

        ...items.map(
          (item) => SectionCard(
            title: item.title,
            subtitle: item.subtitle,
            icon: _iconFor(item.kind),
            onTap: () => context.push('/reader/${item.id}'),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(LibraryKind kind) => switch (kind) {
    LibraryKind.prayer => Icons.nightlight_outlined,
    LibraryKind.liturgy => Icons.church_outlined,
    LibraryKind.hymn => Icons.music_note_outlined,
    LibraryKind.saint => Icons.person_outline,
    LibraryKind.rite => Icons.volunteer_activism_outlined,
    LibraryKind.bible => Icons.menu_book_outlined,
  };
}
