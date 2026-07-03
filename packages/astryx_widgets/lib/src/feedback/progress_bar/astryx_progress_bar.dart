import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.progressbar}
/// A linear progress indicator. Determinate when [value] (0..1) is set;
/// otherwise indeterminate (an animated sweep, frozen under reduced motion).
/// Announces its percentage to assistive tech.
/// {@endtemplate}
class AstryxProgressBar extends StatefulWidget {
  const AstryxProgressBar({super.key, this.value, this.semanticLabel = 'Progress', this.height = 6});

  final double? value;
  final String semanticLabel;
  final double height;

  @override
  State<AstryxProgressBar> createState() => _AstryxProgressBarState();
}

class _AstryxProgressBarState extends State<AstryxProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AstryxMotion.resolve(context).durationSlow == Duration.zero;
    if (widget.value == null && !reduced) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void didUpdateWidget(AstryxProgressBar old) {
    super.didUpdateWidget(old);
    if (widget.value != null) {
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
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final value = widget.value?.clamp(0.0, 1.0);

    return Semantics(
      label: widget.semanticLabel,
      value: value != null ? '${(value * 100).round()}%' : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height),
        child: Container(
          height: widget.height,
          color: t.color.surfaceSunken,
          child: value != null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: motion.durationNormal,
                    curve: motion.curveDecelerate,
                    widthFactor: value,
                    child: DecoratedBox(decoration: BoxDecoration(color: t.color.accentDefault)),
                  ),
                )
              : AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => CustomPaint(
                    painter: _IndeterminatePainter(progress: _c.value, color: t.color.accentDefault),
                  ),
                ),
        ),
      ),
    );
  }
}

class _IndeterminatePainter extends CustomPainter {
  _IndeterminatePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final segW = size.width * 0.4;
    final x = (size.width + segW) * progress - segW;
    canvas.drawRect(Rect.fromLTWH(x, 0, segW, size.height), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_IndeterminatePainter old) => old.progress != progress || old.color != color;
}
