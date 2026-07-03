import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: child)));
}

void main() {
  testWidgets('AstryxBadge renders its label', (tester) async {
    await tester.pumpWidget(wrap(const AstryxBadge('New', tone: AstryxTone.accent)));
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('AstryxStatusDot exposes its label (never color-alone)', (tester) async {
    await tester.pumpWidget(wrap(const AstryxStatusDot(tone: AstryxTone.success, label: 'Online')));
    expect(find.bySemanticsLabel('Online'), findsOneWidget);
  });

  testWidgets('AstryxBanner announces via a live region and supports dismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(wrap(AstryxBanner(
      title: 'Heads up',
      message: 'Your trial ends soon.',
      tone: AstryxTone.warning,
      onDismiss: () => dismissed = true,
    )));

    expect(find.bySemanticsLabel('Heads up. Your trial ends soon.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Dismiss'));
    expect(dismissed, isTrue);
  });

  testWidgets('AstryxSpinner announces a busy state', (tester) async {
    await tester.pumpWidget(wrap(const AstryxSpinner(label: 'Saving')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel('Saving'), findsOneWidget);
  });
}
