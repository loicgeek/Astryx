import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

final _today = DateTime(2026, 7, 3);

void main() {
  test('AstryxDates.addDays is DST-safe across US transitions', () {
    // US 2026 spring-forward (Mar 8, a 23h day) and fall-back (Nov 1, a 25h day).
    // Duration-based math would drift here; component math must not.
    expect(AstryxDates.addDays(DateTime(2026, 3, 8), 1), DateTime(2026, 3, 9));
    expect(AstryxDates.addDays(DateTime(2026, 11, 1), 1), DateTime(2026, 11, 2));
    // A week step straddling fall-back.
    expect(AstryxDates.addDays(DateTime(2026, 10, 28), 7), DateTime(2026, 11, 4));
    // Round-trip and month rollover.
    expect(AstryxDates.addDays(AstryxDates.addDays(DateTime(2026, 3, 8), 5), -5), DateTime(2026, 3, 8));
    expect(AstryxDates.addDays(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 1));
  });

  testWidgets('AstryxCalendar selects a day on tap and exposes day semantics', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(wrap(AstryxCalendar(
      today: _today,
      onChanged: (d) => picked = d,
    )));

    // The header shows the current month; today (July 3) is labeled as such.
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('July 3, 2026, today'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('July 15, 2026'));
    expect(picked, DateTime(2026, 7, 15));
  });

  testWidgets('AstryxCalendar navigates months and moves focus with arrows', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    DateTime? picked;
    await tester.pumpWidget(wrap(AstryxCalendar(
      today: _today,
      focusNode: focusNode,
      value: DateTime(2026, 7, 10),
      onChanged: (d) => picked = d,
    )));

    // Next month → focus resets to the 1st of the visible month.
    await tester.tap(find.bySemanticsLabel('Next month'));
    await tester.pump();
    expect(find.text('August 2026'), findsOneWidget);

    // Focus the grid, ArrowRight (Aug 1 → Aug 2) then Enter selects it.
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(picked, DateTime(2026, 8, 2));
  });

  testWidgets('AstryxDateInput opens a calendar and reports the picked date', (tester) async {
    DateTime? picked;
    await tester.pumpWidget(wrap(AstryxDateInput(
      today: _today,
      onChanged: (d) => picked = d,
    )));

    expect(find.text('Select a date'), findsOneWidget);
    await tester.tap(find.text('Select a date'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('July 9, 2026'));
    await tester.pump();
    expect(picked, DateTime(2026, 7, 9));
    // Popover closed after selection.
    expect(find.text('July 2026'), findsNothing);
  });

  testWidgets('AstryxTimeInput opens a time list and reports the picked time', (tester) async {
    AstryxTimeOfDay? picked;
    await tester.pumpWidget(wrap(AstryxTimeInput(
      intervalMinutes: 60,
      onChanged: (v) => picked = v,
    )));

    await tester.tap(find.text('Select a time'));
    await tester.pump();
    // 02:00 is near the top of the scrollable list (visible without scrolling).
    await tester.tap(find.bySemanticsLabel('02:00'));
    await tester.pump();
    expect(picked, const AstryxTimeOfDay(2, 0));
  });
}
