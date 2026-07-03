import 'package:flutter/material.dart';

import '../action/button/astryx_button_style.dart';

/// Theme-level per-component style overrides — the "restyle every Button in the
/// app" mechanism (a CSS rule, without forking widgets). Attach it to a theme
/// via `ThemeData.extensions` (or `copyWith`); each component merges its entry
/// between the token default and the per-instance override:
///
///   tokens ⊕ themeComponentStyle ⊕ instanceStyle
@immutable
class AstryxComponentStyles extends ThemeExtension<AstryxComponentStyles> {
  const AstryxComponentStyles({this.button});

  /// Default style applied to every [AstryxButton] unless overridden per-instance.
  final AstryxButtonStyle? button;

  /// The component styles from the nearest theme, if any.
  static AstryxComponentStyles? of(BuildContext context) =>
      Theme.of(context).extension<AstryxComponentStyles>();

  @override
  AstryxComponentStyles copyWith({AstryxButtonStyle? button}) =>
      AstryxComponentStyles(button: button ?? this.button);

  // Styles hold discrete values that don't meaningfully interpolate; snap at
  // the midpoint so a theme swap still resolves cleanly.
  @override
  AstryxComponentStyles lerp(covariant AstryxComponentStyles? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}
