import 'package:flutter/widgets.dart' show Color;

import 'astryx_theme_data.dart';
import 'theme_spec.dart';

/// The built-in Astryx theme specs (~10 ready-made themes) and helpers to build
/// them. Each spec is just seed colors + radius + font; [build] expands one into
/// a full [AstryxThemeData].
abstract final class AstryxThemeCatalog {
  static const neutral = AstryxThemeSpec(
    name: 'neutral',
    lightSurface: Color(0xFFFFFFFF), lightText: Color(0xFF18181B), lightAccent: Color(0xFF2F6BFF),
    darkSurface: Color(0xFF0F0F11), darkText: Color(0xFFF7F7F8), darkAccent: Color(0xFF5C93FF),
  );

  static const daily = AstryxThemeSpec(
    name: 'daily',
    lightSurface: Color(0xFFFBFBFD), lightText: Color(0xFF1B1B28), lightAccent: Color(0xFF4F46E5),
    darkSurface: Color(0xFF0E0E16), darkText: Color(0xFFECECF5), darkAccent: Color(0xFF8B83FF),
  );

  static const butter = AstryxThemeSpec(
    name: 'butter',
    lightSurface: Color(0xFFFFFDF5), lightText: Color(0xFF3A2F1E), lightAccent: Color(0xFFE0A400),
    darkSurface: Color(0xFF17130A), darkText: Color(0xFFF5ECD6), darkAccent: Color(0xFFF5C451),
    radiusUnit: 12,
  );

  static const chocolate = AstryxThemeSpec(
    name: 'chocolate',
    lightSurface: Color(0xFFF7F1EC), lightText: Color(0xFF3A2A22), lightAccent: Color(0xFF8B5E3C),
    darkSurface: Color(0xFF17110D), darkText: Color(0xFFEFE3DA), darkAccent: Color(0xFFC98A5E),
  );

  static const matcha = AstryxThemeSpec(
    name: 'matcha',
    lightSurface: Color(0xFFF4F8F1), lightText: Color(0xFF22301F), lightAccent: Color(0xFF3F8F4F),
    darkSurface: Color(0xFF0E150D), darkText: Color(0xFFE6F0E2), darkAccent: Color(0xFF6FBF6F),
    radiusUnit: 12,
  );

  static const stone = AstryxThemeSpec(
    name: 'stone',
    lightSurface: Color(0xFFF6F6F5), lightText: Color(0xFF292723), lightAccent: Color(0xFF64748B),
    darkSurface: Color(0xFF131311), darkText: Color(0xFFEAE8E2), darkAccent: Color(0xFF94A3B8),
    radiusUnit: 4,
  );

  static const gothic = AstryxThemeSpec(
    name: 'gothic',
    // dark-only: light seeds are ignored (light renders the dark scheme).
    lightSurface: Color(0xFF0B0B0D), lightText: Color(0xFFE8E8EC), lightAccent: Color(0xFFA855F7),
    darkSurface: Color(0xFF0B0B0D), darkText: Color(0xFFE8E8EC), darkAccent: Color(0xFFA855F7),
    darkOnly: true,
  );

  static const brutalist = AstryxThemeSpec(
    name: 'brutalist',
    lightSurface: Color(0xFFFFFFFF), lightText: Color(0xFF000000), lightAccent: Color(0xFFFF2D55),
    darkSurface: Color(0xFF000000), darkText: Color(0xFFFFFFFF), darkAccent: Color(0xFFFF2D55),
    radiusUnit: 0,
  );

  static const meta = AstryxThemeSpec(
    name: 'meta',
    lightSurface: Color(0xFFFFFFFF), lightText: Color(0xFF1C2B33), lightAccent: Color(0xFF0064E0),
    darkSurface: Color(0xFF101418), darkText: Color(0xFFE4E6EB), darkAccent: Color(0xFF1B84FF),
    radiusUnit: 12,
  );

  static const whatsapp = AstryxThemeSpec(
    name: 'whatsapp',
    lightSurface: Color(0xFFFFFFFF), lightText: Color(0xFF111B21), lightAccent: Color(0xFF1DA851),
    darkSurface: Color(0xFF0B141A), darkText: Color(0xFFE9EDEF), darkAccent: Color(0xFF21C063),
    radiusUnit: 12,
  );

  static const y2k = AstryxThemeSpec(
    name: 'y2k',
    lightSurface: Color(0xFFFFF0FB), lightText: Color(0xFF2A0A3A), lightAccent: Color(0xFFFF3EA5),
    darkSurface: Color(0xFF14001A), darkText: Color(0xFFFFE6FB), darkAccent: Color(0xFFFF5CC0),
    radiusUnit: 16,
  );

  /// All built-in specs, in display order.
  static const List<AstryxThemeSpec> specs = [
    neutral, daily, butter, chocolate, matcha, stone, gothic, brutalist, meta, whatsapp, y2k,
  ];

  /// Builds a full theme from a spec.
  static AstryxThemeData build(AstryxThemeSpec spec) => buildAstryxTheme(spec);

  /// Builds the theme with [name], or neutral if unknown.
  static AstryxThemeData byName(String name) =>
      build(specs.firstWhere((s) => s.name == name, orElse: () => neutral));
}
