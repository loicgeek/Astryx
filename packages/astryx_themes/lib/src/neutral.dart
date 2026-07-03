import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';

import 'astryx_theme_data.dart';

/// The `neutral` theme — the default Astryx look, generated target of
/// `tokens/themes/neutral.json` mapped onto concrete Dart token groups.
AstryxThemeData buildNeutralTheme() {
  // Scales are brightness-invariant.
  const spacing = AstryxSpacingTokens(
    insetXs: AstryxSpace.s2,
    insetSm: AstryxSpace.s3,
    insetMd: AstryxSpace.s5,
    insetLg: AstryxSpace.s7,
    gapSm: AstryxSpace.s2,
    gapMd: AstryxSpace.s4,
    gapLg: AstryxSpace.s7,
  );
  const shape = AstryxShapeTokens(
    radiusControl: BorderRadius.all(Radius.circular(AstryxRadius.md)),
    radiusCard: BorderRadius.all(Radius.circular(AstryxRadius.lg)),
    radiusOverlay: BorderRadius.all(Radius.circular(AstryxRadius.xl)),
    radiusPill: BorderRadius.all(Radius.circular(AstryxRadius.full)),
  );
  const motion = AstryxMotionTokens(
    durationFast: AstryxDurations.fast,
    durationNormal: AstryxDurations.normal,
    durationSlow: AstryxDurations.slow,
    curveStandard: AstryxEasings.standard,
    curveEmphasized: AstryxEasings.emphasized,
    curveDecelerate: AstryxEasings.decelerate,
    curveAccelerate: AstryxEasings.accelerate,
  );

  AstryxTypographyTokens typography(Color text, Color muted) {
    TextStyle base(double size, FontWeight weight, double height, Color color) =>
        TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: color,
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

  List<BoxShadow> raisedShadow(double opacity) => [
        BoxShadow(
          color: AstryxPalette.black.withValues(alpha: opacity),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
  List<BoxShadow> overlayShadow(double opacity) => [
        BoxShadow(
          color: AstryxPalette.black.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  final lightColors = const AstryxColorTokens(
    surfaceDefault: AstryxPalette.neutral0,
    surfaceRaised: AstryxPalette.neutral0,
    surfaceSunken: AstryxPalette.neutral50,
    surfaceOverlay: AstryxPalette.neutral0,
    textDefault: AstryxPalette.neutral900,
    textMuted: AstryxPalette.neutral500,
    textOnAccent: AstryxPalette.white,
    textDisabled: AstryxPalette.neutral300,
    borderDefault: AstryxPalette.neutral200,
    borderStrong: AstryxPalette.neutral300,
    borderFocus: AstryxPalette.blue500,
    accentDefault: AstryxPalette.blue500,
    accentHover: AstryxPalette.blue600,
    accentPressed: AstryxPalette.blue700,
    danger: AstryxPalette.red500,
    success: AstryxPalette.green500,
    warning: AstryxPalette.amber500,
  );

  final darkColors = const AstryxColorTokens(
    surfaceDefault: AstryxPalette.neutral950,
    surfaceRaised: AstryxPalette.neutral900,
    surfaceSunken: AstryxPalette.neutral900,
    surfaceOverlay: AstryxPalette.neutral800,
    textDefault: AstryxPalette.neutral50,
    textMuted: AstryxPalette.neutral400,
    textOnAccent: AstryxPalette.white,
    textDisabled: AstryxPalette.neutral600,
    borderDefault: AstryxPalette.neutral700,
    borderStrong: AstryxPalette.neutral600,
    borderFocus: AstryxPalette.blue400,
    accentDefault: AstryxPalette.blue400,
    accentHover: AstryxPalette.blue300,
    accentPressed: AstryxPalette.blue500,
    danger: AstryxPalette.red400,
    success: AstryxPalette.green400,
    warning: AstryxPalette.amber400,
  );

  ThemeData themeFor(Brightness brightness, AstryxColorTokens colors) {
    final elevation = AstryxElevationTokens(
      flat: const [],
      raised: raisedShadow(brightness == Brightness.dark ? 0.5 : 0.08),
      overlay: overlayShadow(brightness == Brightness.dark ? 0.6 : 0.14),
    );
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.surfaceDefault,
      fontFamily: 'Inter',
      extensions: <ThemeExtension>[
        colors,
        spacing,
        shape,
        elevation,
        motion,
        typography(colors.textDefault, colors.textMuted),
      ],
    );
  }

  return AstryxThemeData(
    name: 'neutral',
    light: themeFor(Brightness.light, lightColors),
    dark: themeFor(Brightness.dark, darkColors),
  );
}
