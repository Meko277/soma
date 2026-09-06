import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bible/bible_content_provider.dart';
import '../../core/bible/bible_models.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/saved/saved_item.dart';
import '../../core/saved/saved_items_provider.dart';
import '../../widgets/bilingual_text.dart';
import '../../widgets/floating_text_zoom.dart';
import '../../widgets/presentation_reader.dart';
import '../../widgets/reading_settings_drawer.dart';

// ============================================================
// BIBLE CHAPTER READER PAGE
//
// Works exactly like the Agpeya prayer page:
//
//   - ONE drawer on the RIGHT side (endDrawer):
//       * Chapters grid
//       * Settings button in the footer that swaps the
//         drawer content to the reading settings panel
//         (with a back button) - identical to Agpeya.
//
//   - ONE-SIDE swipe: only the RIGHT screen edge
//     opens the drawer (plus the AppBar button).
//
//   - EXPLICIT saving only: a bookmark button beside
//     the drawer button saves the current chapter as
//     the last reading. Opening chapters or drawers
//     NEVER saves anything automatically.
//
//   - The chapter future is CACHED in state, so rebuilds
//     (font scale slider, theme switch, drawer open...)
//     never restart the chapter load -> buttery smooth.
// ============================================================

class BibleChapterReaderPage extends ConsumerStatefulWidget {
  const BibleChapterReaderPage({
    super.key,
    required this.chapterId,
    this.roleHint,
  });

  final String chapterId;

  /// Optional hint of WHO reads this passage
  /// ('people' | 'deacons' | 'priests') — shown as a
  /// banner above the verses when opened from a
  /// daily reading.
  final String? roleHint;

  @override
  ConsumerState<BibleChapterReaderPage> createState() =>
      _BibleChapterReaderPageState();
}

class _BibleChapterReaderPageState
    extends ConsumerState<BibleChapterReaderPage> {
  // ============================================================
  // STATE
  // ============================================================

  String _bookId = '';
  int _chapterNumber = 1;
  BibleBook? _book;

  late String _language;
  late Future<BibleChapter?> _chapterFuture;

  // Settings view shown inside the drawer (Agpeya pattern)
  bool _showSettingsInDrawer = false;

  /// Tracks the device orientation so the reader can flip
  /// into PRESENTATION MODE (one verse per screen) when the
  /// phone is rotated to landscape.
  bool _isLandscape = false;

  // ============================================================
  // PRESENTATION MODE STATE
  // ============================================================

  /// Set when the user exits presentation mode with the X
  /// button. Unlike the old behaviour this does NOT disable
  /// presentation globally - it only dismisses it until the
  /// device returns to portrait (then it is re-armed). The
  /// master switch remains the toggle in reading settings.
  bool _presentationDismissed = false;

  /// Last slide shown in presentation mode, so rotating
  /// back to landscape resumes where you were instead of
  /// restarting from verse 1.
  int _lastPresentationIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final wasLandscape = _isLandscape;

    _isLandscape =
        MediaQuery.of(context).orientation ==
            Orientation.landscape;

    // Returning to portrait re-arms presentation mode
    // after a local dismissal (X button).
    if (wasLandscape && !_isLandscape) {
      _presentationDismissed = false;
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _resolveLocation();

    _language = _getBibleLanguage(
      ref.read(preferencesProvider).contentLanguage,
    );

    _startLoading();
  }

  @override
  void didUpdateWidget(
    covariant BibleChapterReaderPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.chapterId != widget.chapterId) {
      _resolveLocation();
      _startLoading();

      // New chapter -> restart the presentation position
      // and re-arm presentation mode if it was dismissed.
      _lastPresentationIndex = 0;
      _presentationDismissed = false;
    }
  }

  // ============================================================
  // LOCATION PARSING
  //
  // Examples:
  //
  //   genesis-1
  //   john-3
  //   1corinthians-13
  //   1peter-2
  // ============================================================

  void _resolveLocation() {
    final repository =
        ref.read(bibleContentRepositoryProvider);

    _bookId = '';
    _chapterNumber = 1;

    for (final book in repository.books) {
      final prefix = '${book.id}-';

      if (widget.chapterId.startsWith(prefix)) {
        _bookId = book.id;

        _chapterNumber = int.tryParse(
              widget.chapterId.substring(prefix.length),
            ) ??
            1;

        break;
      }
    }

    _book = repository.bookById(_bookId);
  }

  void _startLoading() {
    final repository =
        ref.read(bibleContentRepositoryProvider);

    _chapterFuture = repository.loadChapter(
      bookId: _bookId,
      chapterNumber: _chapterNumber,
      language: _language,
    );

    // NOTE: nothing is saved automatically here.
    // Saving happens ONLY when the user taps the
    // bookmark (save) button in the AppBar.
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);

    // UI chrome follows the CHOSEN INTERFACE language
    // (with the other language shown underneath in
    // titles), while scripture text follows the
    // CONTENT language preference.
    final uiIsArabic =
        preferences.interfaceLanguage.isRtl;

    final language =
        _getBibleLanguage(preferences.contentLanguage);

    // ----------------------------------------------------------
    // Content language changed from the settings panel:
    // reload silently (no spinner flash, drawer stays put).
    // ----------------------------------------------------------

    if (language != _language) {
      _language = language;
      _startLoading();
    }

    final book = _book;

    final strings = AppStrings(
      preferences.interfaceLanguage,
    );

    // ----------------------------------------------------------
    // BOOK NOT FOUND
    // ----------------------------------------------------------

    if (book == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(strings.bible),
        ),
        body: Center(
          child: Text(
            '${strings.bookNotFoundLabel}\n\nID: $_bookId',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    /*
     * The Scaffold itself stays LTR so the endDrawer
     * always sits on the RIGHT - exactly like the
     * Agpeya prayer page.
     *
     * Arabic direction is applied to the reading
     * content and drawer contents separately.
     */

    // ----------------------------------------------------------
    // PRESENTATION MODE (landscape)
    //
    // When the phone is in LANDSCAPE and the user has not
    // disabled it, the chapter turns into a presentation:
    // black background, ONE VERSE PER SCREEN, swipe to move.
    // ----------------------------------------------------------

    final presenting =
        preferences.presentationModeEnabled &&
            _isLandscape &&
            !_presentationDismissed;

    return Directionality(
      textDirection: TextDirection.ltr,

      child: Scaffold(
        // ==============================================
        // ONE-SIDE SWIPE
        //
        // Only the RIGHT edge opens the drawer
        // (there is no left drawer anymore).
        // Disabled while presenting (swipes move verses).
        // ==============================================

        drawerEdgeDragWidth: presenting ? 0 : 150,

        endDrawerEnableOpenDragGesture: !presenting,

        // ==============================================
        // APP BAR (hidden in presentation mode)
        // ==============================================

        appBar: presenting ? null : AppBar(
          // Bilingual format: chosen language on top,
          // the other underneath.
          title: BilingualText(
            english: '${book.name} $_chapterNumber',
            arabic: '${book.arabicName} $_chapterNumber',
            primaryIsArabic: uiIsArabic,
            spacing: 1,
            style:
                Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
          ),

          actions: [
            // ------------------------------------------
            // LAST READING BUTTON
            //
            // Sits beside the drawer button and jumps
            // back to the previously read chapter.
            // Hidden until at least two different
            // chapters have been read.
            // ------------------------------------------

            _buildLastReadingButton(preferences),

            // ------------------------------------------
            // SAVE READING BUTTON
            //
            // Explicitly saves the CURRENT chapter as
            // the last reading. Nothing is ever saved
            // automatically.
            // ------------------------------------------

            _buildSaveReadingButton(preferences),

            // ------------------------------------------
            // BOOKMARK BUTTON (Saved page)
            //
            // Adds/removes the CURRENT chapter in the
            // Saved list - persisted by SharedPreferences
            // and shown on the Saved screen.
            // ------------------------------------------

            _buildBookmarkButton(preferences),

            // ------------------------------------------
            // Builder gives a context that is UNDER
            // the Scaffold, so Scaffold.of() works
            // (same pattern as the Agpeya page).
            // ------------------------------------------

            Builder(
              builder: (context) {
                return IconButton(
                  tooltip: uiIsArabic
                      ? 'الأصحاح'
                      : 'Chapters',
                  icon: const Icon(
                    Icons.grid_view_outlined,
                  ),
                  onPressed: () {
                    Scaffold.of(context)
                        .openEndDrawer();
                  },
                );
              },
            ),
          ],
        ),

        // ==============================================
        // RIGHT DRAWER -> CHAPTERS (+ SETTINGS INSIDE)
        // ==============================================

            endDrawer: presenting
                ? null
                : _showSettingsInDrawer
                ? _buildSettingsDrawer()
                : _ChaptersDrawer(
                    book: book,
                    currentChapter: _chapterNumber,
                    language: _language,
                    primaryIsArabic: uiIsArabic,
                    chaptersLabel: uiIsArabic
                        ? 'الأصحاح'
                        : 'Chapters',
                    onOpenSettings: () {
                      setState(() {
                        _showSettingsInDrawer = true;
                      });
                    },
                  ),

        // ==============================================
        // BODY
        // ==============================================

        body: FutureBuilder<BibleChapter?>(
          future: _chapterFuture,

          builder: (context, snapshot) {
            // ----------------------------------------
            // LOADING
            // ----------------------------------------

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ----------------------------------------
            // ERROR
            // ----------------------------------------

            if (snapshot.hasError) {
              return _ErrorView(
                bookId: _bookId,
                chapterNumber: _chapterNumber,
                language: _language,
                error: '${snapshot.error}',
                strings: strings,
              );
            }

            // ----------------------------------------
            // NO CHAPTER
            // ----------------------------------------

            final chapter = snapshot.data;

            if (chapter == null) {
              return _EmptyChapter(
                book: book,
                chapterNumber: _chapterNumber,
                strings: strings,
              );
            }

            // ----------------------------------------
            // CHAPTER LOADED
            // ----------------------------------------

            // ----------------------------------------
            // PRESENTATION MODE (landscape)
            //
            // One verse per screen on a black
            // background; swipe / tap to navigate.
            // ----------------------------------------

            if (presenting &&
                chapter.verses.isNotEmpty) {
              return PresentationReader(
                slides: [
                  for (final verse
                      in chapter.verses)
                    PresentationSlide(
                      text: verse.text,
                      badge: '${verse.number}',
                    ),
                ],

                headerTitle:
                    _language == 'ar'
                        ? '${book.arabicName} $_chapterNumber'
                        : '${book.name} $_chapterNumber',

                isRtl: _language == 'ar',

                // Resume on the verse that was last
                // visible instead of verse 1.
                startIndex: _lastPresentationIndex,

                onPageChanged: (page) =>
                    _lastPresentationIndex = page,

                exitTooltip:
                    strings.presentationExitLabel,

                onExit: () {
                  // LOCAL dismissal only - rotating back
                  // to portrait re-arms presentation.
                  // The master switch remains the toggle
                  // in reading settings.
                  setState(() {
                    _presentationDismissed = true;
                  });
                },
              );
            }

            return Stack(
              children: [
                _ReaderPage(
                  book: book,
                  chapter: chapter,
                  language: _language,
                  uiIsArabic: uiIsArabic,
                  roleHint: widget.roleHint,
                ),

                // FLOATING TEXT ZOOM: floats above the reading
                // content only (not over loading/error/empty
                // states, and never in presentation mode).
                const Positioned(
                  right: 16,
                  bottom: 24,
                  child: FloatingTextZoom(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LAST READING BUTTON (beside the drawer button)
  //
  // Jumps to the most recent history entry that is NOT
  // the current chapter - so tapping it toggles you
  // between your two latest chapters.
  // ============================================================

  Widget _buildLastReadingButton(
    AppPreferences preferences,
  ) {
    String? jumpTarget;

    for (final id in preferences.readingHistory) {
      if (id != widget.chapterId) {
        jumpTarget = id;
        break;
      }
    }

    if (jumpTarget == null) {
      return const SizedBox.shrink();
    }

    final isArabic =
        preferences.interfaceLanguage.isRtl;

    return IconButton(
      tooltip: isArabic
          ? 'آخر قراءة'
          : 'Last reading',
      icon: const Icon(Icons.history),
      onPressed: () {
        context.go('/chapter/$jumpTarget');
      },
    );
  }

  // ============================================================
  // SAVE READING BUTTON (beside the drawer button)
  //
  // Saves the CURRENT chapter explicitly. Shows a filled
  // bookmark (disabled) when the current chapter is
  // already the saved one.
  // ============================================================

  Widget _buildSaveReadingButton(
    AppPreferences preferences,
  ) {
    final isSaved =
        preferences.readingHistory.isNotEmpty &&
            preferences.readingHistory.first ==
                widget.chapterId;

    final isArabic =
        preferences.interfaceLanguage.isRtl;

    return IconButton(
      tooltip: isArabic
          ? (isSaved
              ? 'القراءة محفوظة'
              : 'حفظ القراءة')
          : (isSaved
              ? 'Reading saved'
              : 'Save reading'),
      icon: Icon(
        isSaved
            ? Icons.bookmark
            : Icons.bookmark_border,
      ),
      onPressed: isSaved
          ? null
          : () {
              ref
                  .read(preferencesProvider.notifier)
                  .recordReading(widget.chapterId);
            },
    );
  }

  // ============================================================
  // BOOKMARK BUTTON (Saved page)
  //
  // Toggles the CURRENT chapter in the Saved/Bookmarks list
  // (savedItemsProvider). Distinct from the reading-history
  // button above: this one is for the Saved screen.
  // ============================================================

  Widget _buildBookmarkButton(AppPreferences preferences) {
    final savedId = 'bible:${widget.chapterId}';

    // Scoped watch: rebuilds ONLY this button when the saved
    // state flips (not the whole reader).
    final isSaved = ref.watch(
      savedItemsProvider.select(
        (items) => items.any((item) => item.id == savedId),
      ),
    );

    final isArabic = preferences.interfaceLanguage.isRtl;

    final book = _book;

    return IconButton(
      tooltip: isArabic
          ? (isSaved ? 'إزالة من المحفوظات' : 'حفظ في المحفوظات')
          : (isSaved ? 'Remove from Saved' : 'Save to Saved'),
      icon: Icon(
        isSaved
            ? Icons.collections_bookmark
            : Icons.collections_bookmark_outlined,
      ),
      onPressed: book == null
          ? null
          : () {
              ref.read(savedItemsProvider.notifier).toggle(
                    SavedItem(
                      id: savedId,
                      kind: SavedContentKind.bibleChapter,
                      title: isArabic
                          ? '${book.arabicName} $_chapterNumber'
                          : '${book.name} $_chapterNumber',
                      subtitle: isArabic
                          ? 'الكتاب المقدس'
                          : 'Bible',
                      routePath: '/chapter/${widget.chapterId}',
                    ),
                  );
            },
    );
  }

  // ============================================================
  // SETTINGS VIEW INSIDE THE DRAWER (same as Agpeya)
  // ============================================================

  Widget _buildSettingsDrawer() {
    final theme = Theme.of(context);

    final isArabic = _language == 'ar';

    return Drawer(
      width: 350,

      child: SafeArea(
        child: Directionality(
          textDirection: isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,

          child: Column(
            children: [
              // ==============================================
              // SETTINGS HEADER (with back button)
              // ==============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  4,
                  8,
                  16,
                  16,
                ),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    BackButton(
                      color: theme.colorScheme
                          .onPrimaryContainer,
                      onPressed: () {
                        setState(() {
                          _showSettingsInDrawer =
                              false;
                        });
                      },
                    ),

                    Expanded(
                      child: Text(
                        isArabic
                            ? 'الإعدادات'
                            : 'Settings',
                        textAlign: isArabic
                            ? TextAlign.right
                            : TextAlign.left,
                        style: theme.textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                          color: theme.colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Expanded(
                child: ReadingSettingsPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCALIZED HELPERS
  // ============================================================

  String _getBibleLanguage(AppLanguage language) {
    return language == AppLanguage.arabic
        ? 'ar'
        : 'en';
  }
}

// ============================================================
// READER PAGE
// ============================================================

class _ReaderPage extends StatelessWidget {
  const _ReaderPage({
    required this.book,
    required this.chapter,
    required this.language,
    required this.uiIsArabic,
    this.roleHint,
  });

  final BibleBook book;
  final BibleChapter chapter;
  final String language;

  /// Interface-language RTL flag (for the banner).
  final bool uiIsArabic;

  /// WHO reads this passage ('people'|'deacons'|'priests').
  final String? roleHint;

  @override
  Widget build(BuildContext context) {
    final isArabic = language == 'ar';

    final theme = Theme.of(context);

    // ----------------------------------------------------------
    // WHO-READS banner (from a daily reading tap).
    // ----------------------------------------------------------

    String? roleLabel;

    IconData? roleIcon;

    if (roleHint != null) {
      switch (roleHint) {
        case 'people':
          roleLabel = isArabic
              ? 'يقرؤها الشعب'
              : 'Read by the People';
          roleIcon = Icons.groups;
          break;

        case 'deacons':
          roleLabel = isArabic
              ? 'يقرؤها الشمامسة'
              : 'Read by the Deacons';
          roleIcon = Icons.record_voice_over;
          break;

        case 'priests':
          roleLabel = isArabic
              ? 'يقرؤها الكهنة'
              : 'Read by the Priests';
          roleIcon = Icons.church;
          break;
      }
    }

    return SafeArea(
      child: Directionality(
        textDirection: isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,

        child: Column(
          children: [
            // ------------------------------------------
            // ROLE HINT BANNER
            // ------------------------------------------

            if (roleLabel != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isArabic
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Icon(
                      roleIcon,
                      size: 18,
                      color: theme
                          .colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      roleLabel,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

            // ------------------------------------------
            // VERSES
            // ------------------------------------------

            Expanded(
              child: _buildVerseList(context, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseList(
    BuildContext context,
    ThemeData theme,
  ) {
    final isArabic = language == 'ar';

    return ListView.builder(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            40,
          ),

          itemCount: chapter.verses.length + 1,

          itemBuilder: (context, index) {
            // --------------------------------------
            // HEADER
            // --------------------------------------

            if (index == 0) {
              return Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic
                        ? book.arabicName
                        : book.name,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isArabic
                        ? 'الإصحاح ${chapter.chapterNumber}'
                        : 'Chapter ${chapter.chapterNumber}',
                    style: theme
                        .textTheme.titleLarge,
                  ),

                  const SizedBox(height: 28),
                ],
              );
            }

            // --------------------------------------
            // VERSE
            // --------------------------------------

            return _VerseTile(
              verse: chapter.verses[index - 1],
              language: language,
            );
          },
        );
  }
}

// ============================================================
// VERSE
// ============================================================

class _VerseTile extends StatelessWidget {
  const _VerseTile({
    required this.verse,
    required this.language,
  });

  final BibleVerse verse;
  final String language;

  @override
  Widget build(BuildContext context) {
    final isArabic = language == 'ar';

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Text(
              '${verse.number}',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              verse.text,
              textAlign: isArabic
                  ? TextAlign.right
                  : TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    fontSize: 19,
                    height: 1.75,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHAPTERS DRAWER
//
// Styled exactly like the Agpeya sections drawer:
//
//   - Width 350
//   - primaryContainer header
//   - Rounded ListTiles
//   - Settings button in the footer that swaps the
//     drawer content to the settings panel
// ============================================================

class _ChaptersDrawer extends StatelessWidget {
  const _ChaptersDrawer({
    required this.book,
    required this.currentChapter,
    required this.language,
    required this.primaryIsArabic,
    required this.chaptersLabel,
    required this.onOpenSettings,
  });

  final BibleBook book;
  final int currentChapter;
  final String language;

  /// Whether the PRIMARY (top) title line should be
  /// Arabic - follows the INTERFACE language.
  final bool primaryIsArabic;

  /// Localized "Chapters" label.
  final String chaptersLabel;

  final VoidCallback onOpenSettings;

  bool get _isArabic => primaryIsArabic;

  TextDirection get _textDirection =>
      _isArabic ? TextDirection.rtl : TextDirection.ltr;

  String get _settingsText =>
      _isArabic ? 'الإعدادات' : 'Settings';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 350,

      child: SafeArea(
        child: Directionality(
          textDirection: _textDirection,

          child: Column(
            children: [
              // ==============================================
              // HEADER
              // ==============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  24,
                ),
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment:
                      _isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: _isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 38,
                        color: theme.colorScheme
                            .onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(height: 14),

                    BilingualText(
                      english: book.name,
                      arabic: book.arabicName,
                      primaryIsArabic:
                          primaryIsArabic,
                      textAlign: _isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      crossAxisAlignment:
                          _isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      style: theme.textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color: theme.colorScheme
                            .onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      chaptersLabel,
                      textAlign: _isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      style: theme.textTheme
                          .titleMedium
                          ?.copyWith(
                        color: theme.colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              // ==============================================
              // CHAPTERS GRID
              // ==============================================

              Expanded(
                child: GridView.builder(
                  physics:
                      const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: book.chapterCount,
                  itemBuilder: (context, index) {
                    final chapter = index + 1;

                    final selected =
                        chapter == currentChapter;

                    return Card(
                      elevation: 0,
                      color: selected
                          ? theme
                              .colorScheme
                              .primary
                          : theme
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(
                                alpha: 0.5,
                              ),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        onTap: () {
                          // Close the drawer first,
                          // then navigate (same
                          // pattern as the Agpeya
                          // drawer).
                          Navigator.of(context)
                              .pop();

                          context.go(
                            '/chapter/${book.id}-$chapter',
                          );
                        },
                        child: Center(
                          child: Text(
                            '$chapter',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: selected
                                  ? theme
                                      .colorScheme
                                      .onPrimary
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ==============================================
              // SETTINGS BUTTON (footer, like Agpeya)
              // ==============================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  4,
                  10,
                  10,
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    Icons.settings_outlined,
                    color:
                        theme.colorScheme.primary,
                  ),
                  title: Text(
                    _settingsText,
                    textAlign: _isArabic
                        ? TextAlign.right
                        : TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: onOpenSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.bookId,
    required this.chapterNumber,
    required this.language,
    required this.error,
    required this.strings,
  });

  final String bookId;
  final int chapterNumber;
  final String language;
  final String error;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),

            const SizedBox(height: 20),

            Text(
              strings.unableToLoadChapter,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Book: $bookId\n'
              'Chapter: $chapterNumber\n'
              'Language: $language',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY CHAPTER
// ============================================================

class _EmptyChapter extends StatelessWidget {
  const _EmptyChapter({
    required this.book,
    required this.chapterNumber,
    required this.strings,
  });

  final BibleBook book;
  final int chapterNumber;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          strings.chapterNotAddedYet(
            strings.isArabic
                ? book.arabicName
                : book.name,
            chapterNumber,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}