import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

enum AstryxSpinnerSize { sm, md, lg }

/// {@template astryx.spinner}
/// Indeterminate loading indicator, token-colored. Announces a busy state to
/// assistive tech via [label]. Honors reduced motion (renders a static ring
/// instead of spinning) through the shared motion choke point.
/// {@endtemplate}
class AstryxSpinner extends StatefulWidget {
  const AstryxSpinner({
    super.key,
    this.size = AstryxSpinnerSize.md,
    this.color,
    this.label = 'Loading',
  });

  final AstryxSpinnerSize size;
  final Color? color;
  final String label;

  @override
  State<AstryxSpinner> createState() => _AstryxSpinnerState();
}

class _AstryxSpinnerState extends State<AstryxSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion → don't spin (durationSlow collapses to zero).
    final reduced = AstryxMotion.resolve(context).durationSlow == Duration.zero;
    if (reduced) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _dim => switch (widget.size) {
        AstryxSpinnerSize.sm => 16,
        AstryxSpinnerSize.md => 24,
        AstryxSpinnerSize.lg => 36,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = widget.color ?? t.color.accentDefault;
    final track = t.color.borderDefault;
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: SizedBox(
        width: _dim,
        height: _dim,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _RingPainter(progress: _controller.value, color: color, track: track),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color, required this.track});

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    const sweep = 1.6; // ~90° visible arc
    final start = progress * 6.283185; // 2π
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
