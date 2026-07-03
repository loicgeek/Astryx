import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';

/// Single reduced-motion choke point. Every component animates through this,
/// so honoring `MediaQuery.disableAnimations` / reduced-motion is automatic —
/// no per-widget branching.
abstract final class AstryxMotion {
  /// The motion tokens for [context], with all durations collapsed to zero when
  /// the platform requests reduced/disabled animations.
  static AstryxMotionTokens resolve(BuildContext context) {
    final motion = context.tokens.motion;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduce) return motion;
    return motion.copyWith(
      durationFast: Duration.zero,
      durationNormal: Duration.zero,
      durationSlow: Duration.zero,
    );
  }
}
