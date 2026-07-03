import 'package:flutter/material.dart';

/// Semantic typography roles. Each theme may swap the family (e.g. brutalist,
/// y2k) while components keep referencing the same named styles.
@immutable
class AstryxTypographyTokens extends ThemeExtension<AstryxTypographyTokens> {
  const AstryxTypographyTokens({
    required this.display,
    required this.heading,
    required this.body,
    required this.label,
    required this.code,
  });

  final TextStyle display;
  final TextStyle heading;
  final TextStyle body;
  final TextStyle label;
  final TextStyle code;

  @override
  AstryxTypographyTokens copyWith({
    TextStyle? display,
    TextStyle? heading,
    TextStyle? body,
    TextStyle? label,
    TextStyle? code,
  }) {
    return AstryxTypographyTokens(
      display: display ?? this.display,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      label: label ?? this.label,
      code: code ?? this.code,
    );
  }

  @override
  AstryxTypographyTokens lerp(covariant AstryxTypographyTokens? other, double t) {
    if (other == null) return this;
    return AstryxTypographyTokens(
      display: TextStyle.lerp(display, other.display, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      code: TextStyle.lerp(code, other.code, t)!,
    );
  }
}
