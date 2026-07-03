/// Concrete Astryx theme bundles. Each theme is an [AstryxThemeData] with
/// light + dark [ThemeData] carrying the full set of token extensions.
///
/// Themes are described compactly as [AstryxThemeSpec]s (seed colors + radius +
/// font) and expanded via [buildAstryxTheme]. See [AstryxThemeCatalog] for the
/// ~10 built-in themes.
library astryx_themes;

export 'src/astryx_theme_data.dart';
export 'src/catalog.dart';
export 'src/neutral.dart' show buildNeutralTheme;
export 'src/scheme.dart' show contrastRatio, deriveScheme, shapeFromUnit;
export 'src/theme_spec.dart' show AstryxThemeSpec, buildAstryxTheme;
