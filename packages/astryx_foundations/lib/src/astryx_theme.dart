import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';

/// Scoped token overrides for a subtree — the Flutter analog of redefining a
/// CSS custom property on a nested selector. Reads the inherited Astryx
/// extensions, applies the caller's deltas, and republishes a merged [Theme].
///
/// ```dart
/// AstryxTheme.override(
///   colors: (c) => c.copyWith(accentDefault: brandRed),
///   child: subtree, // everything below sees the new accent
/// )
/// ```
class AstryxTheme extends StatelessWidget {
  const AstryxTheme.override({
    super.key,
    this.colors,
    this.spacing,
    this.shape,
    this.elevation,
    this.motion,
    this.typography,
    required this.child,
  });

  final AstryxColorTokens Function(AstryxColorTokens)? colors;
  final AstryxSpacingTokens Function(AstryxSpacingTokens)? spacing;
  final AstryxShapeTokens Function(AstryxShapeTokens)? shape;
  final AstryxElevationTokens Function(AstryxElevationTokens)? elevation;
  final AstryxMotionTokens Function(AstryxMotionTokens)? motion;
  final AstryxTypographyTokens Function(AstryxTypographyTokens)? typography;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final t = AstryxTokens.of(context);

    final merged = base.copyWith(
      extensions: <ThemeExtension>[
        colors?.call(t.color) ?? t.color,
        spacing?.call(t.spacing) ?? t.spacing,
        shape?.call(t.shape) ?? t.shape,
        elevation?.call(t.elevation) ?? t.elevation,
        motion?.call(t.motion) ?? t.motion,
        typography?.call(t.typography) ?? t.typography,
      ],
    );

    return Theme(data: merged, child: child);
  }
}
