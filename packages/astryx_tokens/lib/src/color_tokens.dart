import 'package:flutter/material.dart';

/// Semantic (tier-2) color roles. Components read ONLY these — never primitives —
/// so any theme drives every component by re-pointing these values.
///
/// `lerp` gives animated theme transitions for free via [AnimatedTheme].
@immutable
class AstryxColorTokens extends ThemeExtension<AstryxColorTokens> {
  const AstryxColorTokens({
    required this.surfaceDefault,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.surfaceOverlay,
    required this.textDefault,
    required this.textMuted,
    required this.textOnAccent,
    required this.textDisabled,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.accentDefault,
    required this.accentHover,
    required this.accentPressed,
    required this.danger,
    required this.success,
    required this.warning,
  });

  final Color surfaceDefault;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color surfaceOverlay;
  final Color textDefault;
  final Color textMuted;
  final Color textOnAccent;
  final Color textDisabled;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderFocus;
  final Color accentDefault;
  final Color accentHover;
  final Color accentPressed;
  final Color danger;
  final Color success;
  final Color warning;

  @override
  AstryxColorTokens copyWith({
    Color? surfaceDefault,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? surfaceOverlay,
    Color? textDefault,
    Color? textMuted,
    Color? textOnAccent,
    Color? textDisabled,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? accentDefault,
    Color? accentHover,
    Color? accentPressed,
    Color? danger,
    Color? success,
    Color? warning,
  }) {
    return AstryxColorTokens(
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      textDefault: textDefault ?? this.textDefault,
      textMuted: textMuted ?? this.textMuted,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textDisabled: textDisabled ?? this.textDisabled,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      accentDefault: accentDefault ?? this.accentDefault,
      accentHover: accentHover ?? this.accentHover,
      accentPressed: accentPressed ?? this.accentPressed,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AstryxColorTokens lerp(covariant AstryxColorTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AstryxColorTokens(
      surfaceDefault: c(surfaceDefault, other.surfaceDefault),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      surfaceOverlay: c(surfaceOverlay, other.surfaceOverlay),
      textDefault: c(textDefault, other.textDefault),
      textMuted: c(textMuted, other.textMuted),
      textOnAccent: c(textOnAccent, other.textOnAccent),
      textDisabled: c(textDisabled, other.textDisabled),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      borderFocus: c(borderFocus, other.borderFocus),
      accentDefault: c(accentDefault, other.accentDefault),
      accentHover: c(accentHover, other.accentHover),
      accentPressed: c(accentPressed, other.accentPressed),
      danger: c(danger, other.danger),
      success: c(success, other.success),
      warning: c(warning, other.warning),
    );
  }
}
