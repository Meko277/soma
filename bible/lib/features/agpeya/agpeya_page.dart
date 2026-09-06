import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/bilingual_text.dart';

class AgpeyaPage extends ConsumerWidget {
  const AgpeyaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    final prayers = [
      (
        id: 'morning',
        title: 'Morning Prayer',
        subtitle: 'صلاة باكر',
        icon: Icons.wb_sunny_outlined,
      ),
      (
        id: 'third',
        title: 'Third Hour',
        subtitle: 'الساعة الثالثة',
        icon: Icons.access_time_outlined,
      ),
      (
        id: 'sixth',
        title: 'Sixth Hour',
        subtitle: 'الساعة السادسة',
        icon: Icons.wb_sunny,
      ),
      (
        id: 'ninth',
        title: 'Ninth Hour',
        subtitle: 'الساعة التاسعة',
        icon: Icons.schedule_outlined,
      ),
      (
        id: 'vespers',
        title: 'Vespers',
        subtitle: 'صلاة الغروب',
        icon: Icons.wb_twilight,
      ),
      (
        id: 'compline',
        title: 'Compline',
        subtitle: 'صلاة النوم',
        icon: Icons.nightlight_outlined,
      ),
      (
        id: 'midnight',
        title: 'Midnight Prayer',
        subtitle: 'صلاة نصف الليل',
        icon: Icons.dark_mode_outlined,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Bilingual format like the Bible pages.
        title: BilingualText(
          english: strings.agpeya,
          arabic: 'الأجبية',
          primaryIsArabic: strings.isArabic,
          spacing: 1,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        children: [
          // ------------------------------------------------------
          // HEADER (bilingual format)
          // ------------------------------------------------------

          BilingualText(
            english: 'The Agpeya',
            arabic: 'الأجبية المقدسة',
            primaryIsArabic: strings.isArabic,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          ...prayers.map(
            (prayer) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.push(
                    '/agpeya/${prayer.id}',
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          prayer.icon,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: BilingualText(
                          english: prayer.title,
                          arabic: prayer.subtitle,
                          primaryIsArabic: strings.isArabic,
                          spacing: 3,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}