import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.checkbox}
/// A branded checkbox. Controlled: pass [value] and handle [onChanged]
/// (`null` = disabled). Toggles on tap or keyboard (Space/Enter), exposes a
/// `checkbox` semantics node, and shows a keyboard-only focus ring.
/// {@endtemplate}
class AstryxCheckbox extends StatefulWidget {
  const AstryxCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Optional inline label (also the accessible name unless [semanticLabel] set).
  final String? label;
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  @override
  State<AstryxCheckbox> createState() => _AstryxCheckboxState();
}

class _AstryxCheckboxState extends State<AstryxCheckbox> {
  bool _focused = false;

  void _toggle() {
    if (widget._enabled) widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final enabled = widget._enabled;
    final checked = widget.value;

    final box = AnimatedContainer(
      duration: motion.durationFast,
      curve: motion.curveStandard,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? (enabled ? t.color.accentDefault : t.color.textDisabled) : t.color.surfaceDefault,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        border: Border.all(
          color: checked
              ? (enabled ? t.color.accentDefault : t.color.textDisabled)
              : (enabled ? t.color.borderStrong : t.color.borderDefault),
          width: 1.5,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)]
            : null,
      ),
      child: checked
          ? CustomPaint(painter: _CheckPainter(t.color.textOnAccent))
          : null,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: t.spacing.gapMd,
      children: [
        box,
        if (widget.label != null)
          Flexible(
            child: Text(
              widget.label!,
              style: t.typography.body.copyWith(
                color: enabled ? t.color.textDefault : t.color.textDisabled,
              ),
            ),
          ),
      ],
    );

    return Semantics(
      checked: checked,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      container: true,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _toggle();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: ExcludeSemantics(child: row),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.28, h * 0.52)
      ..lineTo(w * 0.44, h * 0.68)
      ..lineTo(w * 0.72, h * 0.34);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}
