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
  testWidgets('showAstryxDialog opens content and Escape dismisses it', (tester) async {
    await tester.pumpWidget(wrap(Builder(
      builder: (context) => AstryxButton(
        label: 'Open',
        onPressed: () => showAstryxDialog<void>(
          context: context,
          builder: (_) => const AstryxDialog(title: 'Confirm', content: Text('Are you sure?')),
        ),
      ),
    )));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Are you sure?'), findsNothing);
  });

  testWidgets('AstryxTooltip attaches its message to child semantics', (tester) async {
    await tester.pumpWidget(wrap(
      const AstryxTooltip(message: 'More info', child: Icon(Icons.info)),
    ));
    expect(
      tester.getSemantics(find.byIcon(Icons.info)),
      matchesSemantics(tooltip: 'More info', hasLongPressAction: true),
    );
  });

  testWidgets('AstryxTooltip shows a bubble on hover', (tester) async {
    await tester.pumpWidget(wrap(
      const AstryxTooltip(message: 'Bubble text', child: Icon(Icons.help)),
    ));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.help)));
    await tester.pump();
    expect(find.text('Bubble text'), findsOneWidget);
  });

  testWidgets('AstryxPopover opens on tap and dismisses on outside tap', (tester) async {
    await tester.pumpWidget(wrap(
      AstryxPopover(
        anchor: const AstryxBadge('Menu'),
        builder: (_) => const Text('Popover body'),
      ),
    ));

    await tester.tap(find.text('Menu'));
    await tester.pump();
    expect(find.text('Popover body'), findsOneWidget);

    // Tap the full-screen barrier (top-left corner, away from the panel).
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.text('Popover body'), findsNothing);
  });

  testWidgets('showAstryxToast displays a message then auto-dismisses', (tester) async {
    await tester.pumpWidget(wrap(Builder(
      builder: (context) => AstryxButton(
        label: 'Notify',
        onPressed: () => showAstryxToast(context, message: 'Saved', tone: AstryxTone.success,
            duration: const Duration(seconds: 2)),
      ),
    )));

    await tester.tap(find.text('Notify'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);

    // Fire the auto-dismiss timer, then let the exit animation finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });
}
