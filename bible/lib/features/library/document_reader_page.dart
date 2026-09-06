import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/content_providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';

class DocumentReaderPage extends ConsumerWidget {
  const DocumentReaderPage({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.read(contentRepositoryProvider).byId(documentId);

    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.documentNotAvailable)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.bookmark_border)),
          IconButton(onPressed: null, icon: Icon(Icons.share_outlined)),
        ],
      ),

      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(24),

          children: [
            Text(
              item.subtitle,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),

            const SizedBox(height: 24),

            Text(
              item.body,

              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(height: 1.7),
            ),

            const SizedBox(height: 28),

            Text(
              strings.contentPacksTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(strings.contentPacksBody),
          ],
        ),
      ),
    );
  }
}
