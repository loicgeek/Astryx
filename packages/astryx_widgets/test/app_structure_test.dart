import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: child));
}

AstryxSideNav<String> sideNav(String selected, ValueChanged<String> onSelect) {
  return AstryxSideNav<String>(
    selected: selected,
    onSelect: onSelect,
    sections: const [
      AstryxNavSection(title: 'Main', items: [
        AstryxNavItem(value: 'home', label: 'Home'),
        AstryxNavItem(value: 'settings', label: 'Settings'),
      ]),
    ],
  );
}

void main() {
  testWidgets('AstryxSideNav selects an item and reports selection', (tester) async {
    String selected = 'home';
    await tester.pumpWidget(wrap(SizedBox(
      width: 260,
      height: 400,
      child: StatefulBuilder(
        builder: (context, setState) => sideNav(selected, (v) => setState(() => selected = v)),
      ),
    )));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      matchesSemantics(label: 'Home', isButton: true, isSelected: true, hasSelectedState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(selected, 'settings');
  });

  testWidgets('AstryxResizeHandle emits drag delta and keyboard nudge', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    double delta = 0;
    await tester.pumpWidget(wrap(Center(
      child: SizedBox(
        width: 8,
        height: 200,
        child: AstryxResizeHandle(
          focusNode: focusNode,
          step: 16,
          onResize: (d) => delta += d,
          semanticLabel: 'Resize sidebar',
        ),
      ),
    )));

    await tester.drag(find.byType(AstryxResizeHandle), const Offset(30, 0));
    expect(delta, closeTo(30, 0.5));

    delta = 0;
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(delta, 16);
  });

  testWidgets('AstryxAppShell docks the rail when wide and shows a hamburger when compact', (tester) async {
    Widget shell(double w) => wrap(SizedBox(
          width: w,
          height: 600,
          child: AstryxAppShell(
            breakpoint: 800,
            topNav: const AstryxTopNav(leading: Text('Brand'), items: [Text('Docs')]),
            sideNav: sideNav('home', (_) {}),
            content: const Text('main content'),
          ),
        ));

    // Wide: side nav docked (Home visible), no hamburger, inline items shown.
    await tester.pumpWidget(shell(1000));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Docs'), findsOneWidget);
    expect(find.bySemanticsLabel('Open navigation'), findsNothing);

    // Compact: hamburger appears, inline items hidden.
    await tester.pumpWidget(shell(500));
    await tester.pump();
    expect(find.bySemanticsLabel('Open navigation'), findsOneWidget);
    expect(find.text('Docs'), findsNothing);
  });

  testWidgets('AstryxMegaMenu opens on tap and a link navigates then closes', (tester) async {
    String picked = '';
    await tester.pumpWidget(wrap(Align(
      alignment: Alignment.topLeft,
      child: AstryxMegaMenu(
        label: 'Products',
        columns: [
          AstryxMegaColumn(title: 'Build', links: [
            AstryxMegaLink(label: 'Widgets', description: 'UI kit', onTap: () => picked = 'widgets'),
          ]),
        ],
      ),
    )));

    await tester.tap(find.text('Products'));
    await tester.pump();
    expect(find.text('Widgets'), findsOneWidget);

    await tester.tap(find.text('Widgets'));
    await tester.pump();
    expect(picked, 'widgets');
    expect(find.text('Widgets'), findsNothing);
  });
}
