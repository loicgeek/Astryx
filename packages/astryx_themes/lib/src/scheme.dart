import 'dart:math' as math;

import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';

/// WCAG relative-luminance contrast ratio between two colors (1..21).
double contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

/// Derives a full semantic color scheme from three seed colors — surface, text,
/// and accent — for a given brightness. Muted/border/disabled roles are blends
/// of text over surface; hover/pressed shift the accent toward white (dark) or
/// black (light); on-accent text is chosen by accent luminance for contrast.
///
/// This keeps each theme's definition to a handful of seeds while producing a
/// coherent, accessible set of tokens.
AstryxColorTokens deriveScheme({
  required Color surface,
  required Color text,
  required Color accent,
  required Brightness brightness,
}) {
  final dark = brightness == Brightness.dark;
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);
  Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
  // text laid over surface at [a] opacity → a muted variant sitting on surface.
  Color on(double a) => Color.alphaBlend(text.withValues(alpha: a), surface);
  final toward = dark ? white : black;
  // Pick the on-accent text color with the higher contrast against the accent
  // (white-on-amber, for instance, would otherwise fail contrast).
  const darkInk = Color(0xFF16161A);
  final onAccent = contrastRatio(accent, white) >= contrastRatio(accent, darkInk) ? white : darkInk;

  return AstryxColorTokens(
    surfaceDefault: surface,
    surfaceRaised: dark ? mix(surface, white, 0.05) : surface,
    surfaceSunken: on(0.05),
    surfaceOverlay: dark ? mix(surface, white, 0.08) : surface,
    textDefault: text,
    textMuted: on(0.55),
    textOnAccent: onAccent,
    textDisabled: on(0.32),
    borderDefault: on(0.14),
    borderStrong: on(0.26),
    borderFocus: accent,
    accentDefault: accent,
    accentHover: mix(accent, toward, 0.14),
    accentPressed: mix(accent, toward, 0.26),
    danger: dark ? AstryxPalette.red400 : AstryxPalette.red500,
    success: dark ? AstryxPalette.green400 : AstryxPalette.green500,
    warning: dark ? AstryxPalette.amber400 : AstryxPalette.amber500,
  );
}

/// Builds the shape scale from a single corner-radius unit. `unit == 0` yields a
/// fully squared-off system (e.g. brutalist).
AstryxShapeTokens shapeFromUnit(double unit) {
  BorderRadius r(double v) => BorderRadius.all(Radius.circular(v));
  return AstryxShapeTokens(
    radiusControl: r(unit),
    radiusCard: r(unit == 0 ? 0 : unit * 1.4),
    radiusOverlay: r(unit == 0 ? 0 : unit * 1.8),
    radiusPill: r(unit == 0 ? 0 : AstryxRadius.full),
  );
}
