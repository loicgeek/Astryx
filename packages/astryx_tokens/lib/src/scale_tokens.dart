import 'package:flutter/material.dart';

/// Semantic spacing roles. Named by intent, not raw size, so density can be
/// retuned per theme without touching components.
@immutable
class AstryxSpacingTokens extends ThemeExtension<AstryxSpacingTokens> {
  const AstryxSpacingTokens({
    required this.insetXs,
    required this.insetSm,
    required this.insetMd,
    required this.insetLg,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  final double insetXs;
  final double insetSm;
  final double insetMd;
  final double insetLg;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  @override
  AstryxSpacingTokens copyWith({
    double? insetXs,
    double? insetSm,
    double? insetMd,
    double? insetLg,
    double? gapSm,
    double? gapMd,
    double? gapLg,
  }) {
    return AstryxSpacingTokens(
      insetXs: insetXs ?? this.insetXs,
      insetSm: insetSm ?? this.insetSm,
      insetMd: insetMd ?? this.insetMd,
      insetLg: insetLg ?? this.insetLg,
      gapSm: gapSm ?? this.gapSm,
      gapMd: gapMd ?? this.gapMd,
      gapLg: gapLg ?? this.gapLg,
    );
  }

  @override
  AstryxSpacingTokens lerp(covariant AstryxSpacingTokens? other, double t) {
    if (other == null) return this;
    double d(double a, double b) => lerpDouble(a, b, t);
    return AstryxSpacingTokens(
      insetXs: d(insetXs, other.insetXs),
      insetSm: d(insetSm, other.insetSm),
      insetMd: d(insetMd, other.insetMd),
      insetLg: d(insetLg, other.insetLg),
      gapSm: d(gapSm, other.gapSm),
      gapMd: d(gapMd, other.gapMd),
      gapLg: d(gapLg, other.gapLg),
    );
  }
}

/// Semantic shape roles (corner radii).
@immutable
class AstryxShapeTokens extends ThemeExtension<AstryxShapeTokens> {
  const AstryxShapeTokens({
    required this.radiusControl,
    required this.radiusCard,
    required this.radiusOverlay,
    required this.radiusPill,
  });

  final BorderRadius radiusControl;
  final BorderRadius radiusCard;
  final BorderRadius radiusOverlay;
  final BorderRadius radiusPill;

  @override
  AstryxShapeTokens copyWith({
    BorderRadius? radiusControl,
    BorderRadius? radiusCard,
    BorderRadius? radiusOverlay,
    BorderRadius? radiusPill,
  }) {
    return AstryxShapeTokens(
      radiusControl: radiusControl ?? this.radiusControl,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusOverlay: radiusOverlay ?? this.radiusOverlay,
      radiusPill: radiusPill ?? this.radiusPill,
    );
  }

  @override
  AstryxShapeTokens lerp(covariant AstryxShapeTokens? other, double t) {
    if (other == null) return this;
    return AstryxShapeTokens(
      radiusControl: BorderRadius.lerp(radiusControl, other.radiusControl, t)!,
      radiusCard: BorderRadius.lerp(radiusCard, other.radiusCard, t)!,
      radiusOverlay: BorderRadius.lerp(radiusOverlay, other.radiusOverlay, t)!,
      radiusPill: BorderRadius.lerp(radiusPill, other.radiusPill, t)!,
    );
  }
}

/// Semantic elevation roles → box-shadow stacks (StyleX elevation analog).
@immutable
class AstryxElevationTokens extends ThemeExtension<AstryxElevationTokens> {
  const AstryxElevationTokens({
    required this.flat,
    required this.raised,
    required this.overlay,
  });

  final List<BoxShadow> flat;
  final List<BoxShadow> raised;
  final List<BoxShadow> overlay;

  @override
  AstryxElevationTokens copyWith({
    List<BoxShadow>? flat,
    List<BoxShadow>? raised,
    List<BoxShadow>? overlay,
  }) {
    return AstryxElevationTokens(
      flat: flat ?? this.flat,
      raised: raised ?? this.raised,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AstryxElevationTokens lerp(covariant AstryxElevationTokens? other, double t) {
    if (other == null) return this;
    return AstryxElevationTokens(
      flat: BoxShadow.lerpList(flat, other.flat, t) ?? const [],
      raised: BoxShadow.lerpList(raised, other.raised, t) ?? const [],
      overlay: BoxShadow.lerpList(overlay, other.overlay, t) ?? const [],
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
