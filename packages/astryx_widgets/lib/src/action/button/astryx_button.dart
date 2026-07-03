import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import 'astryx_button_style.dart';

/// {@template astryx.button}
/// A branded, accessible action button — the Astryx reference component.
///
/// Composition hints: pair with an [AstryxButtonVariant] to convey emphasis
/// (`primary` for the main action, `secondary`/`ghost` for lower emphasis,
/// `danger` for destructive actions). Use [leading]/[trailing] slots for icons.
/// Disabled by passing `onPressed: null`; a [loading] button is also inert and
/// announces a busy state.
/// {@endtemplate}
///
/// A11y: exposes a `button` semantics role with the label text, honors
/// keyboard activation (Enter/Space), shows a token-driven focus ring only on
/// keyboard focus, and meets the 48×48 minimum target via [AstryxButtonSize].
class AstryxButton extends StatefulWidget {
  const AstryxButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AstryxButtonVariant.primary,
    this.size = AstryxButtonSize.md,
    this.leading,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.style,
    this.semanticLabel,
  });

  /// The button's text label (also its default accessible name).
  final String label;

  /// Tap/activate callback. `null` renders the button disabled.
  final VoidCallback? onPressed;

  final AstryxButtonVariant variant;
  final AstryxButtonSize size;

  /// Optional leading widget (icon). Structural slot — not covered by [style].
  final Widget? leading;

  /// Optional trailing widget (icon). Structural slot — not covered by [style].
  final Widget? trailing;

  /// When true, shows a spinner, disables interaction, and marks the control busy.
  final bool loading;

  /// Stretch to fill the horizontal extent of the parent.
  final bool expand;

  /// Per-instance paint override, merged over the token/variant default.
  final AstryxButtonStyle? style;

  /// Overrides the accessible name (defaults to [label]).
  final String? semanticLabel;

  bool get _enabled => onPressed != null && !loading;

  @override
  State<AstryxButton> createState() => _AstryxButtonState();
}

class _AstryxButtonState extends State<AstryxButton> {
  bool _hovered = false;
  bool _focusedByKeyboard = false;
  bool _pressed = false;

  void _handleActivate() {
    if (widget._enabled) widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final s = AstryxButtonStyle.resolve(
      context,
      variant: widget.variant,
      size: widget.size,
      override: widget.style,
    );

    final enabled = widget._enabled;
    final bg = !enabled
        ? tokens.color.surfaceSunken
        : _pressed
            ? (s.backgroundPressed ?? s.background!)
            : _hovered
                ? (s.backgroundHover ?? s.background!)
                : s.background!;
    final fg = enabled ? s.foreground! : tokens.color.textDisabled;

    final content = _buildContent(s, fg, tokens);

    Widget button = AnimatedContainer(
      duration: motion.durationFast,
      curve: motion.curveStandard,
      constraints: BoxConstraints(minHeight: s.minHeight ?? 40),
      padding: s.padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: s.borderRadius,
        border: s.borderColor != null
            ? Border.all(color: enabled ? s.borderColor! : tokens.color.borderDefault)
            : null,
        boxShadow: _focusedByKeyboard
            ? [
                BoxShadow(
                  color: tokens.color.borderFocus,
                  spreadRadius: 2,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: content,
    );

    if (widget.expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      // Announce a busy state to assistive tech while loading.
      liveRegion: widget.loading,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focusedByKeyboard = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleActivate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _handleActivate : null,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          child: ExcludeSemantics(child: button),
        ),
      ),
    );
  }

  Widget _buildContent(AstryxButtonStyle s, Color fg, AstryxTokens tokens) {
    final labelWidget = DefaultTextStyle.merge(
      style: (s.labelStyle ?? tokens.typography.label).copyWith(color: fg),
      child: Text(widget.label),
    );

    final children = <Widget>[
      if (widget.loading)
        _ButtonSpinner(color: fg)
      else if (widget.leading != null)
        IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: widget.leading!),
      labelWidget,
      if (widget.trailing != null && !widget.loading)
        IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: widget.trailing!),
    ];

    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: tokens.spacing.gapSm,
      children: children,
    );
  }
}

/// A tiny Material-free loading spinner for the button (rotating arc), so the
/// component depends only on the widgets library.
class _ButtonSpinner extends StatefulWidget {
  const _ButtonSpinner({required this.color});
  final Color color;

  @override
  State<_ButtonSpinner> createState() => _ButtonSpinnerState();
}

class _ButtonSpinnerState extends State<_ButtonSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AstryxMotion.resolve(context).durationSlow == Duration.zero;
    if (reduced) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(painter: _ButtonSpinnerPainter(_c.value, widget.color)),
      ),
    );
  }
}

class _ButtonSpinnerPainter extends CustomPainter {
  _ButtonSpinnerPainter(this.progress, this.color);
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * 6.283185,
      1.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ButtonSpinnerPainter old) => old.progress != progress || old.color != color;
}
