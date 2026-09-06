import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/saved/saved_item.dart';
import '../../core/saved/saved_items_provider.dart';

// ================================================================
// SAVED PAGE (المحفوظات)
//
// Lists every page the user saved while reading (Bible chapters,
// Agpeya prayers, Traneem hymns, readings, documents). Tapping an
// item reopens the original content; the trash icon removes it.
// ================================================================

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  @override
  void initState() {
    super.initState();

    ref.watch(savedItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);

    final strings = AppStrings(preferences.interfaceLanguage);

    final saved = ref.watch(savedItemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.savedTitle)),

      body: saved.isEmpty
          ? _buildEmptyState(context, strings)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: saved.length,
              itemBuilder: (context, index) =>
                  _buildItem(context, strings, saved[index]),
            ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    AppStrings strings,
    SavedItem item,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(item.routePath),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
                  item.kind.icon,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------
              // REMOVE
              // -------------------------------------------------
              IconButton(
                tooltip: strings.isArabic ? 'إزالة' : 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  ref
                      .read(savedItemsProvider.notifier)
                      .remove(item.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppStrings strings,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.bookmark_outline,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.savedEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.savedEmptyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}