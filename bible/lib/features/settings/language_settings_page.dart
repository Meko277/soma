import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(preferencesProvider);

    final controller = ref.read(preferencesProvider.notifier);

    final strings = AppStrings(settings.interfaceLanguage);

    return Scaffold(
      appBar: AppBar(title: Text(strings.languageTitle)),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ------------------------------------------------
          // INTERFACE LANGUAGE
          // ------------------------------------------------

          Text(
            strings.interfaceLanguageHeading,

            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------
          // Interface language (modern RadioGroup API).
          // ------------------------------------------------
          RadioGroup<AppLanguage>(
            groupValue: settings.interfaceLanguage,

            onChanged: (value) {
              if (value != null) {
                controller.setInterfaceLanguage(value);
              }
            },

            child: Column(
              children: [
                ...AppLanguage.values.map(
                  (language) => RadioListTile<AppLanguage>(
                    value: language,
                    title: Text(language.label),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ------------------------------------------------
          // CONTENT LANGUAGE
          // ------------------------------------------------
          Text(
            strings.contentLanguageHeading,

            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------
          // Content language (modern RadioGroup API).
          // ------------------------------------------------
          RadioGroup<AppLanguage>(
            groupValue: settings.contentLanguage,

            onChanged: (value) {
              if (value != null) {
                controller.setContentLanguage(value);
              }
            },

            child: Column(
              children: [
                ...AppLanguage.values.map(
                  (language) => RadioListTile<AppLanguage>(
                    value: language,
                    title: Text(language.label),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
