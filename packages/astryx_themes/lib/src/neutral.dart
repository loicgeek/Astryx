import 'astryx_theme_data.dart';
import 'catalog.dart';
import 'theme_spec.dart';

/// The default Astryx theme. Kept as a named entry point; assembly now goes
/// through the shared spec builder.
AstryxThemeData buildNeutralTheme() => buildAstryxTheme(AstryxThemeCatalog.neutral);
