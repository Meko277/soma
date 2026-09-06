import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/agpeya/agpeya_content_provider.dart';
import '../../core/agpeya/agpeya_models.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/saved/saved_item.dart';
import '../../core/saved/saved_items_provider.dart';
import '../../widgets/bilingual_text.dart';
import '../../widgets/floating_text_zoom.dart';
import '../../widgets/presentation_reader.dart';
import '../../widgets/reading_settings_drawer.dart';

class AgpeyaPrayerPage extends StatefulWidget {
  final String prayerId;

  /// Title used by the AppBar.
  final String title;

  /// Arabic title of the prayer.
  /// Used when the current language is English.
  final String arabicTitle;

  /// Agpeya content language:
  /// 'ar' = Arabic
  /// 'en' = English
  final String language;

  const AgpeyaPrayerPage({
    super.key,
    required this.prayerId,
    required this.title,
    required this.arabicTitle,
    this.language = 'en',
  });

  @override
  State<AgpeyaPrayerPage> createState() => _AgpeyaPrayerPageState();
}

class _AgpeyaPrayerPageState extends State<AgpeyaPrayerPage> {
  late Future<AgpeyaHour> _hourFuture;

  /// Cached hour so scroll tracking runs fully
  /// synchronously (no futures allocated per scroll
  /// event -> much smoother scrolling).
  AgpeyaHour? _loadedHour;

  /// Cached drawer sections - rebuilt ONLY when the
  /// hour reloads or the language changes, so scroll
  /// tracking never rebuilds lists while scrolling.
  List<_AgpeyaDrawerSection>? _cachedSections;

  final AgpeyaContentProvider _provider = const AgpeyaContentProvider();

  // ============================================================
  // Scroll Controller
  // ============================================================

  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // Main Section Keys
  // ============================================================

  final GlobalKey _introductionKey = GlobalKey();
  final GlobalKey _openingKey = GlobalKey();
  final GlobalKey _hourIntroKey = GlobalKey();
  final GlobalKey _comeLetUsWorshipKey = GlobalKey();
  final GlobalKey _thanksgivingKey = GlobalKey();
  final GlobalKey _introductoryPsalmKey = GlobalKey();
  final GlobalKey _psalmsKey = GlobalKey();
  final GlobalKey _gospelKey = GlobalKey();
  final GlobalKey _litaniesKey = GlobalKey();
  final GlobalKey _lordsPrayerKey = GlobalKey();
  final GlobalKey _closingKey = GlobalKey();
  final GlobalKey _additionalSectionsKey = GlobalKey();
  final GlobalKey _watchesKey = GlobalKey();
  final GlobalKey _chaptersKey = GlobalKey();

  // ============================================================
  // Sub-item Keys
  // ============================================================

  final Map<String, GlobalKey> _psalmKeys = {};
  final Map<String, GlobalKey> _litanyKeys = {};
  final Map<String, GlobalKey> _watchKeys = {};
  final Map<int, GlobalKey> _chapterKeys = {};

  // ============================================================
  // Currently active section
  // ============================================================

  String? _activeSection;

  // ============================================================
  // Expanded sections in drawer
  // ============================================================

  final Set<String> _expandedSections = {};

  // ============================================================
  // Prevent active section update while navigating
  // ============================================================

  bool _isNavigatingToSection = false;

  // ============================================================
  // PRESENTATION MODE STATE
  // ============================================================

  /// Tracks orientation across dependency changes so we can
  /// detect the landscape -> portrait transition.
  bool _wasLandscape = false;

  /// Local dismissal via the X button. Unlike turning the
  /// global preference off, this re-arms automatically when
  /// the device returns to portrait. The settings switch
  /// remains the master control.
  bool _presentationDismissed = false;

  /// Last slide index shown in presentation mode so
  /// rotations resume where the user was.
  int _lastPresentationIndex = 0;

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
  // Show settings panel inside the drawer
  // ============================================================

  bool _showSettingsInDrawer = false;

  // ============================================================
  // Language
  // ============================================================

  bool get _isArabic => widget.language == 'ar';

  TextDirection get _textDirection =>
      _isArabic ? TextDirection.rtl : TextDirection.ltr;

  // ============================================================
  // Localized strings
  // ============================================================

  String get _introductionText => _isArabic ? 'مقدمة' : 'Introduction';

  String get _openingText => _isArabic ? 'البداية' : 'Opening';

  String get _beginningPrayerText =>
      _isArabic ? 'بداية الصلاة' : 'Beginning of the Prayer';

  String get _comeLetUsWorshipText =>
      _isArabic ? 'هلم نسجد' : 'Come, Let Us Worship';

  String get _thanksgivingText =>
      _isArabic ? 'صلاة الشكر' : 'Thanksgiving Prayer';

  String get _psalm50Text => _isArabic ? 'المزمور الخمسين' : 'Psalm 50';

  String get _psalmsText => _isArabic ? 'المزامير' : 'Psalms';

  String get _gospelText => _isArabic ? 'الإنجيل' : 'Gospel';

  String get _litaniesText => _isArabic ? 'الطلبات' : 'Litanies';

  String get _lordsPrayerText =>
      _isArabic ? 'الصلاة الربانية' : "The Lord's Prayer";

  String get _closingText => _isArabic ? 'الختام' : 'Closing';

  String get _additionalSectionsText =>
      _isArabic ? 'أقسام إضافية' : 'Additional Sections';

  String get _watchText => _isArabic ? 'الخدمة' : 'Watch';

  String get _chaptersText => _isArabic ? 'الأقسام' : 'Sections';

  String get _prayerSectionsText =>
      _isArabic ? 'أقسام الصلاة' : 'Prayer sections';

  String get _collapseText => _isArabic ? 'طي' : 'Collapse';

  String get _expandText => _isArabic ? 'فتح' : 'Expand';

  String get _litanyText => _isArabic ? 'طلب' : 'Litany';

  String get _failedToLoadText =>
      _isArabic ? 'فشل تحميل الصلاة.' : 'Failed to load prayer.';

  String get _prayerNotFoundText =>
      _isArabic ? 'الصلاة غير موجودة' : 'Prayer not found';

  String get _settingsText => _isArabic ? 'الإعدادات' : 'Settings';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadHour();

    _scrollController.addListener(_updateActiveSection);
  }

  // ============================================================
  // Load Hour + Cache Result
  // ============================================================

  void _loadHour() {
    _hourFuture = _provider.loadHour(
      widget.prayerId,
      language: widget.language,
    );

    _hourFuture.then((hour) {
      if (!mounted) {
        return;
      }

      // Rebuild so PRESENTATION MODE can engage if the
      // device is already in landscape when the hour
      // finishes loading.
      setState(() {
        _loadedHour = hour;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _activeSection == null) {
          _updateActiveSection();
        }
      });
    });
  }

  // ============================================================
  // RELOAD WHEN LANGUAGE CHANGES FROM SETTINGS
  // ============================================================

  @override
  void didUpdateWidget(covariant AgpeyaPrayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.language != widget.language) {
      setState(() {
        _loadedHour = null;
        _cachedSections = null;
        _activeSection = null;
        _loadHour();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateActiveSection);

    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // Get / Create Psalm Key
  // ============================================================

  GlobalKey _getPsalmKey(AgpeyaPsalm psalm, int index) {
    final keyId = '${psalm.reference}_$index';

    return _psalmKeys.putIfAbsent(keyId, () => GlobalKey());
  }

  // ============================================================
  // Get / Create Watch Key
  // ============================================================

  GlobalKey _getWatchKey(AgpeyaWatch watch, int index) {
    final keyId = watch.id.isNotEmpty ? watch.id : 'watch_$index';

    return _watchKeys.putIfAbsent(keyId, () => GlobalKey());
  }

  // ============================================================
  // Get / Create Chapter Key
  // ============================================================

  GlobalKey _getChapterKey(int index) {
    return _chapterKeys.putIfAbsent(index, () => GlobalKey());
  }

  // ============================================================
  // Get / Create Litany Key
  // ============================================================

  GlobalKey _getLitanyKey(String litany, int index) {
    final keyId = '${index}_$litany';

    return _litanyKeys.putIfAbsent(keyId, () => GlobalKey());
  }

  // ============================================================
  // Section definitions
  // ============================================================

  List<_AgpeyaDrawerSection> _getSections(AgpeyaHour hour) {
    // --------------------------------------------------------
    // Reuse the cached list so scrolling (which calls this
    // constantly) never rebuilds anything.
    // --------------------------------------------------------

    final cached = _cachedSections;

    if (cached != null) {
      return cached;
    }

    final sections = <_AgpeyaDrawerSection>[];

    if (hour.introduction != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'introduction',
          title: _introductionText,
          subtitle: _isArabic ? 'مقدمة الصلاة' : 'Prayer introduction',
          icon: Icons.info_outline,
          key: _introductionKey,
        ),
      );
    }

    if (hour.opening != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'opening',
          title: _openingText,
          subtitle: _isArabic ? 'افتتاح الصلاة' : 'Prayer opening',
          icon: Icons.auto_awesome_outlined,
          key: _openingKey,
        ),
      );
    }

    if (hour.hourIntro != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'hourIntro',
          title: _beginningPrayerText,
          subtitle: _isArabic ? 'بداية الصلاة' : 'Beginning of prayer',
          icon: Icons.menu_book_outlined,
          key: _hourIntroKey,
        ),
      );
    }

    if (hour.comeLetUsWorship != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'comeLetUsWorship',
          title: _comeLetUsWorshipText,
          subtitle: _isArabic ? 'هلم نسجد' : 'Come, Let Us Worship',
          icon: Icons.church_outlined,
          key: _comeLetUsWorshipKey,
        ),
      );
    }

    if (hour.thanksgiving != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'thanksgiving',
          title: _thanksgivingText,
          subtitle: _isArabic ? 'صلاة الشكر' : 'Thanksgiving',
          icon: Icons.volunteer_activism_outlined,
          key: _thanksgivingKey,
        ),
      );
    }

    if (hour.introductoryPsalm != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'introductoryPsalm',
          title: _isArabic ? 'المزمور الخمسين' : 'Psalm 50',
          subtitle: _psalm50Text,
          icon: Icons.music_note_outlined,
          key: _introductoryPsalmKey,
        ),
      );
    }

    // Watches (Midnight prayer)
    for (var i = 0; i < hour.watches.length; i++) {
      final watch = hour.watches[i];

      sections.add(
        _AgpeyaDrawerSection(
          id: 'watch_$i',
          title: watch.name.isNotEmpty ? watch.name : '$_watchText ${i + 1}',
          subtitle: watch.theme ?? (_isArabic ? 'الخدمة' : 'Watch'),
          icon: Icons.dark_mode_outlined,
          key: _getWatchKey(watch, i),
        ),
      );
    }

    if (hour.psalms.isNotEmpty) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'psalms',
          title: _psalmsText,
          subtitle: _isArabic ? 'المزامير' : 'Psalms',
          icon: Icons.library_music_outlined,
          key: _psalmsKey,
          hasChildren: true,
        ),
      );
    }

    if (hour.gospel != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'gospel',
          title: _gospelText,
          subtitle: _isArabic ? 'الإنجيل' : 'The Gospel',
          icon: Icons.auto_stories_outlined,
          key: _gospelKey,
        ),
      );
    }

    if (hour.litanies != null && hour.litanies!.content.isNotEmpty) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'litanies',
          title: _litaniesText,
          subtitle: _isArabic ? 'الطلبات' : 'Litanies',
          icon: Icons.pan_tool_outlined,
          key: _litaniesKey,
          hasChildren: true,
        ),
      );
    }

    if (hour.lordsPrayer != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'lordsPrayer',
          title: _lordsPrayerText,
          subtitle: _isArabic ? 'الصلاة الربانية' : "The Lord's Prayer",
          icon: Icons.record_voice_over_outlined,
          key: _lordsPrayerKey,
        ),
      );
    }

    if (hour.closing != null) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'closing',
          title: _closingText,
          subtitle: _isArabic ? 'ختام الصلاة' : 'Prayer closing',
          icon: Icons.nightlight_outlined,
          key: _closingKey,
        ),
      );
    }

    if (hour.additionalSections.isNotEmpty) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'additionalSections',
          title: _additionalSectionsText,
          subtitle: _isArabic ? 'أقسام إضافية' : 'Additional sections',
          icon: Icons.playlist_add_outlined,
          key: _additionalSectionsKey,
        ),
      );
    }

    // Chapters (fallback format in some Arabic files)
    if (hour.chapters.isNotEmpty) {
      sections.add(
        _AgpeyaDrawerSection(
          id: 'chapters',
          title: _chaptersText,
          subtitle: _isArabic ? 'أقسام الصلاة' : 'Prayer sections',
          icon: Icons.format_list_numbered_outlined,
          key: _chaptersKey,
          hasChildren: true,
        ),
      );
    }

    _cachedSections = sections;

    return sections;
  }

  // ============================================================
  // Detect current section while scrolling
  // ============================================================

  void _updateActiveSection() {
    if (!mounted || _isNavigatingToSection) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    /*
     * Fully synchronous: uses the cached hour, so
     * scrolling never allocates futures or waits on
     * microtasks. This keeps the scroll buttery smooth.
     */

    final hour = _loadedHour;

    if (hour == null) {
      return;
    }

    final sections = _getSections(hour);

    if (sections.isEmpty) {
      return;
    }

    String? currentSection;

    const double activationPoint = 140;

    for (final section in sections) {
      final context = section.key.currentContext;

      if (context == null) {
        continue;
      }

      final renderObject = context.findRenderObject();

      if (renderObject is! RenderBox) {
        continue;
      }

      final position = renderObject.localToGlobal(Offset.zero);

      final top = position.dy;

      if (top <= activationPoint) {
        currentSection = section.id;
      }
    }

    if (_scrollController.offset <= 20) {
      currentSection = sections.first.id;
    }

    if (currentSection != null && currentSection != _activeSection) {
      setState(() {
        _activeSection = currentSection;
      });
    }
  }

  // ============================================================
  // Toggle expanded section
  // ============================================================

  void _toggleSection(String sectionId) {
    setState(() {
      if (_expandedSections.contains(sectionId)) {
        _expandedSections.remove(sectionId);
      } else {
        _expandedSections.add(sectionId);
      }
    });
  }

  // ============================================================
  // Scroll to Main Section
  // ============================================================

  void _scrollToSection(_AgpeyaDrawerSection section) {
    if (_isNavigatingToSection) {
      return;
    }

    _isNavigatingToSection = true;

    setState(() {
      _activeSection = section.id;
    });

    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      _scrollToKey(section.key, section.id);
    });
  }

  // ============================================================
  // Scroll to Sub Item
  // ============================================================

  void _scrollToSubItem({required GlobalKey key, required String activeId}) {
    if (_isNavigatingToSection) {
      return;
    }

    _isNavigatingToSection = true;

    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      _scrollToKey(key, activeId);
    });
  }

  // ============================================================
  // Scroll using GlobalKey
  // ============================================================

  void _scrollToKey(GlobalKey key, String activeId) {
    final targetContext = key.currentContext;

    if (targetContext == null) {
      _isNavigatingToSection = false;
      return;
    }

    final renderObject = targetContext.findRenderObject();

    if (renderObject is! RenderBox) {
      _isNavigatingToSection = false;
      return;
    }

    final targetPosition = renderObject.localToGlobal(Offset.zero);

    final scrollableContext = _scrollController.position.context.storageContext;

    final scrollableRenderObject = scrollableContext.findRenderObject();

    double viewportTop = 0;

    if (scrollableRenderObject is RenderBox) {
      final viewportPosition = scrollableRenderObject.localToGlobal(
        Offset.zero,
      );

      viewportTop = viewportPosition.dy;
    }

    final relativePosition = targetPosition.dy - viewportTop;

    const double topPadding = 20;

    double targetOffset =
        _scrollController.offset + relativePosition - topPadding;

    targetOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() {
          if (!mounted) {
            return;
          }

          _isNavigatingToSection = false;

          if (_activeSection != activeId) {
            setState(() {
              _activeSection = activeId;
            });
          }
        });
  }

  // ============================================================
  // Drawer
  // ============================================================

  Widget _buildSectionsDrawer(BuildContext context, AgpeyaHour hour) {
    // ========================================================
    // SETTINGS VIEW (opened from the settings button)
    // ========================================================

    if (_showSettingsInDrawer) {
      return _buildSettingsDrawer(context);
    }

    final sections = _getSections(hour);

    return Drawer(
      width: 350,
      child: SafeArea(
        child: Directionality(
          textDirection: _textDirection,
          child: Column(
            children: [
              _buildDrawerHeader(context),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];

                    return _buildDrawerSection(
                      context,
                      hour: hour,
                      section: section,
                    );
                  },
                ),
              ),

              // ================================================
              // SETTINGS BUTTON (footer of the drawer)
              // ================================================
              _buildDrawerSettingsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Drawer Settings Button
  // ============================================================

  Widget _buildDrawerSettingsButton(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          Icons.settings_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          _settingsText,
          textAlign: _isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          setState(() {
            _showSettingsInDrawer = true;
          });
        },
      ),
    );
  }

  // ============================================================
  // Drawer Settings View
  // ============================================================

  Widget _buildSettingsDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 350,
      child: SafeArea(
        child: Directionality(
          textDirection: _textDirection,
          child: Column(
            children: [
              // ==============================================
              // SETTINGS HEADER (with back button)
              // ==============================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                ),
                child: Row(
                  children: [
                    BackButton(
                      color: theme.colorScheme.onPrimaryContainer,
                      onPressed: () {
                        setState(() {
                          _showSettingsInDrawer = false;
                        });
                      },
                    ),

                    Expanded(
                      child: Text(
                        _settingsText,
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Expanded(child: ReadingSettingsPanel()),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Drawer Header
  // ============================================================

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer),
      child: Column(
        crossAxisAlignment: _isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: _isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Icon(
              Icons.menu_book_rounded,
              size: 38,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------
          // Bilingual format driven by the CHOSEN INTERFACE
          // language: English mode shows "Morning Prayer"
          // on top and "صلاة باكر" underneath - Arabic mode
          // shows the opposite.
          // --------------------------------------------------
          Consumer(
            builder: (context, ref, _) {
              final uiIsArabic = ref
                  .watch(preferencesProvider)
                  .interfaceLanguage
                  .isRtl;

              final primaryTitle = uiIsArabic
                  ? widget.arabicTitle
                  : widget.title;

              final secondaryTitle = uiIsArabic
                  ? widget.title
                  : widget.arabicTitle;

              return Column(
                crossAxisAlignment: _isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryTitle,
                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Directionality(
                    textDirection: uiIsArabic
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    child: Text(
                      secondaryTitle,
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Drawer Main Section
  // ============================================================

  Widget _buildDrawerSection(
    BuildContext context, {
    required AgpeyaHour hour,
    required _AgpeyaDrawerSection section,
  }) {
    final theme = Theme.of(context);

    final isActive = _activeSection == section.id;

    final isExpanded = _expandedSections.contains(section.id);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            tileColor: isActive ? theme.colorScheme.primaryContainer : null,

            leading: Icon(
              section.icon,
              color: isActive ? theme.colorScheme.primary : null,
            ),

            title: Text(
              section.title,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              ),
            ),

            subtitle: Text(
              section.subtitle,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            ),

            trailing: section.hasChildren
                ? IconButton(
                    tooltip: isExpanded ? _collapseText : _expandText,
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                    ),
                    onPressed: () {
                      _toggleSection(section.id);
                    },
                  )
                : Icon(
                    isActive ? Icons.check_circle : Icons.chevron_right,
                    color: isActive ? theme.colorScheme.primary : null,
                  ),

            onTap: () {
              _scrollToSection(section);
            },
          ),
        ),

        if (section.id == 'psalms' && isExpanded)
          _buildPsalmChildren(context, hour),

        if (section.id == 'litanies' && isExpanded)
          _buildLitanyChildren(context, hour),

        if (section.id == 'chapters' && isExpanded)
          _buildChapterChildren(context, hour),
      ],
    );
  }

  // ============================================================
  // Chapter Children
  // ============================================================

  Widget _buildChapterChildren(BuildContext context, AgpeyaHour hour) {
    return Column(
      children: List.generate(hour.chapters.length, (index) {
        final chapter = hour.chapters[index];

        return Padding(
          padding: const EdgeInsets.only(left: 30, right: 10),
          child: ListTile(
            dense: true,

            leading: Icon(
              Icons.format_list_numbered_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),

            title: Text(
              chapter.title.isNotEmpty
                  ? chapter.title
                  : '$_chaptersText ${index + 1}',
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            trailing: const Icon(Icons.chevron_right, size: 20),

            onTap: () {
              _scrollToSubItem(
                key: _getChapterKey(index),
                activeId: 'chapter_$index',
              );
            },
          ),
        );
      }),
    );
  }

  // ============================================================
  // Psalm Children
  // ============================================================

  Widget _buildPsalmChildren(BuildContext context, AgpeyaHour hour) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(hour.psalms.length, (index) {
        final psalm = hour.psalms[index];

        final key = _getPsalmKey(psalm, index);

        return Padding(
          padding: const EdgeInsets.only(left: 30, right: 10),
          child: ListTile(
            dense: true,

            leading: Icon(
              Icons.music_note_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),

            title: Text(
              psalm.title.isNotEmpty ? psalm.title : psalm.reference,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            subtitle: psalm.reference.isNotEmpty
                ? Text(
                    psalm.reference,
                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  )
                : null,

            trailing: const Icon(Icons.chevron_right, size: 20),

            onTap: () {
              _scrollToSubItem(key: key, activeId: 'psalm_$index');
            },
          ),
        );
      }),
    );
  }

  // ============================================================
  // Litany Children
  // ============================================================

  Widget _buildLitanyChildren(BuildContext context, AgpeyaHour hour) {
    final theme = Theme.of(context);

    final litanies = hour.litanies?.content ?? [];

    return Column(
      children: List.generate(litanies.length, (index) {
        final litany = litanies[index];

        final key = _getLitanyKey(litany, index);

        return Padding(
          padding: const EdgeInsets.only(left: 30, right: 10),
          child: ListTile(
            dense: true,

            leading: Icon(
              Icons.pan_tool_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),

            title: Text(
              '$_litanyText ${index + 1}',
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            subtitle: Text(
              _shortenText(litany),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            ),

            trailing: const Icon(Icons.chevron_right, size: 20),

            onTap: () {
              _scrollToSubItem(key: key, activeId: 'litany_$index');
            },
          ),
        );
      }),
    );
  }

  // ============================================================
  // Shorten Long Text
  // ============================================================

  String _shortenText(String text) {
    final cleanText = text.replaceAll('\n', ' ').trim();

    if (cleanText.length <= 45) {
      return cleanText;
    }

    return '${cleanText.substring(0, 45)}...';
  }

  // ============================================================
  // PRESENTATION MODE SLIDES (landscape)
  //
  // Flattens the whole hour into a list of full-screen
  // slides - one verse / paragraph per slide - so the prayer
  // can be presented verse by verse when the phone is held
  // in landscape.
  // ============================================================

  List<PresentationSlide> _buildPresentationSlides(AgpeyaHour hour) {
    final slides = <PresentationSlide>[];

    void addParagraph(String? text) {
      final clean = text?.replaceAll('\n', ' ').trim();
      if (clean != null && clean.isNotEmpty) {
        slides.add(PresentationSlide(text: clean));
      }
    }

    void addSection(AgpeyaSection? section) {
      if (section == null) return;

      final title = section.title?.trim() ?? '';

      if (title.isNotEmpty && section.content.isNotEmpty) {
        slides.add(PresentationSlide(text: title));
      }

      for (final paragraph in section.content) {
        addParagraph(paragraph);
      }
    }

    void addContentSection(AgpeyaContentSection? section) {
      if (section == null) return;

      final title = section.title?.trim() ?? '';

      if (title.isNotEmpty && section.content.isNotEmpty) {
        slides.add(PresentationSlide(text: title));
      }

      for (final paragraph in section.content) {
        addParagraph(paragraph);
      }
    }

    void addPsalms(List<AgpeyaPsalm> psalms) {
      for (final psalm in psalms) {
        final reference = psalm.reference.trim();

        for (final verse in psalm.verses) {
          slides.add(
            PresentationSlide(
              text: verse.text.replaceAll('\n', ' '),
              badge: verse.number?.toString(),
              label: reference.isEmpty ? null : reference,
            ),
          );
        }
      }
    }

    void addGospel(AgpeyaGospel? gospel) {
      if (gospel == null) return;

      addParagraph(gospel.rubric);

      final reference = gospel.reference.trim();

      for (final verse in gospel.verses) {
        slides.add(
          PresentationSlide(
            text: verse.text.replaceAll('\n', ' '),
            badge: verse.number?.toString(),
            label: reference.isEmpty ? null : reference,
          ),
        );
      }
    }

    // ---------- ORDER OF THE HOUR ----------

    addParagraph(hour.introduction);

    addSection(hour.opening);
    addSection(hour.hourIntro);
    addSection(hour.comeLetUsWorship);
    addSection(hour.thanksgiving);

    if (hour.introductoryPsalm != null) {
      addPsalms([hour.introductoryPsalm!]);
    }

    addParagraph(hour.psalmsIntro);
    addPsalms(hour.psalms);

    addGospel(hour.gospel);

    addContentSection(hour.litanies);
    addSection(hour.lordsPrayer);

    // Midnight prayer watches.
    for (final watch in hour.watches) {
      if (watch.name.trim().isNotEmpty) {
        slides.add(PresentationSlide(text: watch.name));
      }

      addParagraph(watch.theme);
      addParagraph(watch.psalmsIntro);
      addPsalms(watch.psalms);
      addGospel(watch.gospel);
      addContentSection(watch.litanies);
      addContentSection(watch.closing);
    }

    // Fallback chapter format (several Arabic files).
    for (final chapter in hour.chapters) {
      final title = chapter.title.trim();

      if (title.isNotEmpty) {
        slides.add(PresentationSlide(text: title));
      }

      for (final verse in chapter.verses) {
        slides.add(
          PresentationSlide(
            text: verse.text.replaceAll('\n', ' '),
            badge: verse.number?.toString(),
          ),
        );
      }
    }

    addContentSection(hour.closing);

    for (final section in hour.additionalSections) {
      addContentSection(section);
    }

    return slides;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    /*
     * The Scaffold itself stays LTR.
     *
     * This guarantees that endDrawer remains on the RIGHT.
     *
     * Arabic direction is applied to the prayer content
     * and drawer contents separately.
     */

    // ========================================================
    // PRESENTATION MODE (landscape)
    //
    // When the phone is in LANDSCAPE and the user has not
    // disabled it, the loaded prayer turns into a
    // verse-by-verse black-screen presentation.
    // ========================================================

    return Consumer(
      builder: (context, ref, _) {
        final preferences = ref.watch(preferencesProvider);

        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        final cachedHour = _loadedHour;

        final presenting =
            preferences.presentationModeEnabled &&
            isLandscape &&
            cachedHour != null &&
            !_presentationDismissed;

        return Directionality(
          textDirection: TextDirection.ltr,

          child: Scaffold(
            // ======================================================
            // ONE-SIDE SWIPE (right edge opens the drawer)
            // Disabled while presenting (swipes move verses).
            // ======================================================

            drawerEdgeDragWidth: presenting ? 0 : 150,

            endDrawerEnableOpenDragGesture: !presenting,

            // ======================================================
            // APP BAR (hidden in presentation mode)
            // ======================================================
            appBar: presenting
                ? null
                : AppBar(
                    // Bilingual format driven by the chosen
                    // interface language (like the Bible).
                    title: Consumer(
                      builder: (context, ref, _) {
                        final uiIsArabic = ref
                            .watch(preferencesProvider)
                            .interfaceLanguage
                            .isRtl;

                        return BilingualText(
                          english: widget.title,
                          arabic: widget.arabicTitle,
                          primaryIsArabic: uiIsArabic,
                          spacing: 1,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        );
                      },
                    ),

                    actions: [
                      // ------------------------------------------
                      // BOOKMARK BUTTON (Saved page)
                      //
                      // Toggles the CURRENT prayer in the
                      // Saved/Bookmarks list (persisted by
                      // SharedPreferences, shown on the Saved
                      // screen). Consumer because this page is a
                      // plain StatefulWidget.
                      // ------------------------------------------
                      Consumer(
                        builder: (context, ref, _) {
                          final isArabic = ref
                              .watch(preferencesProvider)
                              .interfaceLanguage
                              .isRtl;

                          final savedId = 'agpeya:${widget.prayerId}';

                          final isSaved = ref.watch(
                            savedItemsProvider.select(
                              (items) => items
                                  .any((item) => item.id == savedId),
                            ),
                          );

                          return IconButton(
                            tooltip: isArabic
                                ? (isSaved
                                    ? 'إزالة من المحفوظات'
                                    : 'حفظ في المحفوظات')
                                : (isSaved
                                    ? 'Remove from Saved'
                                    : 'Save to Saved'),
                            icon: Icon(
                              isSaved
                                  ? Icons.collections_bookmark
                                  : Icons
                                      .collections_bookmark_outlined,
                            ),
                            onPressed: () {
                              ref
                                  .read(savedItemsProvider.notifier)
                                  .toggle(
                                    SavedItem(
                                      id: savedId,
                                      kind: SavedContentKind.agpeya,
                                      title: isArabic
                                          ? widget.arabicTitle
                                          : widget.title,
                                      subtitle: isArabic
                                          ? 'الأجبية'
                                          : 'Agpeya',
                                      routePath:
                                          '/agpeya/${widget.prayerId}',
                                    ),
                                  );
                            },
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return IconButton(
                            tooltip: _prayerSectionsText,
                            icon: const Icon(Icons.menu_book_outlined),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                          );
                        },
                      ),
                    ],
                  ),

            // ======================================================
            // RIGHT DRAWER
            // ======================================================
            endDrawer: presenting
                ? null
                : FutureBuilder<AgpeyaHour>(
                    future: _hourFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Drawer(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return _buildSectionsDrawer(context, snapshot.data!);
                    },
                  ),

            // ======================================================
            // BODY
            // ======================================================
            body: presenting
                ? PresentationReader(
                    slides: _buildPresentationSlides(cachedHour),
                    headerTitle: cachedHour.name,
                    isRtl: _isArabic,

                    // Resume where the user was instead
                    // of jumping back to slide 1.
                    startIndex: _lastPresentationIndex,

                    onPageChanged: (page) =>
                        _lastPresentationIndex = page,

                    exitTooltip: _isArabic
                        ? 'خروج من وضع العرض'
                        : 'Exit presentation',

                    onExit: () {
                      // LOCAL dismissal only: rotating
                      // back to portrait re-arms it. The
                      // master switch lives in settings.
                      setState(() {
                        _presentationDismissed = true;
                      });
                    },
                  )
                : FutureBuilder<AgpeyaHour>(
                    future: _hourFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Directionality(
                          textDirection: _textDirection,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                '$_failedToLoadText\n\n'
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      final hour = snapshot.data;

                      if (hour == null) {
                        return Directionality(
                          textDirection: _textDirection,
                          child: Center(child: Text(_prayerNotFoundText)),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_activeSection == null) {
                          _updateActiveSection();
                        }
                      });

                      return Directionality(
                        textDirection: _textDirection,
                        child: _buildPrayer(context, hour),
                      );
                    },
                  ),
          ),
        );

        // Close the presentation-aware Consumer.
      },
    );
  }

  // ============================================================
  // PRAYER CONTENT
  // ============================================================

  Widget _buildPrayer(BuildContext context, AgpeyaHour hour) {
    final theme = Theme.of(context);

    // FLOATING TEXT ZOOM: the zoom button floats above the
    // scrollable prayer content and adjusts the shared reading
    // font scale live (see reading_settings_drawer / preferences).
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,

          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Text(
            hour.name,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // ======================================================
          // English mode:
          // show Arabic prayer title underneath.
          // Arabic mode:
          // JSON already contains Arabic name.
          // ======================================================
          if (!_isArabic) ...[
            const SizedBox(height: 4),

            Text(
              widget.arabicTitle,
              textAlign: TextAlign.left,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (hour.englishName != null && _isArabic == false) ...[
            const SizedBox(height: 4),

            Text(
              hour.englishName!,
              textAlign: TextAlign.left,
              style: theme.textTheme.bodyMedium,
            ),
          ],

          if (hour.traditionalTime != null) ...[
            const SizedBox(height: 6),

            Text(
              hour.traditionalTime!,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 20),

          // ======================================================
          // INTRODUCTION
          // ======================================================
          if (hour.introduction != null)
            Container(
              key: _introductionKey,
              child: _sectionCard(
                context,
                title: _introductionText,
                paragraphs: [hour.introduction!],
              ),
            ),

          // ======================================================
          // OPENING
          // ======================================================
          if (hour.opening != null)
            Container(
              key: _openingKey,
              child: _buildSection(context, hour.opening!),
            ),

          // ======================================================
          // HOUR INTRO
          // ======================================================
          if (hour.hourIntro != null)
            Container(
              key: _hourIntroKey,
              child: _buildSection(context, hour.hourIntro!),
            ),

          // ======================================================
          // COME LET US WORSHIP
          // ======================================================
          if (hour.comeLetUsWorship != null)
            Container(
              key: _comeLetUsWorshipKey,
              child: _buildSection(context, hour.comeLetUsWorship!),
            ),

          // ======================================================
          // THANKSGIVING
          // ======================================================
          if (hour.thanksgiving != null)
            Container(
              key: _thanksgivingKey,
              child: _buildSection(context, hour.thanksgiving!),
            ),

          // ======================================================
          // PSALM 50
          // ======================================================
          if (hour.introductoryPsalm != null)
            Container(
              key: _introductoryPsalmKey,
              child: _buildPsalm(context, hour.introductoryPsalm!),
            ),

          // ======================================================
          // WATCHES (Midnight prayer)
          // ======================================================
          if (hour.watches.isNotEmpty)
            Container(
              key: _watchesKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < hour.watches.length; i++)
                    Container(
                      key: _getWatchKey(hour.watches[i], i),
                      child: _buildWatch(context, hour.watches[i]),
                    ),
                ],
              ),
            ),

          // ======================================================
          // PSALMS
          // ======================================================
          if (hour.psalms.isNotEmpty)
            Container(
              key: _psalmsKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hour.psalmsIntro != null)
                    _sectionCard(
                      context,
                      title: _psalmsText,
                      paragraphs: [hour.psalmsIntro!],
                    ),

                  ...List.generate(hour.psalms.length, (index) {
                    final psalm = hour.psalms[index];

                    return Container(
                      key: _getPsalmKey(psalm, index),
                      child: _buildPsalm(context, psalm),
                    );
                  }),
                ],
              ),
            ),

          // ======================================================
          // GOSPEL
          // ======================================================
          if (hour.gospel != null)
            Container(
              key: _gospelKey,
              child: _buildGospel(context, hour.gospel!),
            ),

          // ======================================================
          // LITANIES
          // ======================================================
          if (hour.litanies != null)
            Container(
              key: _litaniesKey,
              child: _buildLitanies(context, hour.litanies!),
            ),

          // ======================================================
          // LORD'S PRAYER
          // ======================================================
          if (hour.lordsPrayer != null)
            Container(
              key: _lordsPrayerKey,
              child: _buildSection(context, hour.lordsPrayer!),
            ),

          // ======================================================
          // CLOSING
          // ======================================================
          if (hour.closing != null)
            Container(
              key: _closingKey,
              child: _buildContentSection(context, hour.closing!),
            ),

          // ======================================================
          // ADDITIONAL SECTIONS
          // ======================================================
          if (hour.additionalSections.isNotEmpty)
            Container(
              key: _additionalSectionsKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: hour.additionalSections
                    .map((section) => _buildContentSection(context, section))
                    .toList(),
              ),
            ),

          // ======================================================
          // CHAPTERS (fallback format in some Arabic files)
          // ======================================================
          if (hour.chapters.isNotEmpty)
            Container(
              key: _chaptersKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < hour.chapters.length; i++)
                    Container(
                      key: _getChapterKey(i),
                      child: _buildChapter(context, hour.chapters[i]),
                    ),
                ],
              ),
            ),
        ],
      ),
        ),
        const Positioned(
          right: 16,
          bottom: 24,
          child: FloatingTextZoom(),
        ),
      ],
    );
  }

  // ============================================================
  // WATCH (Midnight prayer)
  // ============================================================

  Widget _buildWatch(BuildContext context, AgpeyaWatch watch) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        // Watch header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                watch.name,
                textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              if (watch.theme != null && watch.theme!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  watch.theme!,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (watch.psalmsIntro != null && watch.psalmsIntro!.isNotEmpty)
          _sectionCard(
            context,
            title: _psalmsText,
            paragraphs: [watch.psalmsIntro!],
          ),

        ...watch.psalms.map((psalm) => _buildPsalm(context, psalm)),

        if (watch.gospel != null) _buildGospel(context, watch.gospel!),

        if (watch.litanies != null) _buildLitanies(context, watch.litanies!),

        if (watch.closing != null)
          _buildContentSection(context, watch.closing!),
      ],
    );
  }

  // ============================================================
  // CHAPTER (fallback format)
  // ============================================================

  Widget _buildChapter(BuildContext context, AgpeyaChapter chapter) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              chapter.title,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            ...chapter.verses.map(
              (verse) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${verse.number != null ? '${verse.number}. ' : ''}'
                  '${verse.text}',
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection(BuildContext context, AgpeyaSection section) {
    return _sectionCard(
      context,
      title: section.title ?? '',
      paragraphs: section.content,
    );
  }

  // ============================================================
  // CONTENT SECTION
  // ============================================================

  Widget _buildContentSection(
    BuildContext context,
    AgpeyaContentSection section,
  ) {
    return _sectionCard(
      context,
      title: section.title ?? '',
      paragraphs: section.content,
    );
  }

  // ============================================================
  // LITANIES CONTENT
  // ============================================================

  Widget _buildLitanies(BuildContext context, AgpeyaContentSection section) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            if (section.title != null && section.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  section.title!,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ...List.generate(section.content.length, (index) {
              final litany = section.content[index];

              return Container(
                key: _getLitanyKey(litany, index),

                margin: const EdgeInsets.only(bottom: 14),

                child: Text(
                  litany,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PSALM
  // ============================================================

  Widget _buildPsalm(BuildContext context, AgpeyaPsalm psalm) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text(
              psalm.title,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            if (psalm.reference.isNotEmpty) ...[
              const SizedBox(height: 4),

              Text(
                psalm.reference,
                textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 14),

            ...psalm.verses.map(
              (verse) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${verse.number != null ? '${verse.number}. ' : ''}'
                  '${verse.text}',

                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,

                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GOSPEL
  // ============================================================

  Widget _buildGospel(BuildContext context, AgpeyaGospel gospel) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text(
              _gospelText,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              gospel.reference,
              textAlign: _isArabic ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (gospel.rubric != null) ...[
              const SizedBox(height: 16),

              Text(
                gospel.rubric!,
                textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),

            ...gospel.verses.map(
              (verse) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${verse.number != null ? '${verse.number}. ' : ''}'
                  '${verse.text}',

                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,

                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC SECTION CARD
  // ============================================================

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required List<String> paragraphs,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  title,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ...paragraphs.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  text,
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DRAWER SECTION MODEL
// ================================================================

class _AgpeyaDrawerSection {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final GlobalKey key;
  final bool hasChildren;

  const _AgpeyaDrawerSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.key,
    this.hasChildren = false,
  });
}
