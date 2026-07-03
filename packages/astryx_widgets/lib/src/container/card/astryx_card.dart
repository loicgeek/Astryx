import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Visual treatment of an [AstryxCard].
enum AstryxCardVariant { flat, raised, outlined }

/// {@template astryx.card}
/// A themed container surface. [variant] controls fill/border/shadow. When
/// [onTap] is set the card becomes interactive (hover/press/focus states,
/// keyboard activation, button semantics) — covering the clickable/selectable
/// card patterns via [selected].
/// {@endtemplate}
class AstryxCard extends StatefulWidget {
  const AstryxCard({
    super.key,
    required this.child,
    this.variant = AstryxCardVariant.outlined,
    this.padding,
    this.onTap,
    this.selected = false,
    this.semanticLabel,
  });

  final Widget child;
  final AstryxCardVariant variant;
  final EdgeInsetsGeometry? padding;

  /// When set, the card is interactive (clickable card).
  final VoidCallback? onTap;

  /// Selected state (selectable card) — draws an accent ring + reports selection.
  final bool selected;
  final String? semanticLabel;

  @override
  State<AstryxCard> createState() => _AstryxCardState();
}

class _AstryxCardState extends State<AstryxCard> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  bool get _interactive => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);

    final baseFill = switch (widget.variant) {
      AstryxCardVariant.flat => t.color.surfaceSunken,
      AstryxCardVariant.raised => t.color.surfaceRaised,
      AstryxCardVariant.outlined => t.color.surfaceDefault,
    };
    final fill = _interactive && _hovered ? t.color.surfaceSunken : baseFill;

    final borderColor = widget.selected
        ? t.color.accentDefault
        : widget.variant == AstryxCardVariant.outlined
            ? t.color.borderDefault
            : const Color(0x00000000);

    final shadow = switch (widget.variant) {
      AstryxCardVariant.raised => _pressed ? t.elevation.flat : t.elevation.raised,
      _ => t.elevation.flat,
    };

    Widget card = AnimatedContainer(
      duration: motion.durationFast,
      curve: motion.curveStandard,
      padding: widget.padding ?? EdgeInsets.all(t.spacing.insetMd),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: t.shape.radiusCard,
        border: Border.all(
          color: borderColor,
          width: widget.selected ? 1.5 : 1,
        ),
        boxShadow: [
          ...shadow,
          if (_focused) BoxShadow(color: t.color.borderFocus, spreadRadius: 2),
        ],
      ),
      child: widget.child,
    );

    if (!_interactive) {
      return widget.semanticLabel != null
          ? Semantics(label: widget.semanticLabel, container: true, child: card)
          : card;
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap!();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: ExcludeSemantics(child: card),
        ),
      ),
    );
  }
}
