import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.skeleton}
/// A shimmering placeholder shown while content loads. The shimmer sweep is
/// disabled (static block) under reduced motion. Hidden from assistive tech
/// (loading is conveyed elsewhere, e.g. a spinner's live region).
/// {@endtemplate}
class AstryxSkeleton extends StatefulWidget {
  const AstryxSkeleton({super.key, this.width, this.height = 16, this.borderRadius});

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  /// A stack of [lines] text-line skeletons; the last is shorter.
  static Widget lines(int count, {double spacing = 8}) => _SkeletonLines(count: count, spacing: spacing);

  @override
  State<AstryxSkeleton> createState() => _AstryxSkeletonState();
}

class _AstryxSkeletonState extends State<AstryxSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

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
    final t = context.tokens;
    final radius = widget.borderRadius ?? BorderRadius.circular(6);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _ShimmerPainter(
                progress: _c.isAnimating ? _c.value : -1,
                base: t.color.surfaceSunken,
                highlight: Color.alphaBlend(t.color.textMuted.withValues(alpha: 0.10), t.color.surfaceSunken),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({required this.progress, required this.base, required this.highlight});
  final double progress; // -1 = static (reduced motion)
  final Color base;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = base);
    if (progress < 0) return;
    final x = size.width * (progress * 2 - 0.5);
    final band = size.width * 0.5;
    final shader = LinearGradient(
      colors: [base, highlight, base],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(x, 0, band, size.height));
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress || old.base != base;
}

class _SkeletonLines extends StatelessWidget {
  const _SkeletonLines({required this.count, required this.spacing});
  final int count;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          FractionallySizedBox(
            widthFactor: i == count - 1 ? 0.6 : 1.0,
            child: const AstryxSkeleton(height: 12),
          ),
        ],
      ],
    );
  }
}
