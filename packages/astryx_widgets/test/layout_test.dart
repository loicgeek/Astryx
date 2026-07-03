import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child, {Size size = const Size(1000, 800)}) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(
    theme: theme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('AstryxSection renders a header title, description and child', (tester) async {
    await tester.pumpWidget(wrap(const AstryxSection(
      title: 'Members',
      description: 'People with access',
      child: Text('body'),
    )));

    expect(tester.getSemantics(find.text('Members')), matchesSemantics(label: 'Members', isHeader: true));
    expect(find.text('People with access'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('AstryxGrid sizes items into equal columns for the width', (tester) async {
    await tester.pumpWidget(wrap(
      AstryxGrid(
        columns: const ResponsiveValue<int>(xs: 2),
        gap: 10,
        children: List.generate(4, (i) => Text('cell$i')),
      ),
      size: const Size(410, 400), // 2 cols, gap 10 → item width 200
    ));

    expect(find.text('cell0'), findsOneWidget);
    expect(find.text('cell3'), findsOneWidget);
    final itemBox = find.ancestor(of: find.text('cell0'), matching: find.byType(SizedBox)).first;
    expect(tester.getSize(itemBox).width, closeTo(200, 0.5));
  });

  testWidgets('AstryxDivider with a label shows the caption', (tester) async {
    await tester.pumpWidget(wrap(const AstryxDivider(label: 'OR')));
    expect(find.text('OR'), findsOneWidget);
  });
}
