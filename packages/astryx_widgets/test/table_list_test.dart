import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: SizedBox(width: 500, child: child))));
}

void main() {
  testWidgets('AstryxList renders rows and fires onTap with selected semantics', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(AstryxList(items: [
      AstryxListItem(title: 'Inbox', subtitle: '12 unread', selected: true, onTap: () => taps++),
      const AstryxListItem(title: 'Archive'),
    ])));

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('12 unread'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Inbox')),
      matchesSemantics(label: 'Inbox', isButton: true, isSelected: true, hasSelectedState: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    await tester.tap(find.text('Inbox'));
    expect(taps, 1);
  });

  testWidgets('AstryxTable sorts on header tap and selects a row on tap', (tester) async {
    int? sortedCol;
    int? tappedRow;
    await tester.pumpWidget(wrap(AstryxTable(
      sortColumnIndex: 0,
      sortDirection: AstryxSortDirection.ascending,
      onSort: (c) => sortedCol = c,
      columns: const [
        AstryxColumn(label: 'Name', sortable: true),
        AstryxColumn(label: 'Size', numeric: true, sortable: true),
      ],
      rows: [
        AstryxRow(cells: const [Text('report.pdf'), Text('2 MB')], onTap: () => tappedRow = 0),
        const AstryxRow(cells: [Text('notes.txt'), Text('4 KB')]),
      ],
    )));

    expect(find.text('report.pdf'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Sort by Size'));
    expect(sortedCol, 1);
    await tester.tap(find.text('report.pdf'));
    expect(tappedRow, 0);
  });

  testWidgets('AstryxTreeList expands a branch and selects a leaf', (tester) async {
    Object? selected;
    await tester.pumpWidget(wrap(AstryxTreeList(
      onSelect: (v) => selected = v,
      roots: const [
        AstryxTreeNode(label: 'src', value: 'src', children: [
          AstryxTreeNode(label: 'main.dart', value: 'main'),
          AstryxTreeNode(label: 'app.dart', value: 'app'),
        ]),
      ],
    )));

    // Collapsed: children hidden; branch reports expanded=false.
    expect(find.text('main.dart'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('src')),
      matchesSemantics(label: 'src', isButton: true, hasExpandedState: true, hasSelectedState: true, hasTapAction: true),
    );

    await tester.tap(find.text('src'));
    await tester.pumpAndSettle();
    expect(find.text('main.dart'), findsOneWidget);

    await tester.tap(find.text('app.dart'));
    await tester.pump();
    expect(selected, 'app');
  });
}
