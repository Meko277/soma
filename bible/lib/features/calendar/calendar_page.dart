import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calendar/calendar_providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/section_card.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final day = ref.watch(selectedLiturgicalDayProvider);

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final gregorian = day.gregorianDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.calendar),
        actions: [
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).state =
                DateUtils.dateOnly(DateTime.now()),
            child: Text(strings.today),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: DateTime(1900),
            lastDate: DateTime(2200),
            onDateChanged: (date) =>
                ref.read(selectedDateProvider.notifier).state = date,
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ----------------------------------------
                  // COPTIC DATE (localized)
                  // ----------------------------------------

                  Text(
                    strings.isArabic
                        ? day.copticDate.displayArabic
                        : day.copticDate.display,

                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  _infoRow(
                    strings.gregorianDateLabel,
                    '${gregorian.day}/'
                    '${gregorian.month}/'
                    '${gregorian.year}',
                  ),

                  _infoRow(
                    strings.seasonLabel,
                    strings.localizedSeasonName(day.season.toString()),
                  ),

                  if (day.fastName != null)
                    _infoRow(
                      strings.fastLabel,
                      strings.localizedFastName(day.fastName),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // READINGS
          // ------------------------------------------------
          Text(
            strings.readingsLabel,

            style: Theme.of(context).textTheme.titleLarge,
          ),

          ...day.readings.map(
            (reading) => SectionCard(
              title: strings.isArabic
                  ? (reading.titleAr ?? reading.title)
                  : reading.title,
              subtitle: reading.reference,
              icon: Icons.menu_book_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text('$label: '),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
