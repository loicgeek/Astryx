import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  final theme = AstryxThemeData.neutral();
  return MaterialApp(
    theme: theme.light,
    home: Scaffold(
      body: Center(child: SizedBox(width: 520, child: child)),
    ),
  );
}

void main() {
  testWidgets(
    'AstryxChatMessage: user plain text + assistant markdown, with role semantics',
    (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AstryxChatMessage(role: AstryxChatRole.user, content: 'Hello'),
              AstryxChatMessage(
                role: AstryxChatRole.assistant,
                content: '# Reply',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Reply'), findsOneWidget); // markdown heading
      expect(find.bySemanticsLabel('You said'), findsOneWidget);
      expect(find.bySemanticsLabel('Assistant said'), findsOneWidget);
    },
  );

  testWidgets('AstryxChatSystemMessage shows its notice', (tester) async {
    await tester.pumpWidget(
      wrap(const AstryxChatSystemMessage('New conversation')),
    );
    expect(find.text('New conversation'), findsOneWidget);
  });

  testWidgets('AstryxChatToolCalls expands to reveal arguments and result', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const AstryxChatToolCalls(
          calls: [
            AstryxToolCall(
              name: 'web_search',
              status: AstryxToolStatus.success,
              arguments: '{"q":"astryx"}',
              result: '3 results',
            ),
          ],
        ),
      ),
    );

    expect(find.text('web_search'), findsOneWidget);
    expect(find.text('done'), findsOneWidget); // success badge
    expect(find.text('3 results'), findsNothing); // collapsed

    await tester.tap(find.text('web_search'));
    await tester.pumpAndSettle();
    expect(find.text('3 results'), findsOneWidget);
    expect(find.text('{"q":"astryx"}'), findsOneWidget);
  });

  testWidgets('AstryxChatComposer sends on Enter, disables send when empty', (
    tester,
  ) async {
    String sent = '';
    await tester.pumpWidget(wrap(AstryxChatComposer(onSend: (t) => sent = t)));

    // Empty → send button disabled.
    expect(
      tester.getSemantics(find.bySemanticsLabel('Send message')),
      matchesSemantics(
        label: 'Send message',
        isButton: true,
        hasEnabledState: true,
      ),
    );

    await tester.enterText(find.byType(EditableText), 'Hi there');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(sent, 'Hi there');
    expect(find.text('Hi there'), findsNothing); // field cleared
  });

  testWidgets('AstryxChatLayout renders messages and the composer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SizedBox(
          height: 400,
          child: AstryxChatLayout(
            messages: const [
              AstryxChatMessage(
                role: AstryxChatRole.user,
                content: 'Question?',
              ),
            ],
            composer: AstryxChatComposer(onSend: (_) {}),
          ),
        ),
      ),
    );

    expect(find.text('Question?'), findsOneWidget);
    expect(find.bySemanticsLabel('Send message'), findsOneWidget);
  });
}
