import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('AstryxBreadcrumbs links navigate; last crumb is the current page', (tester) async {
    var tapped = '';
    await tester.pumpWidget(wrap(AstryxBreadcrumbs(items: [
      AstryxCrumb(label: 'Home', onTap: () => tapped = 'Home'),
      AstryxCrumb(label: 'Projects', onTap: () => tapped = 'Projects'),
      const AstryxCrumb(label: 'Astryx'),
    ])));

    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    expect(find.bySemanticsLabel('Astryx, current page'), findsOneWidget);
    await tester.tap(find.text('Projects'));
    expect(tapped, 'Projects');
  });

  testWidgets('AstryxPagination windows pages and changes on tap / next', (tester) async {
    int page = 1;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxPagination(
        page: page,
        pageCount: 20,
        onChanged: (p) => setState(() => page = p),
      ),
    )));

    // 20 pages, current 1 → shows 1,2,…,20 with an ellipsis.
    expect(find.text('…'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Next page'));
    await tester.pump();
    expect(page, 2);

    await tester.tap(find.bySemanticsLabel('Page 20'));
    await tester.pump();
    expect(page, 20);
  });

  testWidgets('AstryxTabList selects on tap and moves with arrow keys', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    String value = 'overview';
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxTabList<String>(
        value: value,
        focusNode: focusNode,
        onChanged: (v) => setState(() => value = v),
        tabs: const [
          AstryxTab(value: 'overview', label: 'Overview'),
          AstryxTab(value: 'activity', label: 'Activity'),
          AstryxTab(value: 'settings', label: 'Settings'),
        ],
      ),
    )));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Overview')),
      matchesSemantics(label: 'Overview', isButton: true, isSelected: true, hasSelectedState: true, isEnabled: true, hasEnabledState: true, hasTapAction: true),
    );

    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(value, 'settings');

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 'overview'); // wraps from settings → overview
  });
}
