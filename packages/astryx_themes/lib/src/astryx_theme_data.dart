import 'package:flutter/material.dart';

import 'neutral.dart';

/// A complete Astryx theme = light + dark [ThemeData], each carrying the full
/// set of semantic token [ThemeExtension]s. Because components read only
/// semantic tokens, one bundle drives every component.
@immutable
class AstryxThemeData {
  const AstryxThemeData({required this.light, required this.dark, required this.name});

  final String name;
  final ThemeData light;
  final ThemeData dark;

  /// Picks the variant for the ambient brightness.
  ThemeData resolve(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// The default Astryx theme. Assembly lives in neutral.dart.
  factory AstryxThemeData.neutral() => buildNeutralTheme();
}
