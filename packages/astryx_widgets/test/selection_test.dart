import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

const _fruits = ['Apple', 'Apricot', 'Banana', 'Cherry'];
List<String> _match(String q) =>
    _fruits.where((f) => f.toLowerCase().contains(q.toLowerCase())).toList();

void main() {
  testWidgets('AstryxTypeahead filters on type and selects on tap', (tester) async {
    String? picked;
    await tester.pumpWidget(wrap(SizedBox(
      width: 300,
      child: AstryxTypeahead<String>(
        suggestions: _match,
        itemLabel: (s) => s,
        onSelected: (s) => picked = s,
      ),
    )));

    await tester.enterText(find.byType(EditableText), 'ap');
    await tester.pump();
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apricot'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);

    await tester.tap(find.text('Apricot'));
    await tester.pump();
    expect(picked, 'Apricot');
  });

  testWidgets('AstryxTypeahead moves highlight with ArrowDown and submits it', (tester) async {
    String? picked;
    await tester.pumpWidget(wrap(SizedBox(
      width: 300,
      child: AstryxTypeahead<String>(
        suggestions: _match,
        itemLabel: (s) => s,
        onSelected: (s) => picked = s,
      ),
    )));

    await tester.enterText(find.byType(EditableText), 'ap');
    await tester.pump();
    // First match highlighted; ArrowDown moves to the second.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Apricot')),
      matchesSemantics(label: 'Apricot', isButton: true, isSelected: true, hasSelectedState: true, hasTapAction: true),
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(picked, 'Apricot');
  });

  testWidgets('AstryxTypeahead closes its suggestions when focus leaves the field', (tester) async {
    final other = FocusNode();
    addTearDown(other.dispose);
    await tester.pumpWidget(wrap(Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 300,
        child: AstryxTypeahead<String>(suggestions: _match, itemLabel: (s) => s, onSelected: (_) {}),
      ),
      Focus(focusNode: other, child: const SizedBox(width: 10, height: 10)),
    ])));

    await tester.enterText(find.byType(EditableText), 'ap');
    await tester.pump();
    expect(find.text('Apple'), findsOneWidget);

    // Focus elsewhere (simulates an outside tap) → suggestions close.
    other.requestFocus();
    await tester.pump();
    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('AstryxMultiSelector toggles options in the checklist', (tester) async {
    Set<String> selected = {};
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxMultiSelector<String>(
        selected: selected,
        onChanged: (s) => setState(() => selected = s),
        options: const [
          AstryxSelectOption(value: 'a', label: 'Alpha'),
          AstryxSelectOption(value: 'b', label: 'Beta'),
          AstryxSelectOption(value: 'c', label: 'Gamma'),
        ],
      ),
    )));

    await tester.tap(find.text('Select…'));
    await tester.pump();
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'b'});
    // Trigger now summarizes the single selection.
    expect(find.text('Beta'), findsWidgets);
  });

  testWidgets('AstryxTokenizer adds on comma and removes via chip + backspace', (tester) async {
    List<String> value = [];
    await tester.pumpWidget(wrap(SizedBox(
      width: 320,
      child: StatefulBuilder(
        builder: (context, setState) => AstryxTokenizer(
          value: value,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    )));

    await tester.enterText(find.byType(EditableText), 'red,');
    await tester.pump();
    expect(value, ['red']);
    expect(find.text('red'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'blue,');
    await tester.pump();
    expect(value, ['red', 'blue']);

    // Remove 'red' via its chip button.
    await tester.tap(find.bySemanticsLabel('Remove red'));
    await tester.pump();
    expect(value, ['blue']);

    // Backspace on the empty field removes the last token.
    await tester.tap(find.byType(AstryxTokenizer));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(value, isEmpty);
  });
}
