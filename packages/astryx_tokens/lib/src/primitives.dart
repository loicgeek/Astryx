import 'dart:ui';

import 'package:flutter/animation.dart' show Cubic;

/// Tier-1 primitive tokens — raw, theme-invariant values.
///
/// GENERATED TARGET: these mirror `tokens/core/*.json` and will be emitted by
/// the `build_runner` token generator (`tool/gen_tokens.dart`). Kept as `const`
/// so they are tree-shakeable and zero-cost. Never consume these directly in a
/// component — use the semantic [AstryxColorTokens] etc. so theming works.
abstract final class AstryxPalette {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF0A0A0A);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF7F7F8);
  static const neutral100 = Color(0xFFEDEDF0);
  static const neutral200 = Color(0xFFD9D9DE);
  static const neutral300 = Color(0xFFB9B9C1);
  static const neutral400 = Color(0xFF8E8E99);
  static const neutral500 = Color(0xFF6B6B76);
  static const neutral600 = Color(0xFF52525B);
  static const neutral700 = Color(0xFF3F3F46);
  static const neutral800 = Color(0xFF27272B);
  static const neutral900 = Color(0xFF18181B);
  static const neutral950 = Color(0xFF0F0F11);

  static const blue300 = Color(0xFF8AB4FF);
  static const blue400 = Color(0xFF5C93FF);
  static const blue500 = Color(0xFF2F6BFF);
  static const blue600 = Color(0xFF1E50E6);
  static const blue700 = Color(0xFF183FB4);

  static const red400 = Color(0xFFFF6B6B);
  static const red500 = Color(0xFFE5484D);
  static const red600 = Color(0xFFC23B3F);

  static const green400 = Color(0xFF3DD68C);
  static const green500 = Color(0xFF2FA96F);
  static const green600 = Color(0xFF248257);

  static const amber400 = Color(0xFFFFBF47);
  static const amber500 = Color(0xFFF5A623);
}

/// Tier-1 spacing scale (logical pixels).
abstract final class AstryxSpace {
  static const s0 = 0.0;
  static const s1 = 2.0;
  static const s2 = 4.0;
  static const s3 = 8.0;
  static const s4 = 12.0;
  static const s5 = 16.0;
  static const s6 = 20.0;
  static const s7 = 24.0;
  static const s8 = 32.0;
  static const s9 = 40.0;
  static const s10 = 48.0;
}

/// Tier-1 radius scale (logical pixels).
abstract final class AstryxRadius {
  static const none = 0.0;
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const full = 9999.0;
}

/// Tier-1 motion durations.
abstract final class AstryxDurations {
  static const instant = Duration.zero;
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
}

/// Tier-1 motion easings (cubic-bezier control points from the token JSON).
abstract final class AstryxEasings {
  static const standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  static const accelerate = Cubic(0.4, 0.0, 1.0, 1.0);
}
