import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(
    theme: theme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders label and fires onPressed when enabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(
      AstryxButton(label: 'Save', onPressed: () => taps++),
    ));

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(taps, 1);
  });

  testWidgets('disabled button (onPressed == null) does not fire', (tester) async {
    await tester.pumpWidget(wrap(const AstryxButton(label: 'Nope')));
    await tester.tap(find.text('Nope'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes a button semantics node with the label', (tester) async {
    await tester.pumpWidget(wrap(
      AstryxButton(label: 'Submit', onPressed: () {}),
    ));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Submit')),
      matchesSemantics(
        label: 'Submit',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets('loading button shows a progress indicator and is inert', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(
      AstryxButton(label: 'Busy', loading: true, onPressed: () => taps++),
    ));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Busy'));
    expect(taps, 0);
  });

  testWidgets('activates via keyboard (Enter) when focused', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(
      AstryxButton(label: 'Go', onPressed: () => taps++),
    ));

    Focus.of(tester.element(find.text('Go'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
  });
}
