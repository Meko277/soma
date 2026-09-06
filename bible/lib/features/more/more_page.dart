import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_strings.dart';
import '../../core/notifications/daily_plan_notification_service.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final isArabic = strings.isArabic;

    // ----------------------------------------------------------
    // Current notification time label (11:00 AM default).
    // ----------------------------------------------------------

    final hour = preferences.notificationHour;
    final minute = preferences.notificationMinute;

    final period = isArabic
        ? (hour >= 12 ? 'م' : 'ص')
        : (hour >= 12 ? 'PM' : 'AM');

    var displayHour = hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    final timeLabel =
        '$displayHour:${minute.toString().padLeft(2, '0')} $period';

    final notificationSubtitle = isArabic
        ? 'تصل خطة اليوم يوميًا في $timeLabel • انقر للتغيير'
        : 'Your plan arrives daily at $timeLabel • tap to change';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          strings.more,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------------
        // DAILY NOTIFICATION TIME
        //
        // Tap -> pick the preferred delivery time.
        // Saved instantly and re-scheduled immediately.
        // Default: 11:00 AM.
        // --------------------------------------------------------
        SectionCard(
          title: strings.notificationTimeTitle,
          subtitle: notificationSubtitle,
          icon: Icons.notifications_active_outlined,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: hour, minute: minute),
            );

            if (picked == null) {
              return;
            }

            await ref
                .read(preferencesProvider.notifier)
                .setNotificationTime(picked.hour, picked.minute);

            // Apply the change immediately.
            await DailyPlanNotificationService.instance.scheduleDailyPlan(
              hour: picked.hour,
              minute: picked.minute,
            );
          },
        ),

        // --------------------------------------------------------
        // TODAY (moved here from the bottom navigation)
        //
        // Opens the daily guide: today's readings plus the
        // liturgical information (Coptic date, season, fast,
        // saint of the day).
        // --------------------------------------------------------
        SectionCard(
          title: strings.today,
          subtitle: strings.moreTodaySubtitle,
          icon: Icons.today_outlined,
          onTap: () => context.push('/today'),
        ),

        SectionCard(
          title: strings.calendar,
          subtitle: strings.moreCalendarSubtitle,
          icon: Icons.calendar_month_outlined,
          onTap: () => context.push('/calendar'),
        ),

        SectionCard(
          title: strings.appearance,
          subtitle: strings.moreAppearanceSubtitle,
          icon: Icons.palette_outlined,
          onTap: () => context.push('/settings/appearance'),
        ),

        SectionCard(
          title: strings.languageTitle,
          subtitle: strings.moreLanguageSubtitle,
          icon: Icons.language_outlined,
          onTap: () => context.push('/settings/language'),
        ),

        SectionCard(
          title: strings.traneem,
          subtitle:
              isArabic ? 'ألحان وكلمات ترانيم للقراءة' : 'Hymn lyrics for reading',
          icon: Icons.music_note_outlined,
          onTap: () => context.push('/traneem'),
        ),

        SectionCard(
          title: strings.moreBookmarksTitle,
          subtitle: strings.moreBookmarksSubtitle,
          icon: Icons.bookmark_outline,
          onTap: () => context.push('/saved'),
        ),

        SectionCard(
          title: strings.moreSearchTitle,
          subtitle: strings.moreSearchSubtitle,
          icon: Icons.search,
        ),
      ],
    );
  }
}
