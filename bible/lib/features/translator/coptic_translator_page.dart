import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../core/translator/translator_provider.dart';
import '../../core/translator/translator_service.dart';

// ================================================================
// COPTIC ⇄ ARABIC TRANSLATOR
//
// UI only - all translation work lives behind the clean service
// interface (translator_service.dart) exposed via translatorProvider:
//
//   - Type in Coptic (built-in COPTIC KEYBOARD) or Arabic.
//   - Exact phrase matches first, then word-by-word.
//   - Fully offline via the built-in lexicon; an optional online
//     gateway (configured with --dart-define) upgrades results when
//     the device has internet. Loading / error / no-connection
//     states are handled here, never crashing.
// ================================================================

/// Coptic keyboard rows.
const List<List<String>> _copticKeyboardRows = [
  ['ⲁ', 'ⲃ', 'ⲅ', 'ⲇ', 'ⲉ', 'ⲍ', 'ⲏ', 'ⲑ', 'ⲓ', 'ⲕ'],
  ['ⲗ', 'ⲙ', 'ⲛ', 'ⲝ', 'ⲟ', 'ⲡ', 'ⲣ', 'ⲥ', 'ⲧ', 'ⲩ'],
  ['ϥ', 'ⲭ', 'ⲯ', 'ⲱ', 'ϣ', 'ϩ', 'ϫ', 'ϭ'],
];

/// Debounce for translation requests so fast typing does not fire a
/// request per keystroke (matters when the online gateway is used).
const Duration _translateDebounce = Duration(milliseconds: 220);

class CopticTranslatorPage extends ConsumerStatefulWidget {
  const CopticTranslatorPage({super.key});

  @override
  ConsumerState<CopticTranslatorPage> createState() =>
      _CopticTranslatorPageState();
}

class _CopticTranslatorPageState
    extends ConsumerState<CopticTranslatorPage> {
  final TextEditingController _controller =
      TextEditingController();

  bool _copticToArabic = true;

  bool _showCopticKeyboard = true;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // TRANSLATION TRIGGER
  // ============================================================

  void _translate({bool immediate = false}) {
    _debounce?.cancel();

    if (immediate) {
      _runTranslation();
      return;
    }

    _debounce = Timer(_translateDebounce, _runTranslation);
  }

  void _runTranslation() {
    final from =
        _copticToArabic ? TCode.coptic : TCode.arabic;
    final to =
        _copticToArabic ? TCode.arabic : TCode.coptic;

    ref.read(translatorProvider.notifier).translate(
          _controller.text,
          from,
          to,
        );
  }

  void _clearResults() {
    _debounce?.cancel();
    ref.read(translatorProvider.notifier).clear();
  }

  void _switchDirection(bool copticToArabic) {
    setState(() {
      _copticToArabic = copticToArabic;
      _controller.clear();
    });
    _clearResults();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final strings = AppStrings(
      ref.watch(preferencesProvider).interfaceLanguage,
    );

    final translatorState = ref.watch(translatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.translator),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ----------------------------------------------
          // DIRECTION SWITCH
          // ----------------------------------------------

          SegmentedButton<bool>(
            segments: [
              const ButtonSegment(
                value: true,
                label: Text('Ⲙⲉⲧⲣⲉⲙ̀ⲛⲭⲏⲙⲓ → عربي'),
              ),
              ButtonSegment(
                value: false,
                label: const Text('عربي → Ⲙⲉⲧⲣⲉⲙ̀ⲛⲭⲏⲙⲓ'),
              ),
            ],
            selected: {_copticToArabic},
            onSelectionChanged: (selection) =>
                _switchDirection(selection.first),
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------
          // INPUT
          // ----------------------------------------------

          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            textAlign: _copticToArabic
                ? TextAlign.left
                : TextAlign.right,
            textDirection: _copticToArabic
                ? TextDirection.ltr
                : TextDirection.rtl,
            decoration: InputDecoration(
              hintText: _copticToArabic
                  ? strings.translateHintCoptic
                  : strings.translateHintArabic,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _clearResults();
                },
              ),
            ),
            onChanged: (_) => _translate(),
          ),

          const SizedBox(height: 10),

          // ----------------------------------------------
          // COPTIC KEYBOARD TOGGLE
          // ----------------------------------------------

          if (_copticToArabic)
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showCopticKeyboard =
                      !_showCopticKeyboard;
                });
              },
              icon: Icon(
                _showCopticKeyboard
                    ? Icons.keyboard_hide_outlined
                    : Icons.keyboard_outlined,
              ),
              label: Text(strings.copticKeyboard),
            ),

          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: (_copticToArabic && _showCopticKeyboard)
                ? _buildCopticKeyboard(theme, strings)
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // ----------------------------------------------
          // RESULTS (loading / error / empty / done)
          // ----------------------------------------------

          _buildResultsSection(
            theme,
            strings,
            translatorState,
          ),
        ],
      ),
    );
  }


  // ============================================================
  // RESULTS SECTION
  // ============================================================

  Widget _buildResultsSection(
    ThemeData theme,
    AppStrings strings,
    TranslatorState state,
  ) {
    // ----------------------------------------------------------
    // IDLE - gentle hint, no card.
    // ----------------------------------------------------------
    if (state.status == TranslatorStatus.idle) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                strings.translatorEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // LOADING - small inline indicator, never blocks typing.
    // ----------------------------------------------------------
    if (state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              strings.translatorLoading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // ERROR - no internet / endpoint unavailable. The offline
    // lexicon path can still answer, so offer a retry.
    // ----------------------------------------------------------
    if (state.status == TranslatorStatus.error) {
      return Card(
        elevation: 0,
        color:
            theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.translatorErrorNetwork,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () =>
                      _translate(immediate: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(strings.translatorRetry),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildDoneResults(theme, strings, state);
  }


  // ------------------------------------------------------------
  // DONE - exact match card or word-by-word list.
  // ------------------------------------------------------------

  Widget _buildDoneResults(
    ThemeData theme,
    AppStrings strings,
    TranslatorState state,
  ) {
    final result = state.result;

    if (result == null || result.isEmpty) {
      return const SizedBox.shrink();
    }

    final fromRemote = result.fromRemote ||
        result.sourceLabel == kTranslatorSourceOnline;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.translateResultTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Source icon: offline lexicon vs online gateway.
                Tooltip(
                  message: fromRemote
                      ? strings.translatorSourceOnline
                      : strings.translatorSourceOffline,
                  child: Icon(
                    fromRemote
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_off_outlined,
                    size: 16,
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (result.exactMatch != null)
              Directionality(
                textDirection: _copticToArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Text(
                  result.exactMatch!,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else
              ...result.words.map((pair) {
                final found = pair.$2.isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          pair.$1,
                          style: theme.textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          found
                              ? pair.$2
                              : strings
                                  .notInDictionary,
                          style: theme.textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: found
                                ? null
                                : theme.colorScheme
                                    .error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // COPTIC KEYBOARD WIDGET
  // ============================================================

  Widget _buildCopticKeyboard(
    ThemeData theme,
    AppStrings strings,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme
            .colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (final row in _copticKeyboardRows)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                for (final letter in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Material(
                        color:
                            theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(8),
                          onTap: () {
                            _insertLetter(letter);
                            HapticFeedback.selectionClick();
                          },
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 9,
                              ),
                              child: Text(
                                letter,
                                style: theme.textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: OutlinedButton.icon(
                    onPressed: () => _insertLetter(' '),
                    icon: const Icon(Icons.space_bar,
                        size: 18),
                    label: Text(strings.spaceKey),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: OutlinedButton.icon(
                    onPressed: _backspace,
                    icon: const Icon(
                      Icons.backspace_outlined,
                      size: 18,
                    ),
                    label: const Text(''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KEYBOARD INPUT HELPERS
  // ============================================================

  void _insertLetter(String letter) {
    final value = _controller.value;

    final selection = value.selection;

    var start =
        selection.start < 0 ? value.text.length : selection.start;

    var end = selection.end < 0 ? value.text.length : selection.end;

    if (start > value.text.length) {
      start = value.text.length;
    }

    if (end > value.text.length) {
      end = value.text.length;
    }

    final newText =
        value.text.replaceRange(start, end, letter);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + letter.length,
      ),
    );

    _translate();
  }

  void _backspace() {
    final value = _controller.value;

    if (value.text.isEmpty) {
      return;
    }

    final selection = value.selection;

    if (!selection.isCollapsed &&
        selection.start >= 0 &&
        selection.end >= 0) {
      final newText = value.text
          .replaceRange(selection.start, selection.end, '');

      _controller.value = TextEditingValue(
        text: newText,
        selection:
            TextSelection.collapsed(offset: selection.start),
      );

      _translate();

      return;
    }

    var pos =
        selection.start < 0 ? value.text.length : selection.start;

    if (pos > value.text.length) {
      pos = value.text.length;
    }

    if (pos == 0) {
      return;
    }

    final newText =
        value.text.replaceRange(pos - 1, pos, '');

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos - 1),
    );

    _translate();
  }
}

