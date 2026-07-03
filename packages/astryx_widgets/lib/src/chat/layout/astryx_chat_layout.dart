import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.chatlayout}
/// Assembles a conversation: a scrollable list of [messages] above a pinned
/// [composer]. Auto-scrolls to the newest message as the list grows (honoring
/// reduced motion). An optional [streaming] placeholder is shown at the bottom
/// while a reply is arriving.
/// {@endtemplate}
class AstryxChatLayout extends StatefulWidget {
  const AstryxChatLayout({
    super.key,
    required this.messages,
    required this.composer,
    this.streaming,
    this.padding,
  });

  final List<Widget> messages;
  final Widget composer;
  final Widget? streaming;
  final EdgeInsetsGeometry? padding;

  @override
  State<AstryxChatLayout> createState() => _AstryxChatLayoutState();
}

class _AstryxChatLayoutState extends State<AstryxChatLayout> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(AstryxChatLayout old) {
    super.didUpdateWidget(old);
    if (widget.messages.length != old.messages.length || (widget.streaming != null) != (old.streaming != null)) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      final motion = AstryxMotion.resolve(context);
      if (motion.durationNormal == Duration.zero) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(target, duration: motion.durationNormal, curve: motion.curveDecelerate);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: widget.padding ?? EdgeInsets.all(t.spacing.insetMd),
            children: [
              ...widget.messages,
              if (widget.streaming != null) widget.streaming!,
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(t.spacing.insetMd),
          child: widget.composer,
        ),
      ],
    );
  }
}
