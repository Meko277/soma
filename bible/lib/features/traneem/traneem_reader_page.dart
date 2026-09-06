import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/saved/saved_item.dart';
import '../../core/saved/saved_items_provider.dart';
import '../../core/sync/sync_holder.dart';
import '../../core/traneem/traneem_content_providers.dart';
import '../../core/traneem/traneem_models.dart';
import '../../widgets/bilingual_text.dart';
import '../../widgets/floating_text_zoom.dart';

// ================================================================
// TRANEEM READER PAGE (قراءة الترنيم)
//
// A comfortable, text-only hymn reader. Shows the title bilingually,
// then the hymn's stanzas with generous line height and spacing.

// Includes the reusable floating text zoom (text size) and a
// bookmark/save button.

// ================================================================

class TraneemReaderPage extends ConsumerStatefulWidget {
  const TraneemReaderPage({
    super.key,
    required this.hymnId,
    required this.language,
  });

  final String hymnId;

  final String language;

  @override
  ConsumerState<TraneemReaderPage> createState() =>
      _TraneemReaderPageState();
}

class _TraneemReaderPageState
    extends ConsumerState<TraneemReaderPage> {
  TraneemHymnMeta? _meta;

  late Future<TraneemHymn> _hymnFuture;

  /// Reload when Firestore sync delivers newer content so the page
  /// reflects admin edits without a restart.
  StreamSubscription<void>? _syncSub;

  @override
  void initState() {
    super.initState();

    _meta = ref
        .read(traneemContentRepositoryProvider)
        .byId(widget.hymnId);

    _startLoading();

    // Listen for Firestore content updates and reload this hymn.
    final sync = SyncHolder.instance;
    _syncSub = sync?.traneemUpdates.listen((_) {
      if (!mounted) return;
      // Re-resolve the meta in case this hymn only exists in
      // Firestore (added by the admin) and arrived after this
      // page opened.
      final resolved = ref
          .read(traneemContentRepositoryProvider)
          .byId(widget.hymnId);
      setState(() {
        _meta = resolved;
        _startLoading();
      });
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    super.dispose();
  }

  void _startLoading() {
    final repository =
        ref.read(traneemContentRepositoryProvider);

    final meta = _meta;

    if (meta != null) {
      _hymnFuture = repository.loadHymn(
        meta.id,
        language: widget.language,
      );
    }
  }

  @override
  void didUpdateWidget(covariant TraneemReaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hymnId != widget.hymnId ||
        oldWidget.language != widget.language) {
      _meta = ref
          .read(traneemContentRepositoryProvider)
          .byId(widget.hymnId);

      _startLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);

    final isArabic =
        preferences.interfaceLanguage.isRtl;

    final strings = AppStrings(preferences.interfaceLanguage);

    final theme = Theme.of(context);
// ------------------------------------------------------------
    // HYMN NOT FOUND
    // ------------------------------------------------------------

    final meta = _meta;

    if (meta == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.traneem)),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 18),
                Text(
                  strings.hymnNotFound,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/traneem'),
                  child: Text(strings.backToTraneem),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) {
            final uiIsArabic = ref
                .watch(preferencesProvider)
                .interfaceLanguage
                .isRtl;

            return BilingualText(
              english: meta.title,
              arabic: meta.arabicTitle,
              primaryIsArabic: uiIsArabic,
              spacing: 1,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          // ----------------------------------------------
          // SAVE / BOOKMARK
          // ----------------------------------------------
          Builder(
            builder: (context) => _buildSaveButton(),
          ),
        ],
      ),
// ============================================================
      // BODY
      // ============================================================
      body: FutureBuilder<TraneemHymn>(
        future: _hymnFuture,

        builder: (context, snapshot) {
          // ----------------------------------------------
          // LOADING
          // ----------------------------------------------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ----------------------------------------------
          // ERROR / NOT AVAILABLE
          // ----------------------------------------------
          if (snapshot.hasError || snapshot.data == null) {
            return Directionality(
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,

              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 56),
                      const SizedBox(height: 18),
                      Text(
                        strings.hymnNotAvailable,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${snapshot.error ?? ''}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // ----------------------------------------------
          // STACK: lyrics + floating text zoom
          // ----------------------------------------------
          final hymn = snapshot.data!;

          return Stack(
            children: [
              Directionality(
                textDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,

                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    56,
                  ),
                  child: _buildHymn(context, hymn),
                ),
              ),

              const Positioned(
                right: 14,
                bottom: 24,
                child: FloatingTextZoom(),
              ),
            ],
          );
        },
      ),
    );
  }
// ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    final meta = _meta;

    final savedId = meta == null ? '' : 'traneem:${meta.id}';

    // Scoped watch: rebuilds ONLY this button when the hymn's
    // saved state flips (not the whole reader).
    final isSaved = meta != null &&
        ref.watch(
          savedItemsProvider.select(
            (items) => items.any((item) => item.id == savedId),
          ),
        );

    final notifier = ref.read(savedItemsProvider.notifier);

    final isArabic =
        ref.watch(preferencesProvider).interfaceLanguage.isRtl;

    return IconButton(
      tooltip: isArabic
          ? (isSaved ? 'تم الحفظ' : 'حفظ')
          : (isSaved ? 'Saved' : 'Save'),
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
      ),
      onPressed: meta == null
          ? null
          : () {
              notifier.toggle(_savedItemFor(meta));
            },
    );
  }

  SavedItem _savedItemFor(TraneemHymnMeta meta) {
    // Called from event handlers - read, never watch.
    final isArabic =
        ref.read(preferencesProvider).interfaceLanguage.isRtl;

    return SavedItem(
      id: 'traneem:${meta.id}',
      kind: SavedContentKind.traneem,
      title: isArabic ? meta.arabicTitle : meta.title,
      subtitle:
          isArabic
              ? 'ترنيم • ${meta.categoryAr ?? ''}'
              : 'Hymn • ${meta.category ?? ''}',
      routePath: '/traneem/${meta.id}',
    );
  }
// ============================================================
  // HYMN LYRICS
  // ============================================================

  Widget _buildHymn(BuildContext context, TraneemHymn hymn) {
    final theme = Theme.of(context);

    final isArabic = hymn.language == 'ar';

    final children = <Widget>[
      // Title (bilingual, primary = content language).
      BilingualText(
        english: hymn.title,
        arabic: hymn.arabicTitle,
        primaryIsArabic: isArabic,
        spacing: 2,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
    ];

    for (final stanza in hymn.stanzas) {
      children.add(_buildStanza(context, stanza));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildStanza(BuildContext context, TraneemStanza stanza) {
    final theme = Theme.of(context);

    final lines = <Widget>[];

    if (stanza.title != null && stanza.title!.isNotEmpty) {
      lines.add(
        Text(
          stanza.title!,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      lines.add(const SizedBox(height: 10));
    }

    // Comfortable reading: raised line height + spacing.
    for (final line in stanza.lines) {
      lines.add(
        Text(
          line,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.7,
            fontSize: 22,
          ),
        ),
      );
      lines.add(const SizedBox(height: 12));
    }

    lines.add(const SizedBox(height: 22));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }
}