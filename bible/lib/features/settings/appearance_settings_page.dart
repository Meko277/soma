import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';

class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(preferencesProvider);

    final controller = ref.read(preferencesProvider.notifier);

    final strings = AppStrings(settings.interfaceLanguage);

    return Scaffold(
      appBar: AppBar(title: Text(strings.appearance)),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Text(
            strings.themeHeading,

            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------
          // Theme mode radio group (modern RadioGroup API):
          // Beige (light) / Blue (dark) / System.
          // ------------------------------------------------
          RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,

            onChanged: (value) {
              if (value != null) {
                controller.setTheme(value);
              }
            },

            child: Column(
              children: [
                // BEIGE (light)
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(strings.themeBeige),
                  subtitle: Text(strings.themeBeigeSubtitle),
                ),

                // BLUE (dark)
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(strings.themeBlue),
                  subtitle: Text(strings.themeBlueSubtitle),
                ),

                // SYSTEM
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(strings.themeSystem),
                  subtitle: Text(strings.themeSystemSubtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
