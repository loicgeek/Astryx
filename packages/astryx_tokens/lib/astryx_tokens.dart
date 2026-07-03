/// Astryx design tokens for Flutter.
///
/// Two tiers:
///  - Primitives ([AstryxPalette], [AstryxSpace], …) — `const`, theme-invariant.
///  - Semantic [ThemeExtension]s ([AstryxColorTokens], …) — theme-driven, read
///    via [BuildContext.tokens].
library astryx_tokens;

export 'src/color_tokens.dart';
export 'src/motion_tokens.dart';
export 'src/primitives.dart';
export 'src/scale_tokens.dart';
export 'src/tokens.dart';
export 'src/typography_tokens.dart';
