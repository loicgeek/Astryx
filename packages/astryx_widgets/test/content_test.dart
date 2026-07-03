import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('AstryxText renders its data', (tester) async {
    await tester.pumpWidget(wrap(const AstryxText('Hello Astryx')));
    expect(find.text('Hello Astryx'), findsOneWidget);
  });

  testWidgets('AstryxHeading exposes a header semantics node', (tester) async {
    await tester.pumpWidget(wrap(const AstryxHeading('Settings')));
    expect(
      tester.getSemantics(find.text('Settings')),
      matchesSemantics(label: 'Settings', isHeader: true),
    );
  });

  testWidgets('AstryxAvatar derives initials and exposes its label', (tester) async {
    await tester.pumpWidget(wrap(const AstryxAvatar(initials: 'Ada Lovelace', label: 'Ada Lovelace')));
    expect(find.text('AL'), findsOneWidget);
    expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
  });

  testWidgets('AstryxCode renders monospace content', (tester) async {
    await tester.pumpWidget(wrap(const AstryxCode('const x = 1;')));
    expect(find.text('const x = 1;'), findsOneWidget);
  });
}
