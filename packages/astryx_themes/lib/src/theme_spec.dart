import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';

import 'astryx_theme_data.dart';
import 'scheme.dart';

/// A compact description of a theme: three seed colors per brightness plus a
/// corner-radius unit and font family. [buildAstryxTheme] expands it into a full
/// [AstryxThemeData] (light + dark, all token extensions).
@immutable
class AstryxThemeSpec {
  const AstryxThemeSpec({
    required this.name,
    required this.lightSurface,
    required this.lightText,
    required this.lightAccent,
    required this.darkSurface,
    required this.darkText,
    required this.darkAccent,
    this.radiusUnit = 8,
    this.fontFamily = 'Inter',
    this.darkOnly = false,
  });

  final String name;
  final Color lightSurface, lightText, lightAccent;
  final Color darkSurface, darkText, darkAccent;
  final double radiusUnit;
  final String fontFamily;

  /// When true (e.g. gothic) the light variant renders the dark scheme.
  final bool darkOnly;
}

// Spacing and motion are brightness- and theme-invariant.
const _spacing = AstryxSpacingTokens(
  insetXs: AstryxSpace.s2,
  insetSm: AstryxSpace.s3,
  insetMd: AstryxSpace.s5,
  insetLg: AstryxSpace.s7,
  gapSm: AstryxSpace.s2,
  gapMd: AstryxSpace.s4,
  gapLg: AstryxSpace.s7,
);

const _motion = AstryxMotionTokens(
  durationFast: AstryxDurations.fast,
  durationNormal: AstryxDurations.normal,
  durationSlow: AstryxDurations.slow,
  curveStandard: AstryxEasings.standard,
  curveEmphasized: AstryxEasings.emphasized,
  curveDecelerate: AstryxEasings.decelerate,
  curveAccelerate: AstryxEasings.accelerate,
);

AstryxTypographyTokens _typography(String family, Color text, Color muted) {
  TextStyle base(double size, FontWeight weight, double height, Color color) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
        // Explicit so text never inherits the framework's amber debug underline
        // when rendered without a DefaultTextStyle (e.g. inside an Overlay).
        decoration: TextDecoration.none,
        leadingDistribution: TextLeadingDistribution.even,
      );
  return AstryxTypographyTokens(
    display: base(32, FontWeight.w700, 1.2, text),
    heading: base(22, FontWeight.w600, 1.25, text),
    body: base(15, FontWeight.w400, 1.45, text),
    label: base(13, FontWeight.w500, 1.3, muted),
    code: base(13, FontWeight.w400, 1.5, text).copyWith(fontFamily: 'monospace'),
  );
}

AstryxElevationTokens _elevation(Brightness b) {
  final o1 = b == Brightness.dark ? 0.5 : 0.08;
  final o2 = b == Brightness.dark ? 0.6 : 0.14;
  return AstryxElevationTokens(
    flat: const [],
    raised: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: o1), blurRadius: 8, offset: const Offset(0, 2))],
    overlay: [BoxShadow(color: const Color(0xFF000000).withValues(alpha: o2), blurRadius: 24, offset: const Offset(0, 8))],
  );
}

/// Expands a [AstryxThemeSpec] into a full [AstryxThemeData].
AstryxThemeData buildAstryxTheme(AstryxThemeSpec spec) {
  final shape = shapeFromUnit(spec.radiusUnit);

  ThemeData themeFor(Brightness b, AstryxColorTokens colors) => ThemeData(
        brightness: b,
        scaffoldBackgroundColor: colors.surfaceDefault,
        fontFamily: spec.fontFamily,
        extensions: <ThemeExtension>[
          colors,
          _spacing,
          shape,
          _elevation(b),
          _motion,
          _typography(spec.fontFamily, colors.textDefault, colors.textMuted),
        ],
      );

  final lightColors = deriveScheme(
    surface: spec.lightSurface,
    text: spec.lightText,
    accent: spec.lightAccent,
    brightness: Brightness.light,
  );
  final darkColors = deriveScheme(
    surface: spec.darkSurface,
    text: spec.darkText,
    accent: spec.darkAccent,
    brightness: Brightness.dark,
  );

  return AstryxThemeData(
    name: spec.name,
    // dark-only themes render the dark scheme even in light mode.
    light: spec.darkOnly
        ? themeFor(Brightness.dark, darkColors)
        : themeFor(Brightness.light, lightColors),
    dark: themeFor(Brightness.dark, darkColors),
  );
}
