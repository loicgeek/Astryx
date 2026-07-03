import 'package:astryx_templates/astryx_templates.dart';
import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: child));
}

void main() {
  testWidgets('AstryxDashboardTemplate renders the title and KPIs', (tester) async {
    await tester.pumpWidget(wrap(const AstryxDashboardTemplate(title: 'Overview')));
    expect(find.text('Overview'), findsWidgets); // heading + side-nav item
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('18,204'), findsOneWidget);
  });

  testWidgets('AstryxSignupFormTemplate submits only with valid email + terms', (tester) async {
    AstryxSignupData? submitted;
    await tester.pumpWidget(wrap(Center(child: AstryxSignupFormTemplate(onSubmit: (d) => submitted = d))));

    // Terms unchecked → submit disabled.
    await tester.tap(find.text('Sign up'));
    expect(submitted, isNull);

    await tester.tap(find.text('I agree to the terms of service'));
    await tester.enterText(find.byType(EditableText), 'ada@astryx.dev');
    await tester.pump();
    await tester.tap(find.text('Sign up'));
    expect(submitted?.email, 'ada@astryx.dev');
    expect(submitted?.acceptedTerms, isTrue);
  });

  testWidgets('AstryxSettingsTemplate toggles a preference switch', (tester) async {
    await tester.pumpWidget(wrap(const Center(child: AstryxSettingsTemplate())));
    expect(find.text('Preferences'), findsOneWidget);
    await tester.tap(find.byType(AstryxSwitch).last); // compact-mode switch
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
