import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_strings.dart';
import '../core/notifications/daily_plan_notification_service.dart';
import '../core/preferences/app_preferences.dart';
import '../core/preferences/preferences_provider.dart';

// ================================================================
// READING SETTINGS DRAWER
//
// A Drawer that lets the user change:
//   - Text size (font scale)
//   - Content language
//   - Theme
//
// Used by the Bible reader and embedded inside the
// Agpeya prayer drawer.
// ================================================================

class ReadingSettingsDrawer extends ConsumerWidget {
  const ReadingSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    return Drawer(
      width: 350,
      child: SafeArea(
        child: Column(
          children: [
            _SettingsHeader(title: strings.settings),

            const Expanded(
              child: ReadingSettingsPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SETTINGS PANEL (CONTENT)
//
// The actual settings UI. Can be used standalone inside
// another drawer.
// ================================================================

class ReadingSettingsPanel extends ConsumerWidget {
  const ReadingSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    final controller =
        ref.read(preferencesProvider.notifier);

    final theme = Theme.of(context);

    final strings = AppStrings(
      preferences.interfaceLanguage,
    );

    final isArabic =
        preferences.interfaceLanguage.isRtl;

    final direction =
        isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: direction,

      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),

        children: [
          // ======================================================
          // TEXT SIZE
          // ======================================================

          _SettingsSectionTitle(
            title: isArabic ? 'حجم الخط' : 'Text Size',
            icon: Icons.text_fields,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Row(
              children: [
                const Text(
                  'A',
                  style: TextStyle(fontSize: 14),
                ),

                Expanded(
                  child: Slider(
                    value: preferences.fontScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    label:
                        '${(preferences.fontScale * 100).round()}%',
                    onChanged: (value) {
                      controller.setFontScale(value);
                    },
                  ),
                ),

                const Text(
                  'A',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Live preview of the text size
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              8,
            ),

            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Text(
                isArabic
                    ? 'في البدء كان الكلمة'
                    : 'In the beginning was the Word',
                textAlign: isArabic
                    ? TextAlign.right
                    : TextAlign.left,
                style: TextStyle(
                  fontSize: 16 * preferences.fontScale,
                  height: 1.6,
                ),
              ),
            ),
          ),

          const Divider(height: 24),

          // ======================================================
          // CONTENT LANGUAGE
          // ======================================================

          _SettingsSectionTitle(
            title: isArabic
                ? 'لغة المحتوى'
                : 'Content Language',
            icon: Icons.language,
          ),

          RadioGroup<AppLanguage>(
            groupValue:
                preferences.contentLanguage,
            onChanged: (value) {
              if (value != null) {
                controller.setContentLanguage(value);
              }
            },
            child: Column(
              children: [
                ...AppLanguage.values.map(
                  (language) =>
                      RadioListTile<AppLanguage>(
                    value: language,
                    title: Text(language.label),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // ======================================================
          // INTERFACE LANGUAGE
          // ======================================================

          _SettingsSectionTitle(
            title: isArabic
                ? 'لغة التطبيق'
                : 'Interface Language',
            icon: Icons.translate,
          ),

          RadioGroup<AppLanguage>(
            groupValue:
                preferences.interfaceLanguage,
            onChanged: (value) {
              if (value != null) {
                controller
                    .setInterfaceLanguage(value);
              }
            },
            child: Column(
              children: [
                ...AppLanguage.values.map(
                  (language) =>
                      RadioListTile<AppLanguage>(
                    value: language,
                    title: Text(language.label),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // ======================================================
          // THEME
          // ======================================================

          _SettingsSectionTitle(
            title: strings.appearance,
            icon: Icons.palette_outlined,
          ),

          RadioGroup<ThemeMode>(
            groupValue: preferences.themeMode,
            onChanged: (value) {
              if (value != null) {
                controller.setTheme(value);
              }
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title:
                      Text(isArabic ? 'بيج' : 'Beige'),
                  subtitle: Text(
                    isArabic
                        ? 'مظهر دافئ فاتح'
                        : 'Warm parchment light look',
                  ),
                ),

                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title:
                      Text(isArabic ? 'أزرق' : 'Blue'),
                  subtitle: Text(
                    isArabic
                        ? 'مظهر داكن مريح للعين'
                        : 'Deep navy dark look',
                  ),
                ),

                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(
                    isArabic ? 'النظام' : 'System',
                  ),
                  subtitle: Text(
                    isArabic
                        ? 'حسب إعدادات الجهاز'
                        : 'Follow device appearance',
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          const Divider(height: 24),

          // ======================================================
          // READING DISPLAY (languages shown together)
          // ======================================================

          _SettingsSectionTitle(
            title: strings.readingDisplayTitle,
            icon: Icons.translate,
          ),

          RadioGroup<BibleDisplayMode>(
            groupValue:
                preferences.bibleDisplayMode,
            onChanged: (value) {
              if (value != null) {
                controller.setBibleDisplayMode(value);
              }
            },
            child: Column(
              children: [
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.single,
                  title: Text(strings.displaySingleLabel),
                ),
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.englishArabic,
                  title: Text(strings.displayEnAr),
                ),
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.arabicEnglish,
                  title: Text(strings.displayArEn),
                ),
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.copticArabic,
                  title: Text(strings.displayCoptAr),
                ),
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.copticEnglish,
                  title: Text(strings.displayCoptEn),
                ),
                RadioListTile<BibleDisplayMode>(
                  value: BibleDisplayMode.all,
                  title: Text(strings.displayAllLabel),
                ),
              ],
            ),
          ),

          SwitchListTile(
            value: preferences.presentationModeEnabled,
            onChanged: controller
                .setPresentationModeEnabled,
            title: Text(strings.presentationModeTitle),
            subtitle: Text(
              strings.presentationModeSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          //
          // Picking a time saves it AND instantly
          // re-schedules the daily plan notifications.
          // ======================================================

          _SettingsSectionTitle(
            title: strings.notificationTimeTitle,
            icon: Icons.notifications_active_outlined,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              8,
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: Icon(
                  Icons.schedule,
                  color:
                      theme.colorScheme.primary,
                ),
                title: Text(
                  strings.notificationTimeSubtitle,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                trailing: Text(
                  _formatNotificationTime(
                    preferences.notificationHour,
                    preferences.notificationMinute,
                    isArabic,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color:
                        theme.colorScheme.primary,
                  ),
                ),
                onTap: () async {
                  final picked =
                      await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour:
                          preferences.notificationHour,
                      minute: preferences
                          .notificationMinute,
                    ),
                  );

                  if (picked == null) {
                    return;
                  }

                  await controller.setNotificationTime(
                    picked.hour,
                    picked.minute,
                  );

                  // Re-schedule immediately so the
                  // change applies without waiting
                  // for the next app start.
                  await DailyPlanNotificationService
                      .instance
                      .scheduleDailyPlan(
                    hour: picked.hour,
                    minute: picked.minute,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Formats a 24-hour time as a readable label,
  /// e.g. '11:00 AM' or '١١:٠٠ م' style for Arabic.
  String _formatNotificationTime(
    int hour,
    int minute,
    bool isArabic,
  ) {
    final period = isArabic
        ? (hour >= 12 ? 'م' : 'ص')
        : (hour >= 12 ? 'PM' : 'AM');

    var display = hour % 12;

    if (display == 0) {
      display = 12;
    }

    final mm = minute.toString().padLeft(2, '0');

    return '$display:$mm $period';
  }
}

// ================================================================
// SETTINGS HEADER
// ================================================================

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 38,
            color:
                theme.colorScheme.onPrimaryContainer,
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SECTION TITLE
// ================================================================

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        4,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}