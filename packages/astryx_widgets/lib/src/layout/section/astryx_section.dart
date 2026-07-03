import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../content/heading/astryx_heading.dart';
import '../../content/text/astryx_text.dart';

/// {@template astryx.section}
/// A titled content block: heading (+ optional description and trailing action)
/// over its [child], with token-driven vertical rhythm. The heading carries a
/// proper header role via [AstryxHeading].
/// {@endtemplate}
class AstryxSection extends StatelessWidget {
  const AstryxSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.level = AstryxHeadingLevel.h2,
    required this.child,
  });

  final String title;
  final String? description;

  /// Optional trailing widget aligned with the title (e.g. an action button).
  final Widget? trailing;
  final AstryxHeadingLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: t.spacing.gapMd,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: t.spacing.gapSm,
                children: [
                  AstryxHeading(title, level: level),
                  if (description != null)
                    AstryxText(description!, tone: AstryxTextTone.muted),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        child,
      ],
    );
  }
}
