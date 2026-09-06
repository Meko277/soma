import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bible/bible_models.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/bilingual_text.dart';

class BibleBookChaptersPage extends ConsumerWidget {
  const BibleBookChaptersPage({
    super.key,
    required this.book,
  });

  final BibleBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    return Scaffold(
      appBar: AppBar(
        title: BilingualText(
          english: book.name,
          arabic: book.arabicName,
          primaryIsArabic: strings.isArabic,
          spacing: 1,
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------
            // HEADER (bilingual format)
            // ------------------------------------------------------

            BilingualText(
              english: book.name,
              arabic: book.arabicName,
              primaryIsArabic: strings.isArabic,
              style:
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
            ),

            const SizedBox(height: 8),

            Text(
              '${book.chapterCount} ${strings.chaptersCountLabel}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: book.chapterCount,
                itemBuilder: (context, index) {
                  final chapterNumber = index + 1;

                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.push(
                          '/chapter/${book.id}-$chapterNumber',
                        );
                      },
                      child: Center(
                        child: Text(
                          '$chapterNumber',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}