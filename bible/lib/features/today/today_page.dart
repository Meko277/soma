import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/calendar/calendar_providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedLiturgicalDayProvider);

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),

      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------

        Text(
          strings.todayGuideTitle,

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

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // LITURGICAL INFORMATION
        //
        // Moved here from the Home page (which now shows the
        // القداس / memorial-prayer card instead).
        // ------------------------------------------------------
        _buildLiturgicalInfoCard(context, strings, day),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // TODAY'S READINGS (localized titles + open in reader)
        // ------------------------------------------------------
        ...day.readings.map(
          (reading) => SectionCard(
            title: strings.isArabic
                ? (reading.titleAr ?? reading.title)
                : reading.title,
            subtitle: reading.reference,
            icon: Icons.menu_book_outlined,

            // Only readings that map to a Bible book
            // can be opened in the chapter reader.
            onTap: reading.bookId != null && reading.chapter != null
                ? () => context.push(
                    '/chapter/${reading.bookId}'
                    '-${reading.chapter}'
                    '?role=${reading.readBy.name}',
                  )
                : null,
          ),
        ),

        // ------------------------------------------------------
        // CALENDAR SHORTCUT
        // ------------------------------------------------------
        SectionCard(
          title: strings.openCalendar,
          subtitle: strings.chooseDifferentDay,
          icon: Icons.calendar_month_outlined,
          onTap: () => context.push('/calendar'),
        ),
      ],
    );
  }

  // ============================================================
  // LITURGICAL INFO CARD
  // (moved verbatim from the Home page)
  // ============================================================

  Widget _buildLiturgicalInfoCard(
    BuildContext context,
    AppStrings strings,
    dynamic day,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoRow(
              context,
              Icons.calendar_today_outlined,
              strings.copticDateLabel,
              strings.isArabic
                  ? day.copticDate.displayArabic
                  : day.copticDate.display,
            ),

            const Divider(height: 24),

            _infoRow(
              context,
              Icons.church_outlined,
              strings.seasonLabel,
              strings.localizedSeasonName(day.season.toString()),
            ),

            if (day.fastName != null) ...[
              const Divider(height: 24),
              _infoRow(
                context,
                Icons.no_food_outlined,
                strings.fastLabel,
                strings.localizedFastName(day.fastName),
              ),
            ],

            if (day.saintName != null) ...[
              const Divider(height: 24),
              _infoRow(
                context,
                Icons.person_outline,
                strings.saintLabel,
                day.saintName!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
