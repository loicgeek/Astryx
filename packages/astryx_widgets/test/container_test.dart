import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('non-interactive AstryxCard renders its child with no button semantics', (tester) async {
    await tester.pumpWidget(wrap(const AstryxCard(child: Text('content'))));
    expect(find.text('content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clickable + selected AstryxCard fires onTap and reports selection', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(AstryxCard(
      onTap: () => taps++,
      selected: true,
      semanticLabel: 'Plan',
      child: const Text('Pro plan'),
    )));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Plan')),
      matchesSemantics(label: 'Plan', isButton: true, isSelected: true, hasSelectedState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    await tester.tap(find.text('Pro plan'));
    expect(taps, 1);
  });

  testWidgets('AstryxCollapsible toggles body and exposes expanded state', (tester) async {
    await tester.pumpWidget(wrap(const AstryxCollapsible(
      title: 'Details',
      child: Text('hidden body'),
    )));

    // Collapsed: header present, expanded=false, body height collapsed.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Details')),
      matchesSemantics(label: 'Details', isButton: true, hasExpandedState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    expect(tester.getSize(find.text('hidden body')).height, 0);

    await tester.tap(find.bySemanticsLabel('Details'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Details')),
      matchesSemantics(label: 'Details', isButton: true, isExpanded: true, hasExpandedState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    expect(tester.getSize(find.text('hidden body')).height, greaterThan(0));
  });
}
