import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Typographic role — selects the base [TextStyle] from the theme's typography
/// tokens.
enum AstryxTextVariant { body, label, code }

/// Semantic color role for text. Keeps callers off raw colors so themes drive it.
enum AstryxTextTone { normal, muted, accent, danger, success, warning, onAccent }

/// {@template astryx.text}
/// Themed text primitive. Reads typography + color tokens so every theme
/// restyles it; pass [style] to override paint per instance.
/// {@endtemplate}
class AstryxText extends StatelessWidget {
  const AstryxText(
    this.data, {
    super.key,
    this.variant = AstryxTextVariant.body,
    this.tone = AstryxTextTone.normal,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
    this.semanticsLabel,
  });

  final String data;
  final AstryxTextVariant variant;
  final AstryxTextTone tone;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Per-instance override, merged over the token-resolved base.
  final TextStyle? style;
  final String? semanticsLabel;

  static Color toneColor(AstryxTokens t, AstryxTextTone tone) {
    return switch (tone) {
      AstryxTextTone.normal => t.color.textDefault,
      AstryxTextTone.muted => t.color.textMuted,
      AstryxTextTone.accent => t.color.accentDefault,
      AstryxTextTone.danger => t.color.danger,
      AstryxTextTone.success => t.color.success,
      AstryxTextTone.warning => t.color.warning,
      AstryxTextTone.onAccent => t.color.textOnAccent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final base = switch (variant) {
      AstryxTextVariant.body => t.typography.body,
      AstryxTextVariant.label => t.typography.label,
      AstryxTextVariant.code => t.typography.code,
    };
    final resolved = base.copyWith(color: toneColor(t, tone)).merge(style);

    return Text(
      data,
      style: resolved,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      semanticsLabel: semanticsLabel,
    );
  }
}
