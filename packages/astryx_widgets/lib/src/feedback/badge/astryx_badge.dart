import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Semantic emphasis for a [AstryxBadge] / [AstryxStatusDot].
enum AstryxTone { neutral, accent, success, danger, warning }

/// {@template astryx.badge}
/// Compact status/count pill. Uses a tinted surface + on-tone text so it reads
/// in light and dark. Decorative by default; pass [semanticsLabel] when the
/// badge conveys information not otherwise announced.
/// {@endtemplate}
class AstryxBadge extends StatelessWidget {
  const AstryxBadge(
    this.label, {
    super.key,
    this.tone = AstryxTone.neutral,
    this.leadingDot = false,
    this.semanticsLabel,
  });

  final String label;
  final AstryxTone tone;
  final bool leadingDot;
  final String? semanticsLabel;

  static ({Color fg, Color bg}) _colors(AstryxTokens t, AstryxTone tone) {
    Color tint(Color c) => Color.alphaBlend(c.withValues(alpha: 0.14), t.color.surfaceDefault);
    return switch (tone) {
      AstryxTone.neutral => (fg: t.color.textMuted, bg: t.color.surfaceSunken),
      AstryxTone.accent => (fg: t.color.accentDefault, bg: tint(t.color.accentDefault)),
      AstryxTone.success => (fg: t.color.success, bg: tint(t.color.success)),
      AstryxTone.danger => (fg: t.color.danger, bg: tint(t.color.danger)),
      AstryxTone.warning => (fg: t.color.warning, bg: tint(t.color.warning)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = _colors(t, tone);
    return Semantics(
      label: semanticsLabel,
      container: semanticsLabel != null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.insetSm, vertical: 2),
        decoration: BoxDecoration(color: c.bg, borderRadius: t.shape.radiusPill),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: t.spacing.gapSm,
          children: [
            if (leadingDot)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
              ),
            Text(
              label,
              style: t.typography.label.copyWith(color: c.fg, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template astryx.statusdot}
/// A small colored dot indicating status. Always carries an accessible [label]
/// (color alone is never the sole signal).
/// {@endtemplate}
class AstryxStatusDot extends StatelessWidget {
  const AstryxStatusDot({super.key, this.tone = AstryxTone.neutral, required this.label, this.size = 8});

  final AstryxTone tone;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = AstryxBadge._colors(t, tone).fg;
    return Semantics(
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
