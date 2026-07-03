import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.tooltip}
/// A small contextual label shown above [child]. Appears on hover (desktop/web)
/// or long-press (touch) — hover is never the only affordance. The message is
/// also attached to the child's semantics so screen readers announce it.
/// {@endtemplate}
class AstryxTooltip extends StatefulWidget {
  const AstryxTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<AstryxTooltip> createState() => _AstryxTooltipState();
}

class _AstryxTooltipState extends State<AstryxTooltip> {
  final _controller = OverlayPortalController();
  final _link = LayerLink();

  void _show() => _controller.show();
  void _hide() => _controller.hide();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      tooltip: widget.message,
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: GestureDetector(
            onLongPress: _show,
            onLongPressUp: _hide,
            child: OverlayPortal(
              controller: _controller,
              overlayChildBuilder: (context) => Positioned(
                child: CompositedTransformFollower(
                  link: _link,
                  targetAnchor: Alignment.topCenter,
                  followerAnchor: Alignment.bottomCenter,
                  offset: const Offset(0, -6),
                  child: _Bubble(message: widget.message, tokens: t),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.tokens});
  final String message;
  final AstryxTokens tokens;

  @override
  Widget build(BuildContext context) {
    // Inverse surface for contrast against the page.
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.insetSm,
          vertical: tokens.spacing.insetXs,
        ),
        decoration: BoxDecoration(
          color: tokens.color.textDefault,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          boxShadow: tokens.elevation.overlay,
        ),
        child: ExcludeSemantics(
          child: Text(
            message,
            style: tokens.typography.label.copyWith(color: tokens.color.surfaceDefault),
          ),
        ),
      ),
    );
  }
}
