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
  testWidgets('AstryxSegmentedControl selects on tap and marks the segment selected', (tester) async {
    String value = 'list';
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxSegmentedControl<String>(
        value: value,
        onChanged: (v) => setState(() => value = v),
        segments: const [
          AstryxSegment(value: 'list', label: 'List'),
          AstryxSegment(value: 'grid', label: 'Grid'),
        ],
      ),
    )));

    expect(
      tester.getSemantics(find.bySemanticsLabel('List')),
      matchesSemantics(label: 'List', isButton: true, isSelected: true, isInMutuallyExclusiveGroup: true, hasSelectedState: true, isEnabled: true, hasEnabledState: true, hasTapAction: true),
    );

    await tester.tap(find.text('Grid'));
    await tester.pump();
    expect(value, 'grid');
  });

  testWidgets('AstryxSegmentedControl moves selection with arrow keys', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    String value = 'list';
    await tester.pumpWidget(wrap(StatefulBuilder(
      builder: (context, setState) => AstryxSegmentedControl<String>(
        value: value,
        focusNode: focusNode,
        onChanged: (v) => setState(() => value = v),
        segments: const [
          AstryxSegment(value: 'list', label: 'List'),
          AstryxSegment(value: 'grid', label: 'Grid'),
        ],
      ),
    )));

    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, 'grid');
  });

  testWidgets('AstryxDropdownMenu opens, selects an item, and closes', (tester) async {
    String? picked;
    await tester.pumpWidget(wrap(AstryxDropdownMenu<String>(
      trigger: const AstryxBadge('Actions'),
      onSelected: (v) => picked = v,
      items: const [
        AstryxMenuItem(value: 'edit', label: 'Edit'),
        AstryxMenuItem(value: 'delete', label: 'Delete'),
      ],
    )));

    await tester.tap(find.text('Actions'));
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    expect(picked, 'delete');
    expect(find.text('Delete'), findsNothing); // menu closed
  });

  testWidgets('AstryxDropdownMenu dismisses on Escape', (tester) async {
    await tester.pumpWidget(wrap(AstryxDropdownMenu<String>(
      trigger: const AstryxBadge('Actions'),
      onSelected: (_) {},
      items: const [AstryxMenuItem(value: 'edit', label: 'Edit')],
    )));

    await tester.tap(find.text('Actions'));
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Edit'), findsNothing);
  });
}
