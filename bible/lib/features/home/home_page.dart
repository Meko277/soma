import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bible/bible_content_provider.dart';
import '../../core/bible/bible_content_repository.dart';
import '../../core/calendar/calendar_providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/localization/daily_verse.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../models/daily_reading.dart';
import '../../widgets/bilingual_text.dart';
import '../../widgets/section_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedLiturgicalDayProvider);

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    // Last saved Bible reading (null until the user
    // opens their first chapter).
    final lastReadingChapterId = preferences.lastReadingChapterId;

    final repository = ref.watch(bibleContentRepositoryProvider);

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        // ---------------------------------------------------------
        // Header (with the SOMA app logo)
        // ---------------------------------------------------------

        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/soma.png',
                width: 54,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.peaceAndBlessing,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    strings.isArabic
                        ? day.copticDate.displayArabic
                        : day.copticDate.display,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ---------------------------------------------------------
        // Continue Reading (last saved Bible reading)
        // ---------------------------------------------------------
        if (lastReadingChapterId != null) ...[
          _buildContinueReadingCard(
            context,
            strings,
            repository,
            lastReadingChapterId,
          ),

          const SizedBox(height: 20),
        ],

        // ---------------------------------------------------------
        // Verse of the Day
        // ---------------------------------------------------------
        _buildVerseCard(context, strings),

        const SizedBox(height: 20),

        // ---------------------------------------------------------
        // القداس (MEMORIAL PRAYER - THE HOLY LITURGY)
        //
        // Replaces the old "Today" section, which now lives
        // under More -> Today.
        // ---------------------------------------------------------
        Text(
          strings.liturgy,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        SectionCard(
          title: strings.liturgyCardTitle,
          subtitle: strings.liturgyDescription,
          icon: Icons.church_outlined,
          onTap: () => context.push('/liturgy'),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------
        // Quick Access
        // ---------------------------------------------------------
        Text(
          strings.quickAccess,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        SectionCard(
          title: strings.bible,
          subtitle: strings.bibleDescription,
          icon: Icons.auto_stories_outlined,
          onTap: () => context.go('/bible'),
        ),

        SectionCard(
          title: strings.calendar,
          subtitle:
              '${strings.isArabic ? day.copticDate.displayArabic : day.copticDate.display} • ${strings.calendarDescription}',
          icon: Icons.calendar_month_outlined,
          onTap: () => context.push('/calendar'),
        ),

        SectionCard(
          title: strings.agpeya,
          subtitle: strings.agpeyaDescription,
          icon: Icons.nightlight_outlined,
          onTap: () => context.push('/agpeya'),
        ),

        // ---------------------------------------------------------
        // TRANEEM (الترانيم) - text-only hymn lyrics, fully offline.
        // ---------------------------------------------------------
        SectionCard(
          title: strings.traneem,
          subtitle: strings.traneemSubtitle,
          icon: Icons.music_note_outlined,
          onTap: () => context.push('/traneem'),
        ),

        SectionCard(
          title: strings.translator,
          subtitle: strings.translatorSubtitle,
          icon: Icons.translate_outlined,
          onTap: () => context.push('/translator'),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------
        // TODAY'S READINGS (last section)
        //
        // A real per-day plan that changes every day.
        // Tapping a reading opens it in the Bible reader,
        // with a hint of WHO reads it.
        // ---------------------------------------------------------
        Text(
          strings.dailyReadings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(strings.readingsDescription, style: theme.textTheme.bodyMedium),

        const SizedBox(height: 12),

        ...day.readings.map(
          (reading) => _buildReadingCard(context, strings, reading),
        ),
      ],
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    AppStrings strings,
    BibleContentRepository repository,
    String chapterId,
  ) {
    final theme = Theme.of(context);

    // ---------------------------------------------------------
    // Resolve a friendly label from the chapter id
    // (e.g. 'genesis-3' -> 'Genesis 3' / 'التكوين 3').
    // ---------------------------------------------------------

    // ---------------------------------------------------------
    // Resolve BOTH language names so the label can be
    // shown in the bilingual format (chosen language on
    // top, the other underneath).
    // ---------------------------------------------------------

    var englishLabel = chapterId;
    var arabicLabel = chapterId;

    for (final book in repository.books) {
      final prefix = '${book.id}-';

      if (chapterId.startsWith(prefix)) {
        final chapterNumber = int.tryParse(chapterId.substring(prefix.length));

        englishLabel = chapterNumber == null
            ? book.name
            : '${book.name} $chapterNumber';

        arabicLabel = chapterNumber == null
            ? book.arabicName
            : '${book.arabicName} $chapterNumber';

        break;
      }
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/chapter/$chapterId'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_stories_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.continueReading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      strings.continueReadingSubtitle,
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 6),

                    BilingualText(
                      english: englishLabel,
                      arabic: arabicLabel,
                      primaryIsArabic: strings.isArabic,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard(BuildContext context, AppStrings strings) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  strings.dailyVerse,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ----------------------------------------
            // The daily verse is ALWAYS Arabic
            // (Van Dyke), regardless of the interface
            // language -> wrap in an RTL direction.
            // ----------------------------------------
            Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DailyVerseRepository.today.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    DailyVerseRepository.today.reference,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(
    BuildContext context,
    AppStrings strings,
    DailyReading reading,
  ) {
    final theme = Theme.of(context);

    final isArabic = strings.isArabic;

    // Localized reading name.
    final title = isArabic ? (reading.titleAr ?? reading.title) : reading.title;

    // Localized verse preview (may be empty).
    final excerpt = isArabic ? (reading.excerptAr ?? '') : reading.excerpt;

    // ---------------------------------------------------------
    // WHO reads this part (Coptic rite):
    // Psalm -> People, Epistles/Praxis -> Deacons,
    // Gospel -> Priests.
    // ---------------------------------------------------------

    final String roleLabel;
    final IconData roleIcon;

    switch (reading.readBy) {
      case ReadingRole.people:
        roleLabel = strings.readByPeople;
        roleIcon = Icons.groups;
        break;

      case ReadingRole.deacons:
        roleLabel = strings.readByDeacons;
        roleIcon = Icons.record_voice_over;
        break;

      case ReadingRole.priests:
        roleLabel = strings.readByPriests;
        roleIcon = Icons.church;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Open the actual chapter in the Bible reader,
          // passing WHO reads it as a hint banner.
          final bookId = reading.bookId;
          final chapter = reading.chapter;

          if (bookId != null && chapter != null) {
            context.push(
              '/chapter/$bookId-$chapter'
              '?role=${reading.readBy.name}',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      reading.reference,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // --------------------------------------
                    // WHO READS IT
                    // (People / Deacons / Priests)
                    // --------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            roleIcon,
                            size: 13,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            roleLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 6),

                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
