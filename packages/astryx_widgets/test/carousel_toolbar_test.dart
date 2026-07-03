import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: SizedBox(width: 400, child: child))));
}

void main() {
  testWidgets('AstryxCarousel pages to the next item via the arrow', (tester) async {
    await tester.pumpWidget(wrap(const AstryxCarousel(
      height: 120,
      items: [Text('Slide 1'), Text('Slide 2'), Text('Slide 3')],
    )));

    expect(find.bySemanticsLabel('Carousel, item 1 of 3'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Carousel, item 2 of 3'), findsOneWidget);
    expect(find.text('Slide 2'), findsOneWidget);
  });

  testWidgets('AstryxToolbar renders its controls and they work', (tester) async {
    var bold = 0;
    await tester.pumpWidget(wrap(AstryxToolbar(children: [
      AstryxButton(label: 'Bold', size: AstryxButtonSize.sm, onPressed: () => bold++),
      AstryxToolbar.divider(),
      AstryxButton(label: 'Italic', size: AstryxButtonSize.sm, onPressed: () {}),
    ])));

    expect(find.text('Bold'), findsOneWidget);
    expect(find.text('Italic'), findsOneWidget);
    await tester.tap(find.text('Bold'));
    expect(bold, 1);
  });
}
