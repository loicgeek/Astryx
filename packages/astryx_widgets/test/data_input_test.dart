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
  testWidgets('AstryxCheckbox toggles and exposes checkbox semantics', (tester) async {
    var value = false;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxCheckbox(
        value: value,
        label: 'Accept',
        onChanged: (v) => setState(() => value = v),
      ),
    )));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Accept')),
      matchesSemantics(label: 'Accept', hasCheckedState: true, isEnabled: true, hasEnabledState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('AstryxSwitch toggles on tap', (tester) async {
    var on = false;
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxSwitch(
        value: on,
        semanticLabel: 'Wifi',
        onChanged: (v) => setState(() => on = v),
      ),
    )));

    await tester.tap(find.bySemanticsLabel('Wifi'));
    await tester.pump();
    expect(on, isTrue);
  });

  testWidgets('AstryxTextInput reports typed text', (tester) async {
    var text = '';
    await tester.pumpWidget(wrap(SizedBox(
      width: 300,
      child: AstryxTextInput(hintText: 'Name', onChanged: (v) => text = v),
    )));
    await tester.enterText(find.byType(EditableText), 'Ada');
    expect(text, 'Ada');
  });

  testWidgets('AstryxField announces label with required and shows error', (tester) async {
    await tester.pumpWidget(wrap(SizedBox(
      width: 300,
      child: AstryxField(
        label: 'Email',
        required: true,
        error: 'Invalid address',
        child: const AstryxTextInput(hintText: 'you@example.com'),
      ),
    )));
    expect(find.bySemanticsLabel('Email, required'), findsOneWidget);
    expect(find.text('Invalid address'), findsOneWidget);
  });

  testWidgets('AstryxSlider reports its value and steps up on ArrowRight when focused', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    double value = 0.5;
    await tester.pumpWidget(wrap(SizedBox(
      width: 200,
      child: StatefulBuilder(
        builder: (context, setState) => AstryxSlider(
          value: value,
          divisions: 10,
          focusNode: focusNode,
          semanticLabel: 'Volume',
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    )));

    expect(tester.getSemantics(find.bySemanticsLabel('Volume')).value, '5'); // 0.5 of 10 divisions
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, closeTo(0.6, 1e-9));
  });
}
