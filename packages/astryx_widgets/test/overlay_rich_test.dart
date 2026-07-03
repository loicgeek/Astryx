import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('command palette opens, filters, and runs a command on tap', (tester) async {
    final ran = <String>[];
    await tester.pumpWidget(wrap(Builder(
      builder: (context) => AstryxButton(
        label: 'Open',
        onPressed: () => showAstryxCommandPalette(context, commands: [
          AstryxCommand(label: 'New file', onRun: () => ran.add('new')),
          AstryxCommand(label: 'Open settings', onRun: () => ran.add('settings')),
          AstryxCommand(label: 'Close tab', onRun: () => ran.add('close')),
        ]),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('New file'), findsOneWidget);
    expect(find.text('Close tab'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'set');
    await tester.pump();
    expect(find.text('New file'), findsNothing);
    expect(find.text('Open settings'), findsOneWidget);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(ran, ['settings']);
    expect(find.text('Open settings'), findsNothing); // closed
  });

  testWidgets('command palette moves highlight with ArrowDown and closes on Escape', (tester) async {
    await tester.pumpWidget(wrap(Builder(
      builder: (context) => AstryxButton(
        label: 'Open',
        onPressed: () => showAstryxCommandPalette(context, commands: [
          AstryxCommand(label: 'Alpha', onRun: () {}),
          AstryxCommand(label: 'Beta', onRun: () {}),
        ]),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Beta')),
      matchesSemantics(label: 'Beta', isButton: true, isSelected: true, hasSelectedState: true, hasTapAction: true),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('AstryxHoverCard opens on hover after a delay and closes on exit', (tester) async {
    await tester.pumpWidget(wrap(const AstryxHoverCard(
      openDelay: Duration(milliseconds: 100),
      card: Text('Rich content'),
      child: Text('Profile'),
    )));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.moveTo(tester.getCenter(find.text('Profile')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Rich content'), findsOneWidget);

    await gesture.moveTo(const Offset(600, 20));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Rich content'), findsNothing);
  });

  testWidgets('showAstryxLightbox pages items and closes on Escape', (tester) async {
    await tester.pumpWidget(wrap(Builder(
      builder: (context) => AstryxButton(
        label: 'View',
        onPressed: () => showAstryxLightbox(context, items: const [Text('Photo A'), Text('Photo B')]),
      ),
    )));

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Photo A'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Photo A'), findsNothing);
  });
}
