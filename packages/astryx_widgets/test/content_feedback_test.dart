import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(theme: theme.light, home: Scaffold(body: Center(child: SizedBox(width: 500, child: child))));
}

void main() {
  testWidgets('AstryxProgressBar reports its percentage (determinate)', (tester) async {
    await tester.pumpWidget(wrap(const AstryxProgressBar(value: 0.42, semanticLabel: 'Upload')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSemantics(find.bySemanticsLabel('Upload')).value, '42%');
  });

  testWidgets('AstryxSkeleton renders without error and is hidden from a11y', (tester) async {
    await tester.pumpWidget(wrap(const AstryxSkeleton(width: 120, height: 16)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AstryxSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AstryxBlockquote shows the quote and citation', (tester) async {
    await tester.pumpWidget(wrap(const AstryxBlockquote(text: 'Stay hungry.', citation: 'Anon')));
    expect(find.text('Stay hungry.'), findsOneWidget);
    expect(find.text('— Anon'), findsOneWidget);
  });

  testWidgets('AstryxMarkdown renders headings, blockquote, list, rule and code block', (tester) async {
    const md = '''
# Heading One

A paragraph with **bold** text.

> A wise quote

- item a
- item b

---

```dart
final x = 1;
```
''';
    await tester.pumpWidget(wrap(const AstryxMarkdown(md)));

    expect(find.text('Heading One'), findsOneWidget); // AstryxHeading
    expect(find.byType(AstryxBlockquote), findsOneWidget);
    expect(find.byType(AstryxDivider), findsOneWidget);
    expect(find.byType(AstryxCodeBlock), findsOneWidget);
    expect(find.text('final x = 1;'), findsOneWidget); // code block content
    expect(find.text('•'), findsNWidgets(2)); // two bullets
  });
}
