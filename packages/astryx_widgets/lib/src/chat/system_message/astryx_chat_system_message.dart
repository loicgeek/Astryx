import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.chatsystemmessage}
/// A centered, muted notice in a conversation (e.g. "New conversation",
/// "Model switched to …"), flanked by hairlines.
/// {@endtemplate}
class AstryxChatSystemMessage extends StatelessWidget {
  const AstryxChatSystemMessage(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget rule() => Expanded(child: Container(height: 1, color: t.color.borderDefault));
    return Semantics(
      label: text,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.spacing.gapMd),
        child: Row(
          children: [
            rule(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd),
              child: ExcludeSemantics(
                child: Text(text, style: t.typography.label.copyWith(color: t.color.textMuted)),
              ),
            ),
            rule(),
          ],
        ),
      ),
    );
  }
}
