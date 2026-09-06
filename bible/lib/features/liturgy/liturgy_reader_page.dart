import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/liturgy/liturgy_content_provider.dart';
import '../../core/liturgy/liturgy_models.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../widgets/presentation_reader.dart';

// ============================================================
// LITURGY READER PAGE
//
// Opens ONE of the three anaphoras (basil / gregory /
// cyril). Every section shows a badge telling WHO reads
// it (priest / deacons / congregation / everyone), and
// landscape PRESENTATION MODE works here exactly like in
// the Bible & Agpeya readers (local dismissal +
// position memory).
// ============================================================

class LiturgyReaderPage extends ConsumerStatefulWidget {
  const LiturgyReaderPage({
    super.key,
    required this.kindId,
    required this.language,
  });

  /// 'basil' | 'gregory' | 'cyril'
  final String kindId;

  /// 'ar' | 'en'
  final String language;

  @override
  ConsumerState<LiturgyReaderPage> createState() =>
      _LiturgyReaderPageState();
}

class _LiturgyReaderPageState
    extends ConsumerState<LiturgyReaderPage> {
  final LiturgyContentProvider _provider =
      const LiturgyContentProvider();

  /// Loaded document (null until ready).
  LiturgyDocument? _doc;

  /// Loading / error flags driving the body branches.
  bool _loading = true;
  String? _error;

  // ============================================================
  // PRESENTATION MODE STATE (same pattern as other readers)
  // ============================================================

  bool _wasLandscape = false;

  /// Manual entry via the slideshow button - lets users
  /// present WITHOUT relying on auto-rotate being unlocked.
  bool _manualPresenting = false;

  /// Local dismissal via the X button - re-arms when the
  /// device returns to portrait. The settings switch stays
  /// as the master control.
  bool _presentationDismissed = false;

  /// Last slide index so rotations resume where you were.
  int _lastSlideIndex = 0;

  @override
  void initState() {
    super.initState();

    _startLoading();
  }

  void _startLoading() {
    _doc = null;
    _error = null;
    _loading = true;
    _lastSlideIndex = 0;
    _presentationDismissed = false;
    _manualPresenting = false;

    _provider
        .loadDocument(
      widget.kindId,
      language: widget.language,
    )
        .then((doc) {
      if (!mounted) return;

      setState(() {
        _doc = doc;
        _loading = false;
      });
    }).catchError((Object error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    });
  }

  @override
  void didUpdateWidget(covariant LiturgyReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.kindId != widget.kindId ||
        oldWidget.language != widget.language) {
      setState(_startLoading);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isLandscape =
        MediaQuery.of(context).orientation ==
            Orientation.landscape;

    if (_wasLandscape && !isLandscape) {
      // Back to portrait -> re-arm presentation mode.
      _presentationDismissed = false;
    }

    _wasLandscape = isLandscape;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);

    final strings =
        AppStrings(preferences.interfaceLanguage);

    final isArabic = widget.language == 'ar';

    final isLandscape =
        MediaQuery.of(context).orientation ==
            Orientation.landscape;

    final doc = _doc;

    // Landscape OR the manual slideshow button both enter
    // presentation mode (so it works even when auto-rotate
    // is locked on the device).
    final presenting =
        preferences.presentationModeEnabled &&
            (isLandscape || _manualPresenting) &&
            !_presentationDismissed &&
            doc != null;

    return Directionality(
      // Scaffold stays LTR; Arabic is applied per-content.
      textDirection: TextDirection.ltr,

      child: Scaffold(
        appBar: presenting
            ? null
            : AppBar(
                title: Text(
                  doc?.name ??
                      (isArabic
                          ? 'القداس الإلهي'
                          : 'The Holy Liturgy'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  if (doc != null)
                    IconButton(
                      tooltip:
                          strings.presentationModeTitle,
                      icon: const Icon(
                          Icons.slideshow_outlined),
                      onPressed: () {
                        setState(() {
                          _manualPresenting = true;
                        });
                      },
                    ),
                  if (doc != null)
                    IconButton(
                      icon: const Icon(
                          Icons.info_outline),
                      onPressed: () =>
                          _showInfoSheet(context, doc),
                    ),
                ],
              ),

        // Note: 'presenting' already implies doc != null,
        // which promotes 'doc' for everything below.
        body: presenting
            ? PresentationReader(
                slides: _buildSlides(doc, strings),

                headerTitle: doc.name,

                isRtl: isArabic,

                startIndex: _lastSlideIndex,

                onPageChanged: (page) =>
                    _lastSlideIndex = page,

                exitTooltip:
                    strings.presentationExitLabel,

                onExit: () {
                  setState(() {
                    _presentationDismissed = true;
                    _manualPresenting = false;
                  });
                },
              )
            : _buildBody(doc, strings, isArabic),
      ),
    );
  }

  /// Normal (portrait / dismissed) reading view.
  Widget _buildBody(
    LiturgyDocument? doc,
    AppStrings strings,
    bool isArabic,
  ) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorView(_error!);
    }

    final loadedDoc = doc;

    if (loadedDoc == null) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,

      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),

        itemCount: loadedDoc.sections.length,

        itemBuilder: (context, index) {
          return _buildSectionCard(
            loadedDoc.sections[index],
            index,
            strings,
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION CARD (with WHO READS IT badge)
  // ============================================================

  Widget _buildSectionCard(
    LiturgySection section,
    int index,
    AppStrings strings,
  ) {
    final theme = Theme.of(context);

    final readerColor = _readerColor(
      section.reader,
      theme,
    );

    return Card(
      elevation: 0,

      margin: const EdgeInsets.symmetric(vertical: 6),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ----------------------------------------
            // WHO READS IT badge
            // ----------------------------------------
            Container(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),

              decoration: BoxDecoration(
                color:
                    readerColor.withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _readerIcon(section.reader),
                    size: 14,
                    color: readerColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${strings.readByPrefix} ${_readerShort(section.reader, strings)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: readerColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ----------------------------------------
            // Section title
            // ----------------------------------------
            Text(
              '${index + 1}. ${section.title}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(
                      fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ----------------------------------------
            // Paragraphs
            // ----------------------------------------
            for (final paragraph
                in section.content) ...[
              Text(
                paragraph,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(height: 1.9),
              ),

              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  IconData _readerIcon(SectionReader reader) {
    switch (reader) {
      case SectionReader.priest:
        return Icons.church;
      case SectionReader.deacons:
        return Icons.record_voice_over;
      case SectionReader.people:
        return Icons.groups;
      case SectionReader.all:
        return Icons.people_alt;
    }
  }

  Color _readerColor(
    SectionReader reader,
    ThemeData theme,
  ) {
    switch (reader) {
      case SectionReader.priest:
        return theme.colorScheme.primary;
      case SectionReader.deacons:
        return Colors.teal;
      case SectionReader.people:
        return Colors.indigo;
      case SectionReader.all:
        return theme.colorScheme.secondary;
    }
  }

  String _readerShort(
    SectionReader reader,
    AppStrings strings,
  ) {
    switch (reader) {
      case SectionReader.priest:
        return strings.readerPriest;
      case SectionReader.deacons:
        return strings.readerDeacons;
      case SectionReader.people:
        return strings.readerPeople;
      case SectionReader.all:
        return strings.readerAll;
    }
  }

  String _readerFull(
    SectionReader reader,
    AppStrings strings,
  ) {
    return '${strings.readByPrefix} '
        '${_readerShort(reader, strings)}';
  }

  // ============================================================
  // PRESENTATION SLIDES
  // ============================================================

  List<PresentationSlide> _buildSlides(
    LiturgyDocument doc,
    AppStrings strings,
  ) {
    final slides = <PresentationSlide>[
      PresentationSlide(
        text: doc.name,
        label: doc.usedWhen,
      ),
    ];

    for (final section in doc.sections) {
      // A title slide per section, labelled with who
      // reads it.
      slides.add(
        PresentationSlide(
          text: section.title,
          label: '• ${_readerFull(section.reader, strings)} •',
        ),
      );

      for (final paragraph in section.content) {
        slides.add(PresentationSlide(text: paragraph));
      }
    }

    return slides;
  }

  // ============================================================
  // INFO SHEET
  // ============================================================

  void _showInfoSheet(
    BuildContext context,
    LiturgyDocument doc,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding:
              const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.name,
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                        fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                doc.usedWhen,
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .primary,
                    ),
              ),

              const SizedBox(height: 12),

              Text(
                doc.introduction,
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.8),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


