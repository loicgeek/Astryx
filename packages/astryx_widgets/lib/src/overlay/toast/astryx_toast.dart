import 'dart:async';

import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../feedback/badge/astryx_badge.dart' show AstryxTone;

// Active toast entries, bottom-up. Kept module-private; managed via
// [showAstryxToast].
final List<OverlayEntry> _active = [];

void _refresh() {
  for (final e in _active) {
    e.markNeedsBuild();
  }
}

/// Shows a transient toast anchored bottom-center. Stacks with any existing
/// toasts and auto-dismisses after [duration]. Announced via a live region.
void showAstryxToast(
  BuildContext context, {
  required String message,
  AstryxTone tone = AstryxTone.neutral,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final tokens = AstryxTokens.of(context);
  final visible = ValueNotifier<bool>(true);

  late OverlayEntry entry;
  void remove() {
    if (_active.remove(entry)) {
      entry.remove();
      visible.dispose();
      _refresh();
    }
  }

  entry = OverlayEntry(
    builder: (context) => _ToastCard(
      message: message,
      tone: tone,
      tokens: tokens,
      index: _active.indexOf(entry),
      visible: visible,
      onGone: remove,
    ),
  );

  _active.add(entry);
  overlay.insert(entry);
  _refresh();
  Timer(duration, () => visible.value = false);
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.message,
    required this.tone,
    required this.tokens,
    required this.index,
    required this.visible,
    required this.onGone,
  });

  final String message;
  final AstryxTone tone;
  final AstryxTokens tokens;
  final int index;
  final ValueNotifier<bool> visible;
  final VoidCallback onGone;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..forward();

  @override
  void initState() {
    super.initState();
    widget.visible.addListener(_onVisible);
    _c.addStatusListener((s) {
      if (s == AnimationStatus.dismissed) widget.onGone();
    });
  }

  void _onVisible() {
    if (!widget.visible.value) _c.reverse();
  }

  @override
  void dispose() {
    widget.visible.removeListener(_onVisible);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final accent = switch (widget.tone) {
      AstryxTone.neutral => t.color.textDefault,
      AstryxTone.accent => t.color.accentDefault,
      AstryxTone.success => t.color.success,
      AstryxTone.danger => t.color.danger,
      AstryxTone.warning => t.color.warning,
    };

    final curved = CurvedAnimation(parent: _c, curve: t.motion.curveDecelerate);
    return Positioned(
      left: 0,
      right: 0,
      bottom: t.spacing.insetLg + widget.index * 56.0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(curved),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: t.spacing.insetLg),
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.insetMd,
                    vertical: t.spacing.insetSm,
                  ),
                  decoration: BoxDecoration(
                    color: t.color.surfaceOverlay,
                    borderRadius: t.shape.radiusControl,
                    boxShadow: t.elevation.overlay,
                    border: Border(left: BorderSide(color: accent, width: 3)),
                  ),
                  child: Text(
                    widget.message,
                    style: t.typography.body.copyWith(color: t.color.textDefault),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
