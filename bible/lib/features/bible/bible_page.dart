import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/bible/bible_content_provider.dart';
import '../../core/bible/bible_models.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/bilingual_text.dart';

class BiblePage extends ConsumerStatefulWidget {
  const BiblePage({super.key});

  @override
  ConsumerState<BiblePage> createState() {
    return _BiblePageState();
  }
}

class _BiblePageState extends ConsumerState<BiblePage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository =
        ref.watch(bibleContentRepositoryProvider);

    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    final allBooks = repository.books;

    final filteredBooks = allBooks.where((book) {
      if (_searchQuery.isEmpty) {
        return true;
      }

      return book.name
              .toLowerCase()
              .contains(_searchQuery) ||
          book.arabicName.contains(_searchQuery) ||
          book.id
              .toLowerCase()
              .contains(_searchQuery);
    }).toList();

    final oldTestament = filteredBooks
        .where(
          (book) =>
              book.testament == BibleTestament.old,
        )
        .toList();

    final newTestament = filteredBooks
        .where(
          (book) =>
              book.testament ==
              BibleTestament.newTestament,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        32,
      ),
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        Text(
          strings.bible,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 6),

        Text(strings.readOffline),

        const SizedBox(height: 20),

        // ========================================================
        // SEARCH
        // ========================================================

        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            hintText: strings.searchBible,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ========================================================
        // OLD TESTAMENT
        // ========================================================

        if (oldTestament.isNotEmpty)
          _buildTestamentSection(
            context,
            strings: strings,
            englishTitle: 'Old Testament',
            arabicTitle: 'العهد القديم',
            icon: Icons.menu_book_outlined,
            books: oldTestament,
          ),

        // ========================================================
        // NEW TESTAMENT
        // ========================================================

        if (oldTestament.isNotEmpty &&
            newTestament.isNotEmpty)
          const SizedBox(height: 28),

        if (newTestament.isNotEmpty)
          _buildTestamentSection(
            context,
            strings: strings,
            englishTitle: 'New Testament',
            arabicTitle: 'العهد الجديد',
            icon: Icons.auto_stories_outlined,
            books: newTestament,
          ),

        // ========================================================
        // NO RESULTS
        // ========================================================

        if (filteredBooks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: 50,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 52,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    strings.noBooksFound,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // TESTAMENT SECTION
  // ============================================================

  Widget _buildTestamentSection(
    BuildContext context, {
    required AppStrings strings,
    required String englishTitle,
    required String arabicTitle,
    required IconData icon,
    required List<BibleBook> books,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // SECTION HEADER
        //
        // Bilingual format: chosen language on top,
        // the other language underneath.
        // --------------------------------------------------------

        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: BilingualText(
                english: englishTitle,
                arabic: arabicTitle,
                primaryIsArabic: strings.isArabic,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Number of books
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '${books.length}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // --------------------------------------------------------
        // BOOKS
        // --------------------------------------------------------

        ...books.map(
          (book) => _BookCard(
            book: book,
            primaryIsArabic: strings.isArabic,
            chaptersLabel:
                strings.chaptersCountLabel,
            onTap: () {
              context.push('/book/${book.id}');
            },
          ),
        ),
      ],
    );
  }
}

// ================================================================
// BOOK CARD
// ================================================================

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.primaryIsArabic,
    required this.chaptersLabel,
    required this.onTap,
  });

  final BibleBook book;

  /// Whether the PRIMARY (top) name should be Arabic.
  final bool primaryIsArabic;

  /// Localized label under the chapter count.
  final String chaptersLabel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              // --------------------------------------------------
              // ICON
              // --------------------------------------------------

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),

              const SizedBox(width: 14),

              // --------------------------------------------------
              // BOOK NAME (bilingual format)
              // --------------------------------------------------

              Expanded(
                child: BilingualText(
                  english: book.name,
                  arabic: book.arabicName,
                  primaryIsArabic: primaryIsArabic,
                  spacing: 3,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
              ),

              // --------------------------------------------------
              // CHAPTER COUNT
              // --------------------------------------------------

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    '${book.chapterCount}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  Text(
                    chaptersLabel,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}