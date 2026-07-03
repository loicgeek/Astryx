import 'package:flutter/material.dart';

/// Semantic motion roles: named durations + curves (StyleX transition analog).
///
/// The reduced-motion choke point lives in `astryx_foundations`
/// (`AstryxMotion.resolve`), which collapses these durations to zero when the
/// platform requests reduced motion — so components never branch themselves.
@immutable
class AstryxMotionTokens extends ThemeExtension<AstryxMotionTokens> {
  const AstryxMotionTokens({
    required this.durationFast,
    required this.durationNormal,
    required this.durationSlow,
    required this.curveStandard,
    required this.curveEmphasized,
    required this.curveDecelerate,
    required this.curveAccelerate,
  });

  final Duration durationFast;
  final Duration durationNormal;
  final Duration durationSlow;
  final Curve curveStandard;
  final Curve curveEmphasized;
  final Curve curveDecelerate;
  final Curve curveAccelerate;

  @override
  AstryxMotionTokens copyWith({
    Duration? durationFast,
    Duration? durationNormal,
    Duration? durationSlow,
    Curve? curveStandard,
    Curve? curveEmphasized,
    Curve? curveDecelerate,
    Curve? curveAccelerate,
  }) {
    return AstryxMotionTokens(
      durationFast: durationFast ?? this.durationFast,
      durationNormal: durationNormal ?? this.durationNormal,
      durationSlow: durationSlow ?? this.durationSlow,
      curveStandard: curveStandard ?? this.curveStandard,
      curveEmphasized: curveEmphasized ?? this.curveEmphasized,
      curveDecelerate: curveDecelerate ?? this.curveDecelerate,
      curveAccelerate: curveAccelerate ?? this.curveAccelerate,
    );
  }

  // Curves and durations don't meaningfully interpolate across a theme swap;
  // snap at the midpoint. (Colors/spacing carry the visible transition.)
  @override
  AstryxMotionTokens lerp(covariant AstryxMotionTokens? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}
