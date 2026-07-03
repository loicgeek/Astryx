import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.chatmetadata}
/// The small line beneath a chat message: an optional [timestamp] and [model]
/// name, plus trailing [actions] (copy, regenerate, feedback…). Kept muted so
/// it recedes behind the message.
/// {@endtemplate}
class AstryxChatMessageMetadata extends StatelessWidget {
  const AstryxChatMessageMetadata({
    super.key,
    this.timestamp,
    this.model,
    this.actions = const [],
  });

  final String? timestamp;
  final String? model;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final parts = <String>[
      if (timestamp != null) timestamp!,
      if (model != null) model!,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: t.spacing.gapMd,
      children: [
        if (parts.isNotEmpty)
          Text(parts.join(' · '), style: t.typography.label.copyWith(color: t.color.textMuted, fontSize: 11)),
        for (final action in actions) action,
      ],
    );
  }
}
