import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.slider}
/// A branded, accessible slider. Controlled via [value] within [min]/[max].
/// Drag the thumb, or focus and use arrow keys (Home/End jump to ends). Exposes
/// a `slider` semantics node with the current value and increase/decrease
/// actions. Optional [divisions] snap the value.
/// {@endtemplate}
class AstryxSlider extends StatefulWidget {
  const AstryxSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.focusNode,
    required this.semanticLabel,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final FocusNode? focusNode;
  final String semanticLabel;

  bool get _enabled => onChanged != null;

  @override
  State<AstryxSlider> createState() => _AstryxSliderState();
}

class _AstryxSliderState extends State<AstryxSlider> {
  bool _focused = false;

  double get _step => widget.divisions != null
      ? (widget.max - widget.min) / widget.divisions!
      : (widget.max - widget.min) / 100;

  double _clamp(double v) => v.clamp(widget.min, widget.max);

  void _emit(double v) {
    if (!widget._enabled) return;
    var next = _clamp(v);
    if (widget.divisions != null) {
      final steps = ((next - widget.min) / _step).round();
      next = widget.min + steps * _step;
    }
    if (next != widget.value) widget.onChanged!(next);
  }

  void _updateFromDx(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    _emit(widget.min + fraction * (widget.max - widget.min));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget._enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.arrowDown:
        _emit(widget.value - _step);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.arrowUp:
        _emit(widget.value + _step);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        _emit(widget.min);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        _emit(widget.max);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = widget._enabled;
    final fraction = (widget.max > widget.min)
        ? ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;

    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.semanticLabel,
      value: _format(widget.value),
      // Flutter requires increased/decreased values alongside increase/decrease.
      increasedValue: _format(_clamp(widget.value + _step)),
      decreasedValue: _format(_clamp(widget.value - _step)),
      onIncrease: enabled ? () => _emit(widget.value + _step) : null,
      onDecrease: enabled ? () => _emit(widget.value - _step) : null,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: enabled,
        onKeyEvent: _onKey,
        onFocusChange: (v) => setState(() => _focused = v),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: enabled ? (d) => _updateFromDx(d.localPosition.dx, width) : null,
              onHorizontalDragUpdate:
                  enabled ? (d) => _updateFromDx(d.localPosition.dx, width) : null,
              child: SizedBox(
                height: 28,
                child: CustomPaint(
                  painter: _SliderPainter(
                    fraction: fraction,
                    track: t.color.borderDefault,
                    fill: enabled ? t.color.accentDefault : t.color.textDisabled,
                    thumb: t.color.surfaceDefault,
                    thumbBorder: enabled ? t.color.accentDefault : t.color.textDisabled,
                    focusRing: _focused ? t.color.borderFocus : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _format(double v) {
    final fraction = (widget.max > widget.min)
        ? ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0)
        : 0.0;
    // Stepped slider announces the notch index (e.g. "5" of 10); continuous
    // announces a percentage.
    if (widget.divisions != null) return (fraction * widget.divisions!).round().toString();
    return '${(fraction * 100).round()}%';
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.fraction,
    required this.track,
    required this.fill,
    required this.thumb,
    required this.thumbBorder,
    required this.focusRing,
  });

  final double fraction;
  final Color track;
  final Color fill;
  final Color thumb;
  final Color thumbBorder;
  final Color? focusRing;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const trackH = 4.0, thumbR = 9.0;
    final usable = size.width - thumbR * 2;
    final cx = thumbR + usable * fraction;

    final trackPaint = Paint()
      ..color = track
      ..strokeWidth = trackH
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(thumbR, cy), Offset(size.width - thumbR, cy), trackPaint);

    final fillPaint = Paint()
      ..color = fill
      ..strokeWidth = trackH
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(thumbR, cy), Offset(cx, cy), fillPaint);

    if (focusRing != null) {
      canvas.drawCircle(Offset(cx, cy), thumbR + 3, Paint()..color = focusRing!);
    }
    canvas.drawCircle(Offset(cx, cy), thumbR, Paint()..color = thumb);
    canvas.drawCircle(
      Offset(cx, cy),
      thumbR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = thumbBorder,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.fraction != fraction || old.fill != fill || old.focusRing != focusRing;
}
