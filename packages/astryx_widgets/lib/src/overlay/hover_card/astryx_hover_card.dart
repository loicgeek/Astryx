import 'dart:async';

import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.hovercard}
/// Shows rich [card] content when the pointer hovers [child] (after
/// [openDelay]). Unlike a tooltip, the card stays open while the pointer is over
/// it, so it can hold interactive content. Pointer-only (a no-op on touch).
/// {@endtemplate}
class AstryxHoverCard extends StatefulWidget {
  const AstryxHoverCard({
    super.key,
    required this.child,
    required this.card,
    this.openDelay = const Duration(milliseconds: 350),
    this.maxWidth = 300,
  });

  final Widget child;
  final Widget card;
  final Duration openDelay;
  final double maxWidth;

  @override
  State<AstryxHoverCard> createState() => _AstryxHoverCardState();
}

class _AstryxHoverCardState extends State<AstryxHoverCard> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  Timer? _openTimer;
  Timer? _closeTimer;

  void _scheduleOpen() {
    _closeTimer?.cancel();
    _openTimer ??= Timer(widget.openDelay, () {
      _openTimer = null;
      if (mounted) _portal.show();
    });
  }

  void _scheduleClose() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    // Grace period so the pointer can travel from trigger to card.
    _closeTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) _portal.hide();
    });
  }

  void _keepOpen() => _closeTimer?.cancel();

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _scheduleOpen(),
        onExit: (_) => _scheduleClose(),
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (context) => CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            offset: Offset(0, t.spacing.gapSm),
            child: Align(
              alignment: Alignment.topLeft,
              child: MouseRegion(
                onEnter: (_) => _keepOpen(),
                onExit: (_) => _scheduleClose(),
                child: AstryxTextDefaults(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: widget.maxWidth),
                    padding: EdgeInsets.all(t.spacing.insetMd),
                    decoration: BoxDecoration(
                      color: t.color.surfaceOverlay,
                      borderRadius: t.shape.radiusOverlay,
                      boxShadow: t.elevation.overlay,
                      border: Border.all(color: t.color.borderDefault),
                    ),
                    child: widget.card,
                  ),
                ),
              ),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
