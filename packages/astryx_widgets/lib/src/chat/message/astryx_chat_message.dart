import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../content/markdown/astryx_markdown.dart';
import '../../content/text/astryx_text.dart';

/// Who authored a chat message.
enum AstryxChatRole { user, assistant }

/// {@template astryx.chatmessage}
/// A single chat bubble. `user` messages align right in an accent bubble with
/// plain text; `assistant` messages align left with an [avatar], render their
/// content as Markdown, and can show [toolCalls] above the text and [metadata]
/// below. Announced with the author role.
/// {@endtemplate}
class AstryxChatMessage extends StatelessWidget {
  const AstryxChatMessage({
    super.key,
    required this.role,
    required this.content,
    this.avatar,
    this.authorName,
    this.toolCalls,
    this.metadata,
    this.onLinkTap,
  });

  final AstryxChatRole role;
  final String content;
  final Widget? avatar;
  final String? authorName;

  /// Rendered above the assistant's content (e.g. an [AstryxChatToolCalls]).
  final Widget? toolCalls;

  /// Rendered below the bubble (e.g. an [AstryxChatMessageMetadata]).
  final Widget? metadata;
  final ValueChanged<String>? onLinkTap;

  bool get _isUser => role == AstryxChatRole.user;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
      decoration: BoxDecoration(
        color: _isUser ? t.color.accentDefault : t.color.surfaceRaised,
        borderRadius: t.shape.radiusCard,
        border: _isUser ? null : Border.all(color: t.color.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapSm,
        children: [
          if (toolCalls != null && !_isUser) toolCalls!,
          if (_isUser)
            AstryxText(content, tone: AstryxTextTone.onAccent)
          else
            AstryxMarkdown(content, onLinkTap: onLinkTap),
        ],
      ),
    );

    final column = Column(
      crossAxisAlignment: _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: t.spacing.gapSm,
      children: [
        bubble,
        if (metadata != null) metadata!,
      ],
    );

    return Semantics(
      label: '${_isUser ? 'You' : authorName ?? 'Assistant'} said',
      container: true,
      explicitChildNodes: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: t.spacing.gapSm),
        child: Row(
          mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: t.spacing.gapMd,
          children: [
            if (!_isUser && avatar != null) avatar!,
            Flexible(child: column),
          ],
        ),
      ),
    );
  }
}
