import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../text/astryx_text.dart';

/// Heading level. `display` is the largest; `h1`–`h3` step down. Levels map to
/// the theme's `display`/`heading` typography tokens (scaled), and expose a
/// header semantics node for assistive tech.
enum AstryxHeadingLevel { display, h1, h2, h3 }

/// {@template astryx.heading}
/// Section heading with a proper `header` semantics role. Prefer this over
/// styling [AstryxText] so screen readers can navigate by heading.
/// {@endtemplate}
class AstryxHeading extends StatelessWidget {
  const AstryxHeading(
    this.data, {
    super.key,
    this.level = AstryxHeadingLevel.h1,
    this.tone = AstryxTextTone.normal,
    this.textAlign,
    this.maxLines,
    this.style,
  });

  final String data;
  final AstryxHeadingLevel level;
  final AstryxTextTone tone;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // display token for the top level; heading token scaled down for h1–h3.
    final base = switch (level) {
      AstryxHeadingLevel.display => t.typography.display,
      AstryxHeadingLevel.h1 => t.typography.heading,
      AstryxHeadingLevel.h2 =>
        t.typography.heading.copyWith(fontSize: (t.typography.heading.fontSize ?? 22) * 0.82),
      AstryxHeadingLevel.h3 =>
        t.typography.heading.copyWith(fontSize: (t.typography.heading.fontSize ?? 22) * 0.68),
    };
    final resolved =
        base.copyWith(color: AstryxText.toneColor(t, tone)).merge(style);

    return Semantics(
      header: true,
      child: Text(
        data,
        style: resolved,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      ),
    );
  }
}
