import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/liturgy/liturgy_content_provider.dart';
import '../../core/liturgy/liturgy_models.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/sync/sync_holder.dart';
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
  ConsumerState<LiturgyReaderPage> createState() => _LiturgyReaderPageState();
}

class _LiturgyReaderPageState extends ConsumerState<LiturgyReaderPage> {
  final LiturgyContentProvider _provider = const LiturgyContentProvider();

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

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _sectionKeys = {};

  /// AR / EN / CO display language picked with the radio
  /// row (defaults to the incoming content language).
  String get _initialDisplay => switch (widget.language) {
    'ar' => 'ar',
    'co' => 'co',
    _ => 'en',
  };

  String _displayLang = 'ar';

  /// Reload when Firestore sync delivers newer content so the page
  /// reflects admin edits without a restart.
  StreamSubscription<void>? _syncSub;

  @override
  void initState() {
    super.initState();

    _displayLang = _initialDisplay;

    _startLoading();

    // Listen for Firestore content updates and reload this liturgy.
    final sync = SyncHolder.instance;
    _syncSub = sync?.liturgyUpdates.listen((_) {
      if (!mounted) return;
      setState(_startLoading);
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _sectionKey(int index) =>
      _sectionKeys.putIfAbsent(index, GlobalKey.new);

  void _goToSection(int index) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _sectionKey(index).currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: 0.08,
        );
      }
    });
  }

  void _startLoading() {
    _doc = null;
    _error = null;
    _loading = true;
    _lastSlideIndex = 0;
    _presentationDismissed = false;
    _manualPresenting = false;
    _displayLang = _initialDisplay;

    _provider
        .loadDocument(widget.kindId, language: widget.language)
        .then((doc) {
          if (!mounted) return;

          setState(() {
            _doc = doc;
            _loading = false;
          });
        })
        .catchError((Object error) {
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
        MediaQuery.of(context).orientation == Orientation.landscape;

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

    final strings = AppStrings(preferences.interfaceLanguage);

    // Arabic rendering follows the ACTIVE display language
    // (AR is RTL; EN / Coptic are LTR).
    final isArabic = _displayLang == 'ar';

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
                  doc == null
                      ? (isArabic ? 'القداس الإلهي' : 'The Holy Liturgy')
                      : _docTitle(doc),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  if (doc != null)
                    Builder(
                      builder: (context) => IconButton(
                        tooltip: isArabic ? 'أقسام القداس' : 'Liturgy sections',
                        icon: const Icon(Icons.menu_book_outlined),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  if (doc != null)
                    IconButton(
                      tooltip: strings.presentationModeTitle,
                      icon: const Icon(Icons.slideshow_outlined),
                      onPressed: () {
                        setState(() {
                          _manualPresenting = true;
                        });
                      },
                    ),
                  if (doc != null)
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showInfoSheet(context, doc),
                    ),
                ],
              ),

        endDrawer: presenting || doc == null
            ? null
            : _buildSectionsDrawer(context, doc, isArabic),

        // Note: 'presenting' already implies doc != null,
        // which promotes 'doc' for everything below.
        body: presenting
            ? PresentationReader(
                slides: _buildSlides(doc, strings),

                headerTitle: doc.name,

                isRtl: isArabic,

                startIndex: _lastSlideIndex,

                onPageChanged: (page) => _lastSlideIndex = page,

                exitTooltip: strings.presentationExitLabel,

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
  Widget _buildBody(LiturgyDocument? doc, AppStrings strings, bool isArabic) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorView(_error!);
    }

    final loadedDoc = doc;

    if (loadedDoc == null) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,

      // Language radio pinned to the top, the sections list
      // scrolls underneath it.
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _LanguageRadioRow(
              value: _displayLang,
              onChanged: (next) {
                setState(() => _displayLang = next);
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: loadedDoc.sections.length,
              itemBuilder: (context, index) {
                final section = loadedDoc.sections[index];
                final previous = index == 0
                    ? null
                    : loadedDoc.sections[index - 1].group;
                return Container(
                  key: _sectionKey(index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (previous != section.group)
                        _buildGroupHeader(section.group),
                      _buildSectionCard(section, index, strings),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsDrawer(
    BuildContext context,
    LiturgyDocument doc,
    bool isArabic,
  ) {
    return Drawer(
      width: 350,
      child: SafeArea(
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.church_outlined),
                title: Text(
                  isArabic ? 'أقسام القداس' : 'Liturgy sections',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_docTitle(doc)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: doc.sections.length,
                  itemBuilder: (context, index) {
                    final section = doc.sections[index];
                    final title = _sectionTitle(section);
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(title),
                      subtitle: section.readingType.isNotEmpty
                          ? Text(
                              isArabic
                                  ? 'قراءة: ${section.readingType}'
                                  : 'Reading: ${section.readingType}',
                            )
                          : null,
                      onTap: () => _goToSection(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(LiturgySectionGroup group) {
    final (arabic, english) = switch (group) {
      LiturgySectionGroup.offering => ('تقديم الحمل', 'Offering of the Lamb'),
      LiturgySectionGroup.word => ('قداس الكلمة', 'Liturgy of the Word'),
      LiturgySectionGroup.faithful => (
        'قداس المؤمنين',
        'Liturgy of the Faithful',
      ),
      LiturgySectionGroup.distribution => ('التوزيع', 'Holy Communion'),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Text(
        _displayLang == 'ar' ? arabic : english,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // ============================================================
  // LOCALIZED TEXT (AR / EN / CO embedded in the same JSON)
  //
  // Every selection falls back to the previous language when
  // the requested one is missing, and finally to the plain
  // 'content'/'title' field.
  // ============================================================

  String _docTitle(LiturgyDocument doc) {
    switch (_displayLang) {
      case 'en':
        return doc.englishName.isNotEmpty ? doc.englishName : doc.name;
      case 'co':
        return doc.nameCo.isNotEmpty ? doc.nameCo : doc.name;
      default:
        return doc.name;
    }
  }

  String _docUsedWhen(LiturgyDocument doc) {
    if (_displayLang == 'en' && doc.usedWhenEn.isNotEmpty) {
      return doc.usedWhenEn;
    }
    return doc.usedWhen;
  }

  String _docIntroduction(LiturgyDocument doc) {
    switch (_displayLang) {
      case 'en':
        return doc.introductionEn.isNotEmpty
            ? doc.introductionEn
            : doc.introduction;
      case 'co':
        return doc.introductionCo.isNotEmpty
            ? doc.introductionCo
            : doc.introduction;
      default:
        return doc.introduction;
    }
  }

  String _sectionTitle(LiturgySection section) {
    switch (_displayLang) {
      case 'en':
        return section.titleEn.isNotEmpty ? section.titleEn : section.title;
      case 'co':
        return section.titleCo.isNotEmpty ? section.titleCo : section.title;
      default:
        return section.title;
    }
  }

  List<String> _sectionContent(LiturgySection section) {
    switch (_displayLang) {
      case 'en':
        return section.contentEn.isNotEmpty
            ? section.contentEn
            : section.content;
      case 'co':
        return section.contentCo.isNotEmpty
            ? section.contentCo
            : section.content;
      default:
        return section.content;
    }
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

    final readerColor = _readerColor(section.reader, theme);

    return Card(
      elevation: 0,

      margin: const EdgeInsets.symmetric(vertical: 6),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ----------------------------------------
            // WHO READS IT badge (more visible)
            // ----------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

              decoration: BoxDecoration(
                color: readerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: readerColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _readerIcon(section.reader),
                    size: 16,
                    color: readerColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${strings.readByPrefix} '
                    '${_readerShort(section.reader, strings)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: readerColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (section.readingType.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _readingLabel(section.readingType),
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),

            // ----------------------------------------
            // Section title (localized)
            // ----------------------------------------
            Text(
              '${index + 1}. ${_sectionTitle(section)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            // ----------------------------------------
            // Paragraphs (localized)
            // ----------------------------------------
            for (final paragraph in _sectionContent(section)) ...[
              Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.95),
              ),

              const SizedBox(height: 9),
            ],
          ],
        ),
      ),
    );
  }

  String _readingLabel(String type) {
    final labels = <String, (String, String)>{
      'pauline': ('البولس', 'Pauline Epistle'),
      'catholic': ('الكاثوليكون', 'Catholic Epistle'),
      'acts': ('الإبركسيس', 'Acts'),
      'synaxar': ('السنكسار', 'Synaxarium'),
      'psalm': ('المزمور', 'Psalm'),
      'gospel': ('الإنجيل', 'Gospel'),
      'readings': ('القراءات', 'Readings'),
    };
    final label = labels[type] ?? (type, type);
    return _displayLang == 'ar' ? label.$1 : label.$2;
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

  Color _readerColor(SectionReader reader, ThemeData theme) {
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

  String _readerShort(SectionReader reader, AppStrings strings) {
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

  String _readerFull(SectionReader reader, AppStrings strings) {
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
      PresentationSlide(text: _docTitle(doc), label: _docUsedWhen(doc)),
    ];

    for (final section in doc.sections) {
      // A title slide per section, labelled with who
      // reads it.
      slides.add(
        PresentationSlide(
          text: _sectionTitle(section),
          label: '• ${_readerFull(section.reader, strings)} •',
        ),
      );

      for (final paragraph in _sectionContent(section)) {
        slides.add(PresentationSlide(text: paragraph));
      }
    }

    return slides;
  }

  // ============================================================
  // INFO SHEET
  // ============================================================

  void _showInfoSheet(BuildContext context, LiturgyDocument doc) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _docTitle(doc),
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                _docUsedWhen(doc),
                style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _docIntroduction(doc),
                style: Theme.of(
                  sheetContext,
                ).textTheme.bodyLarge?.copyWith(height: 1.8),
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
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LANGUAGE RADIO ROW (AR | EN | CO)
//
/// Coptic Reader style switch. 'co' is the Coptic language
/// marker used across the app; content for it is loaded from
/// the same embedded contentCo fields.
// ============================================================

class _LanguageRadioRow extends StatelessWidget {
  const _LanguageRadioRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langButton(context, 'ar', 'العربية'),
          _langButton(context, 'en', 'English'),
          _langButton(context, 'co', 'ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ'),
        ],
      ),
    );
  }

  Widget _langButton(BuildContext context, String lang, String label) {
    final selected = value == lang;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(lang),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
