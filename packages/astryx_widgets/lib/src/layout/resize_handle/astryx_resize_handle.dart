import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.resizehandle}
/// A draggable divider for resizing adjacent panels. Emits a signed delta (in
/// logical pixels) via [onResize] as the user drags; arrow keys nudge by
/// [step] when focused. Shows a resize cursor and announces itself as an
/// adjustable separator.
/// {@endtemplate}
class AstryxResizeHandle extends StatefulWidget {
  const AstryxResizeHandle({
    super.key,
    required this.onResize,
    this.axis = Axis.vertical,
    this.step = 16,
    this.thickness = 8,
    this.focusNode,
    required this.semanticLabel,
  });

  /// Signed delta along the resize direction (dx for a vertical handle).
  final ValueChanged<double> onResize;

  /// The handle's own orientation. A [Axis.vertical] handle resizes horizontally.
  final Axis axis;
  final double step;
  final double thickness;
  final FocusNode? focusNode;
  final String semanticLabel;

  @override
  State<AstryxResizeHandle> createState() => _AstryxResizeHandleState();
}

class _AstryxResizeHandleState extends State<AstryxResizeHandle> {
  bool _active = false;
  bool _focused = false;

  bool get _vertical => widget.axis == Axis.vertical;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (_vertical) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        widget.onResize(-widget.step);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        widget.onResize(widget.step);
        return KeyEventResult.handled;
      }
    } else {
      if (key == LogicalKeyboardKey.arrowUp) {
        widget.onResize(-widget.step);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        widget.onResize(widget.step);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final grabColor = _active || _focused ? t.color.accentDefault : t.color.borderStrong;

    return Semantics(
      label: widget.semanticLabel,
      hint: 'Draggable. Use arrow keys to resize.',
      child: Focus(
        focusNode: widget.focusNode,
        onKeyEvent: _onKey,
        onFocusChange: (v) => setState(() => _focused = v),
        child: MouseRegion(
          cursor: _vertical ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate:
                _vertical ? (d) => widget.onResize(d.delta.dx) : null,
            onVerticalDragUpdate:
                _vertical ? null : (d) => widget.onResize(d.delta.dy),
            onHorizontalDragStart: _vertical ? (_) => setState(() => _active = true) : null,
            onHorizontalDragEnd: _vertical ? (_) => setState(() => _active = false) : null,
            onVerticalDragStart: _vertical ? null : (_) => setState(() => _active = true),
            onVerticalDragEnd: _vertical ? null : (_) => setState(() => _active = false),
            child: SizedBox(
              width: _vertical ? widget.thickness : double.infinity,
              height: _vertical ? double.infinity : widget.thickness,
              child: Center(
                child: Container(
                  width: _vertical ? 2 : 32,
                  height: _vertical ? 32 : 2,
                  decoration: BoxDecoration(
                    color: grabColor,
                    borderRadius: BorderRadius.circular(1),
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
