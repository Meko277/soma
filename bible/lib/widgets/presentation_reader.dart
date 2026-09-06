import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ================================================================
// PRESENTATION READER (وضع العرض التقديمي)
//
// A distraction-free, black-background, ONE-VERSE-PER-SCREEN
// reader used when a reading is open and the phone is held in
// LANDSCAPE:
//
//   - Swipe left / right  -> next / previous verse
//   - Tap right / left    -> next / previous verse
//     (mirrored automatically for Arabic RTL content)
//   - Arrow keys          -> next / previous verse (desktop)
//
// The system status/navigation bars are hidden while active
// (immersive sticky) and restored on exit.
// ================================================================

/// One full-screen slide.
class PresentationSlide {
  const PresentationSlide({required this.text, this.badge, this.label});

  /// Main text shown large in the middle of the screen.
  final String text;

  /// Small chip above the text, e.g. verse number '١٤'.
  final String? badge;

  /// Small caption under the text, e.g. psalm reference or
  /// section name ('المزمور الأول' / 'إنجيل باكر').
  final String? label;
}

class PresentationReader extends StatefulWidget {
  const PresentationReader({
    super.key,
    required this.slides,
    required this.headerTitle,
    required this.isRtl,
    this.onExit,
    this.startIndex = 0,
    this.onPageChanged,
    this.exitTooltip = 'Exit',
  });

  /// Slides (one per verse / paragraph).
  final List<PresentationSlide> slides;

  /// Passage title shown in the subtle top bar
  /// (e.g. 'مزمور ٢٣' or 'يوحنا ٣').
  final String headerTitle;

  /// Whether the CONTENT language is Arabic - flips swipe /
  /// tap direction and alignment.
  final bool isRtl;

  /// Called when the user taps the exit button. The parent
  /// usually turns the presentation-mode preference OFF so
  /// the normal reading view comes back immediately.
  final VoidCallback? onExit;

  /// Called whenever the visible slide changes, so the
  /// parent can remember the position across rotations
  /// (landscape <-> portrait) instead of restarting
  /// from verse 1 every time.
  final ValueChanged<int>? onPageChanged;

  /// Localized label for the exit button (tooltip /
  /// semantics). Defaults to 'Exit'.
  final String exitTooltip;

  /// Initial page index (kept when rotating mid-chapter).
  final int startIndex;

  @override
  State<PresentationReader> createState() => _PresentationReaderState();
}

class _PresentationReaderState extends State<PresentationReader> {
  late final PageController _controller = PageController(
    initialPage: widget.startIndex.clamp(
      0,
      widget.slides.isEmpty ? 0 : widget.slides.length - 1,
    ),
  );

  int _index = 0;

  // ============================================================
  // IMMERSIVE MODE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _index = _controller.initialPage;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.dispose();

    // Restore normal system UI.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _goNext() {
    if (_index >= widget.slides.length - 1) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goPrevious() {
    if (_index <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  // Right arrow = forward for LTR, backward for RTL.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.isRtl ? _goPrevious() : _goNext();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.isRtl ? _goNext() : _goPrevious();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ============================================================
  // TAP ZONES
  //
  // LTR : right half = next, left half = previous
  // RTL : mirrored
  // ============================================================

  void _handleTapUp(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;

    final isRightSide = details.globalPosition.dx > width / 2;

    final forwardTap = widget.isRtl ? !isRightSide : isRightSide;

    forwardTap ? _goNext() : _goPrevious();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;

    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _handleTapUp,
        child: _buildBody(slides),
      ),
    );
  }

  Widget _buildBody(List<PresentationSlide> slides) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(slides),
            Expanded(child: _buildPages(slides)),
            _buildProgressBar(slides),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR (exit + title + counter)
  // ============================================================

  Widget _buildTopBar(List<PresentationSlide> slides) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: widget.exitTooltip,
            icon: const Icon(
              Icons.close_fullscreen_outlined,
              color: Colors.white70,
            ),
            onPressed: widget.onExit,
          ),

          Expanded(
            child: Text(
              widget.headerTitle,
              textAlign: widget.isRtl ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '${(_index + 1).clamp(1, slides.length)} / ${slides.length}',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VERSE PAGES
  // ============================================================

  Widget _buildPages(List<PresentationSlide> slides) {
    return PageView.builder(
      controller: _controller,
      reverse: widget.isRtl,
      itemCount: slides.length,
      onPageChanged: (page) {
        setState(() => _index = page);
      },
      itemBuilder: (context, i) {
        final slide = slides[i];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Center(
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: widget.isRtl
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (slide.badge != null) _buildBadge(slide.badge!),

                    if (slide.badge != null) const SizedBox(height: 22),

                    Text(
                      slide.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontSize: 26,
                        height: 1.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (slide.label != null && slide.label!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          slide.label!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amberAccent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        badge,
        style: const TextStyle(
          color: Color(0xFFFFD97A),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _buildProgressBar(List<PresentationSlide> slides) {
    return LinearProgressIndicator(
      value: (_index + 1) / slides.length,
      minHeight: 2,
      backgroundColor: Colors.white10,
      color: Colors.amberAccent.withValues(alpha: 0.7),
    );
  }
}
