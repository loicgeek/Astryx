import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'motion_tokens.dart';
import 'scale_tokens.dart';
import 'typography_tokens.dart';

/// Ergonomic bundle of all Astryx semantic token groups resolved from the
/// nearest [Theme]. Fetched once via [BuildContext.tokens] so components read
/// `context.tokens.color.accentDefault` instead of six `Theme.of` lookups.
@immutable
class AstryxTokens {
  const AstryxTokens({
    required this.color,
    required this.spacing,
    required this.shape,
    required this.elevation,
    required this.motion,
    required this.typography,
  });

  final AstryxColorTokens color;
  final AstryxSpacingTokens spacing;
  final AstryxShapeTokens shape;
  final AstryxElevationTokens elevation;
  final AstryxMotionTokens motion;
  final AstryxTypographyTokens typography;

  /// Resolves the token bundle from [context]. Asserts the Astryx extensions
  /// are installed (they are, when the app uses an `AstryxThemeData`).
  static AstryxTokens of(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.extension<AstryxColorTokens>();
    final spacing = theme.extension<AstryxSpacingTokens>();
    final shape = theme.extension<AstryxShapeTokens>();
    final elevation = theme.extension<AstryxElevationTokens>();
    final motion = theme.extension<AstryxMotionTokens>();
    final typography = theme.extension<AstryxTypographyTokens>();
    assert(
      color != null &&
          spacing != null &&
          shape != null &&
          elevation != null &&
          motion != null &&
          typography != null,
      'Astryx token extensions are missing. Wrap your app in an Astryx theme '
      '(e.g. MaterialApp(theme: AstryxThemeData.neutral().light)).',
    );
    return AstryxTokens(
      color: color!,
      spacing: spacing!,
      shape: shape!,
      elevation: elevation!,
      motion: motion!,
      typography: typography!,
    );
  }
}

/// `context.tokens.color.accentDefault` — the canonical way components read tokens.
extension AstryxTokensContext on BuildContext {
  AstryxTokens get tokens => AstryxTokens.of(this);
}
