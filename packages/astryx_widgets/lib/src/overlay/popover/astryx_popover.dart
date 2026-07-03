import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens/closes an [AstryxPopover] programmatically.
class AstryxPopoverController extends ChangeNotifier {
  final OverlayPortalController _portal = OverlayPortalController();

  bool get isOpen => _portal.isShowing;
  void open() {
    _portal.show();
    notifyListeners();
  }

  void close() {
    _portal.hide();
    notifyListeners();
  }

  void toggle() => isOpen ? close() : open();
}

/// {@template astryx.popover}
/// A floating panel anchored to [anchor]. Tapping the anchor toggles it; the
/// panel dismisses on outside tap or Escape. Content comes from [builder].
/// Provide a [controller] to drive it programmatically.
/// {@endtemplate}
class AstryxPopover extends StatefulWidget {
  const AstryxPopover({
    super.key,
    required this.anchor,
    required this.builder,
    this.controller,
    this.maxWidth = 320,
  });

  final Widget anchor;
  final WidgetBuilder builder;
  final AstryxPopoverController? controller;
  final double maxWidth;

  @override
  State<AstryxPopover> createState() => _AstryxPopoverState();
}

class _AstryxPopoverState extends State<AstryxPopover> {
  final _link = LayerLink();
  AstryxPopoverController? _internal;
  AstryxPopoverController get _controller =>
      widget.controller ?? (_internal ??= AstryxPopoverController());

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _controller._portal,
        overlayChildBuilder: (context) => _PopoverOverlay(
          link: _link,
          tokens: t,
          maxWidth: widget.maxWidth,
          onDismiss: _controller.close,
          child: widget.builder(context),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _controller.toggle,
          child: widget.anchor,
        ),
      ),
    );
  }
}

class _PopoverOverlay extends StatelessWidget {
  const _PopoverOverlay({
    required this.link,
    required this.tokens,
    required this.maxWidth,
    required this.onDismiss,
    required this.child,
  });

  final LayerLink link;
  final AstryxTokens tokens;
  final double maxWidth;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible full-screen barrier to catch outside taps.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, tokens.spacing.gapSm),
          child: Align(
            alignment: Alignment.topLeft,
            child: CallbackShortcuts(
              bindings: {const SingleActivator(LogicalKeyboardKey.escape): onDismiss},
              child: Focus(
                autofocus: true,
                child: Semantics(
                  container: true,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    padding: EdgeInsets.all(tokens.spacing.insetMd),
                    decoration: BoxDecoration(
                      color: tokens.color.surfaceOverlay,
                      borderRadius: tokens.shape.radiusOverlay,
                      boxShadow: tokens.elevation.overlay,
                      border: Border.all(color: tokens.color.borderDefault),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
