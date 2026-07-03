import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.carousel}
/// A horizontal, swipeable pager over [items] with optional prev/next arrows
/// (pointer devices) and a dot indicator. Announces the current position and
/// exposes labeled arrow buttons.
/// {@endtemplate}
class AstryxCarousel extends StatefulWidget {
  const AstryxCarousel({
    super.key,
    required this.items,
    this.height = 200,
    this.showArrows = true,
    this.showIndicators = true,
  });

  final List<Widget> items;
  final double height;
  final bool showArrows;
  final bool showIndicators;

  @override
  State<AstryxCarousel> createState() => _AstryxCarouselState();
}

class _AstryxCarouselState extends State<AstryxCarousel> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int target) {
    final motion = AstryxMotion.resolve(context);
    final i = target.clamp(0, widget.items.length - 1);
    _pages.animateToPage(
      i,
      duration: motion.durationNormal,
      curve: motion.curveStandard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final count = widget.items.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Carousel, item ${_index + 1} of $count',
          liveRegion: true,
          child: SizedBox(
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: t.shape.radiusCard,
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: count,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => widget.items[i],
                  ),
                ),
                if (widget.showArrows && count > 1) ...[
                  Positioned(
                    left: t.spacing.insetSm,
                    child: _Arrow(
                      forward: false,
                      onTap: _index > 0 ? () => _go(_index - 1) : null,
                      tokens: t,
                    ),
                  ),
                  Positioned(
                    right: t.spacing.insetSm,
                    child: _Arrow(
                      forward: true,
                      onTap: _index < count - 1 ? () => _go(_index + 1) : null,
                      tokens: t,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.showIndicators && count > 1) ...[
          SizedBox(height: t.spacing.gapMd),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: _Dot(
                    active: i == _index,
                    tokens: t,
                    onTap: () => _go(i),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.forward,
    required this.onTap,
    required this.tokens,
  });
  final bool forward;
  final VoidCallback? onTap;
  final AstryxTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: forward ? 'Next' : 'Previous',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: t.color.surfaceOverlay,
              shape: BoxShape.circle,
              boxShadow: t.elevation.raised,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: CustomPaint(
              painter: _ChevronPainter(
                color: enabled ? t.color.textDefault : t.color.textDisabled,
                forward: forward,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.tokens, required this.onTap});
  final bool active;
  final AstryxTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Semantics(
      button: true,
      selected: active,
      label: 'Go to item',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            width: active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? t.color.accentDefault : t.color.borderStrong,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.forward});
  final Color color;
  final bool forward;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    final path = forward
        ? (Path()
            ..moveTo(w * 0.42, h * 0.32)
            ..lineTo(w * 0.6, h * 0.5)
            ..lineTo(w * 0.42, h * 0.68))
        : (Path()
            ..moveTo(w * 0.58, h * 0.32)
            ..lineTo(w * 0.4, h * 0.5)
            ..lineTo(w * 0.58, h * 0.68));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.color != color || old.forward != forward;
}
