import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog exposes ~10 named themes including neutral and gothic', () {
    final names = AstryxThemeCatalog.specs.map((s) => s.name).toList();
    expect(names.length, greaterThanOrEqualTo(10));
    expect(names, containsAll(['neutral', 'butter', 'brutalist', 'gothic', 'y2k']));
  });

  for (final spec in AstryxThemeCatalog.specs) {
    group('theme "${spec.name}"', () {
      final theme = AstryxThemeCatalog.build(spec);

      test('builds light + dark with all six token extensions', () {
        for (final data in [theme.light, theme.dark]) {
          expect(data.extension<AstryxColorTokens>(), isNotNull);
          expect(data.extension<AstryxSpacingTokens>(), isNotNull);
          expect(data.extension<AstryxShapeTokens>(), isNotNull);
          expect(data.extension<AstryxElevationTokens>(), isNotNull);
          expect(data.extension<AstryxMotionTokens>(), isNotNull);
          expect(data.extension<AstryxTypographyTokens>(), isNotNull);
        }
      });

      test('primary text meets 4.5:1 contrast on surface (light + dark)', () {
        for (final data in [theme.light, theme.dark]) {
          final c = data.extension<AstryxColorTokens>()!;
          expect(
            contrastRatio(c.textDefault, c.surfaceDefault),
            greaterThanOrEqualTo(4.5),
            reason: '${spec.name} textDefault on surface',
          );
        }
      });

      test('on-accent text meets 3:1 contrast on the accent', () {
        for (final data in [theme.light, theme.dark]) {
          final c = data.extension<AstryxColorTokens>()!;
          expect(
            contrastRatio(c.textOnAccent, c.accentDefault),
            greaterThanOrEqualTo(3.0),
            reason: '${spec.name} textOnAccent on accent',
          );
        }
      });
    });
  }

  test('gothic is dark-only: its light variant renders the dark scheme', () {
    final gothic = AstryxThemeCatalog.build(AstryxThemeCatalog.gothic);
    expect(gothic.light.brightness, Brightness.dark);
    final light = gothic.light.extension<AstryxColorTokens>()!;
    final dark = gothic.dark.extension<AstryxColorTokens>()!;
    expect(light.surfaceDefault, dark.surfaceDefault);
  });

  test('brutalist squares off all corners', () {
    final b = AstryxThemeCatalog.build(AstryxThemeCatalog.brutalist);
    final shape = b.light.extension<AstryxShapeTokens>()!;
    expect(shape.radiusControl, BorderRadius.zero);
    expect(shape.radiusCard, BorderRadius.zero);
  });
}
