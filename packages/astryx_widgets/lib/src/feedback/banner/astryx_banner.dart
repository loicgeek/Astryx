import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../badge/astryx_badge.dart' show AstryxTone;

/// {@template astryx.banner}
/// A prominent inline message tied to a region of the UI (not a transient
/// toast). Conveys a [tone] with a tinted surface + accent bar, an optional
/// [icon] and [actions], and an optional dismiss affordance.
/// {@endtemplate}
class AstryxBanner extends StatelessWidget {
  const AstryxBanner({
    super.key,
    required this.message,
    this.title,
    this.tone = AstryxTone.accent,
    this.icon,
    this.actions = const [],
    this.onDismiss,
  });

  final String message;
  final String? title;
  final AstryxTone tone;
  final Widget? icon;

  /// Trailing action widgets (e.g. buttons). Structural slot.
  final List<Widget> actions;

  /// When non-null, shows a dismiss button that calls this.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final accent = _toneColor(t, tone);
    final bg = Color.alphaBlend(accent.withValues(alpha: 0.10), t.color.surfaceDefault);

    return Semantics(
      container: true,
      liveRegion: true,
      // Keep the actionable Dismiss button as its own child node while the
      // container announces the message.
      explicitChildNodes: true,
      label: title == null ? message : '$title. $message',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: t.shape.radiusCard,
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: Padding(
          padding: EdgeInsets.all(t.spacing.insetMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: t.spacing.gapMd,
            children: [
              if (icon != null)
                IconTheme.merge(data: IconThemeData(color: accent, size: 18), child: icon!),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: t.spacing.gapSm,
                    children: [
                      if (title != null)
                        Text(title!,
                            style: t.typography.label
                                .copyWith(color: t.color.textDefault, fontWeight: FontWeight.w700)),
                      Text(message, style: t.typography.body.copyWith(color: t.color.textDefault)),
                      if (actions.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: t.spacing.gapSm),
                          child: Wrap(spacing: t.spacing.gapMd, children: actions),
                        ),
                    ],
                  ),
                ),
              ),
              if (onDismiss != null)
                _DismissButton(color: t.color.textMuted, onDismiss: onDismiss!),
            ],
          ),
        ),
      ),
    );
  }

  static Color _toneColor(AstryxTokens t, AstryxTone tone) => switch (tone) {
        AstryxTone.neutral => t.color.textMuted,
        AstryxTone.accent => t.color.accentDefault,
        AstryxTone.success => t.color.success,
        AstryxTone.danger => t.color.danger,
        AstryxTone.warning => t.color.warning,
      };
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.color, required this.onDismiss});
  final Color color;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Dismiss',
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(painter: _XPainter(color)),
        ),
      ),
    );
  }
}

class _XPainter extends CustomPainter {
  const _XPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final pad = size.width * 0.3;
    canvas.drawLine(Offset(pad, pad), Offset(size.width - pad, size.height - pad), p);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(pad, size.height - pad), p);
  }

  @override
  bool shouldRepaint(_XPainter old) => old.color != color;
}
