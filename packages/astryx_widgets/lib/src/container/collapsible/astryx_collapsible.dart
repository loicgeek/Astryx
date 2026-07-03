import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.collapsible}
/// A disclosure that expands/collapses its [child] under a tappable [title]
/// row. Controlled-optional: seed with [initiallyExpanded] and observe
/// [onExpansionChanged]. The header exposes a button with an expanded state and
/// activates by keyboard; the chevron rotates and the body animates open
/// (honoring reduced motion).
/// {@endtemplate}
class AstryxCollapsible extends StatefulWidget {
  const AstryxCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<AstryxCollapsible> createState() => _AstryxCollapsibleState();
}

class _AstryxCollapsibleState extends State<AstryxCollapsible> {
  late bool _expanded = widget.initiallyExpanded;
  bool _focused = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);

    final header = Semantics(
      button: true,
      expanded: _expanded,
      label: widget.title,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _toggle();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: t.spacing.insetSm),
              decoration: _focused
                  ? BoxDecoration(
                      borderRadius: t.shape.radiusControl,
                      boxShadow: [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)],
                    )
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: t.typography.label.copyWith(
                        color: t.color.textDefault,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: motion.durationFast,
                    curve: motion.curveStandard,
                    child: _Chevron(color: t.color.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        AnimatedSize(
          duration: motion.durationNormal,
          curve: motion.curveStandard,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: _expanded ? double.infinity : 0),
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1 : 0,
              child: Padding(
                padding: EdgeInsets.only(top: t.spacing.gapSm, bottom: t.spacing.gapMd),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 16, height: 16, child: CustomPaint(painter: _ChevronPainter(color)));
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // A right-pointing chevron; rotated by AnimatedRotation when expanded.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.4, h * 0.28)
        ..lineTo(w * 0.62, h * 0.5)
        ..lineTo(w * 0.4, h * 0.72),
      p,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
