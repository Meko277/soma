import 'package:flutter/material.dart';

import '../../core/bible/bible_content_repository.dart';
import '../../core/bible/bible_models.dart';

/// Shows each requested translation beside the others, verse-for-verse.
/// Missing offline assets are surfaced rather than silently substituted.
class ParallelChapterReader extends StatefulWidget {
  const ParallelChapterReader({
    super.key,
    required this.book,
    required this.primaryChapter,
    required this.primaryLanguage,
    required this.languages,
  });

  final BibleBook book;
  final BibleChapter primaryChapter;
  final String primaryLanguage;
  final List<String> languages;

  @override
  State<ParallelChapterReader> createState() => _ParallelChapterReaderState();
}

class _ParallelChapterReaderState extends State<ParallelChapterReader> {
  final _repository = BibleContentRepository();
  late Future<List<_LoadedTranslation>> _translations;

  @override
  void initState() {
    super.initState();
    _translations = _loadTranslations();
  }

  @override
  void didUpdateWidget(covariant ParallelChapterReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryChapter.chapterNumber !=
            widget.primaryChapter.chapterNumber ||
        oldWidget.book.id != widget.book.id ||
        oldWidget.languages.join(',') != widget.languages.join(',')) {
      _translations = _loadTranslations();
    }
  }

  Future<List<_LoadedTranslation>> _loadTranslations() async {
    final requested = [
      for (final language in const ['en', 'copt', 'ar'])
        if (widget.languages.contains(language)) language,
    ];
    final translations = <_LoadedTranslation>[];
    for (final language in requested) {
      if (language == widget.primaryLanguage) {
        translations.add(_LoadedTranslation(language, widget.primaryChapter));
        continue;
      }
      final chapter = await _repository.loadChapter(
        bookId: widget.book.id,
        chapterNumber: widget.primaryChapter.chapterNumber,
        language: language,
      );
      if (chapter != null) {
        translations.add(_LoadedTranslation(language, chapter));
      }
    }
    return translations;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_LoadedTranslation>>(
      future: _translations,
      builder: (context, snapshot) {
        final loaded =
            snapshot.data ??
            <_LoadedTranslation>[
              _LoadedTranslation(widget.primaryLanguage, widget.primaryChapter),
            ];
        final missing = widget.languages
            .where(
              (language) => !loaded.any((item) => item.language == language),
            )
            .toList();
        return _ParallelVerseList(
          book: widget.book,
          translations: loaded,
          missingLanguages: [
            for (final language in const ['en', 'copt', 'ar'])
              if (missing.contains(language)) language,
          ],
        );
      },
    );
  }
}

class _LoadedTranslation {
  const _LoadedTranslation(this.language, this.chapter);

  final String language;
  final BibleChapter chapter;
}

class _ParallelVerseList extends StatelessWidget {
  const _ParallelVerseList({
    required this.book,
    required this.translations,
    required this.missingLanguages,
  });

  final BibleBook book;
  final List<_LoadedTranslation> translations;
  final List<String> missingLanguages;

  @override
  Widget build(BuildContext context) {
    final verseCount = translations
        .map((translation) => translation.chapter.verses.length)
        .reduce((a, b) => a < b ? a : b);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: verseCount + 1 + (missingLanguages.isEmpty ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _header(context);
        }
        if (index == 1 && missingLanguages.isNotEmpty) {
          return _missingNotice(context);
        }
        final verseIndex = index - (missingLanguages.isNotEmpty ? 2 : 1);
        if (verseIndex < 0 || verseIndex >= verseCount) {
          return const SizedBox.shrink();
        }
        return _verseRow(context, verseIndex);
      },
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: translations
              .map(
                (translation) => Expanded(
                  child: Text(
                    '${_bookName(translation.language)} ${translation.chapter.chapterNumber}\n${_languageLabel(translation.language)}',
                    textAlign: translation.language == 'ar'
                        ? TextAlign.right
                        : TextAlign.left,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _missingNotice(BuildContext context) {
    final labels = missingLanguages.map(_languageLabel).join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Offline text not installed for: $labels',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _verseRow(BuildContext context, int verseIndex) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: translations.map((translation) {
            final verse = translation.chapter.verses[verseIndex];
            final isArabic = translation.language == 'ar';
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${verse.number} ',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: verse.text),
                    ],
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.75),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _bookName(String language) =>
      language == 'ar' ? book.arabicName : book.name;

  String _languageLabel(String language) => switch (language) {
    'ar' => 'Arabic',
    'en' => 'English',
    'copt' => 'Coptic',
    _ => language,
  };
}
