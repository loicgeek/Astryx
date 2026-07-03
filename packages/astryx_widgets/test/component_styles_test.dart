import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _themeRed = Color(0xFFAB00AB);
const _instanceGreen = Color(0xFF00AA55);

ThemeData themeWith(AstryxComponentStyles styles) {
  final base = AstryxThemeData.neutral().light;
  return base.copyWith(extensions: [...base.extensions.values, styles]);
}

Color buttonBg(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: find.byType(AstryxButton), matching: find.byType(AnimatedContainer)),
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('theme-level AstryxComponentStyles restyles every button', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: themeWith(const AstryxComponentStyles(button: AstryxButtonStyle(background: _themeRed))),
      home: Scaffold(body: Center(child: AstryxButton(label: 'X', onPressed: () {}))),
    ));
    expect(buttonBg(tester), _themeRed);
  });

  testWidgets('per-instance style wins over the theme-level style', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: themeWith(const AstryxComponentStyles(button: AstryxButtonStyle(background: _themeRed))),
      home: Scaffold(
        body: Center(
          child: AstryxButton(
            label: 'X',
            style: const AstryxButtonStyle(background: _instanceGreen),
            onPressed: () {},
          ),
        ),
      ),
    ));
    expect(buttonBg(tester), _instanceGreen);
  });
}
