import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery boots, renders buttons, and toggles brightness', (tester) async {
    await tester.pumpWidget(const AstryxGalleryApp());
    await tester.pump();

    // Renders the neutral header + variant buttons.
    expect(find.text('Astryx • neutral'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Danger'), findsOneWidget);

    // Light → Dark toggle flips the app theme without throwing.
    expect(find.text('Dark'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    // Not pumpAndSettle: the loading button's spinner animates forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Light'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
