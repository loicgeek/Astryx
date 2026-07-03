import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Visual variant of an [AstryxButton]. Maps to semantic color roles.
enum AstryxButtonVariant { primary, secondary, ghost, danger }

/// Size preset controlling height, padding, and label style.
enum AstryxButtonSize { sm, md, lg }

/// Per-instance style override for [AstryxButton] — the type-safe, mergeable
/// equivalent of Astryx's `className`/`xstyle`. Any non-null field wins over the
/// token/variant default. Structural changes use the widget's builder slots,
/// not this object (paint → style, structure → slots).
@immutable
class AstryxButtonStyle {
  const AstryxButtonStyle({
    this.background,
    this.backgroundHover,
    this.backgroundPressed,
    this.foreground,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.labelStyle,
    this.minHeight,
  });

  final Color? background;
  final Color? backgroundHover;
  final Color? backgroundPressed;
  final Color? foreground;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final double? minHeight;

  AstryxButtonStyle copyWith({
    Color? background,
    Color? backgroundHover,
    Color? backgroundPressed,
    Color? foreground,
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? labelStyle,
    double? minHeight,
  }) {
    return AstryxButtonStyle(
      background: background ?? this.background,
      backgroundHover: backgroundHover ?? this.backgroundHover,
      backgroundPressed: backgroundPressed ?? this.backgroundPressed,
      foreground: foreground ?? this.foreground,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      labelStyle: labelStyle ?? this.labelStyle,
      minHeight: minHeight ?? this.minHeight,
    );
  }

  /// `other` wins where it defines a value.
  AstryxButtonStyle merge(AstryxButtonStyle? other) {
    if (other == null) return this;
    return copyWith(
      background: other.background,
      backgroundHover: other.backgroundHover,
      backgroundPressed: other.backgroundPressed,
      foreground: other.foreground,
      borderColor: other.borderColor,
      borderRadius: other.borderRadius,
      padding: other.padding,
      labelStyle: other.labelStyle,
      minHeight: other.minHeight,
    );
  }

  /// Builds the resolved default style from tokens for a given variant/size,
  /// then merges the per-instance [override] on top (precedence: token default
  /// ⊕ instance override).
  static AstryxButtonStyle resolve(
    BuildContext context, {
    required AstryxButtonVariant variant,
    required AstryxButtonSize size,
    AstryxButtonStyle? override,
  }) {
    final t = context.tokens;
    final c = t.color;

    final (bg, bgHover, bgPressed, fg, border) = switch (variant) {
      AstryxButtonVariant.primary => (
          c.accentDefault,
          c.accentHover,
          c.accentPressed,
          c.textOnAccent,
          null,
        ),
      AstryxButtonVariant.secondary => (
          c.surfaceRaised,
          c.surfaceSunken,
          c.surfaceSunken,
          c.textDefault,
          c.borderDefault,
        ),
      AstryxButtonVariant.ghost => (
          const Color(0x00000000),
          c.surfaceSunken,
          c.surfaceSunken,
          c.textDefault,
          null,
        ),
      AstryxButtonVariant.danger => (
          c.danger,
          c.danger,
          c.danger,
          c.textOnAccent,
          null,
        ),
    };

    final (padH, padV, minH, label) = switch (size) {
      AstryxButtonSize.sm => (t.spacing.insetSm, t.spacing.insetXs, 32.0, t.typography.label),
      AstryxButtonSize.md => (t.spacing.insetMd, t.spacing.insetSm, 40.0, t.typography.label),
      AstryxButtonSize.lg => (t.spacing.insetLg, t.spacing.insetMd, 48.0, t.typography.body),
    };

    final base = AstryxButtonStyle(
      background: bg,
      backgroundHover: bgHover,
      backgroundPressed: bgPressed,
      foreground: fg,
      borderColor: border,
      borderRadius: t.shape.radiusControl,
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      labelStyle: label.copyWith(color: fg, fontWeight: FontWeight.w600),
      minHeight: minH,
    );
    return base.merge(override);
  }
}
