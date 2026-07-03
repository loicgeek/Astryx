import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/astryx_editable.dart';

/// {@template astryx.chatcomposer}
/// The message input for a chat. Grows up to a few lines; Enter sends and
/// Shift+Enter inserts a newline. Disabled (e.g. while the assistant responds)
/// via [enabled]. The send button is disabled while the field is empty.
/// {@endtemplate}
class AstryxChatComposer extends StatefulWidget {
  const AstryxChatComposer({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.hintText = 'Send a message…',
    this.leadingActions = const [],
  });

  final ValueChanged<String> onSend;
  final bool enabled;
  final String hintText;

  /// Optional leading controls (attachments, etc.).
  final List<Widget> leadingActions;

  @override
  State<AstryxChatComposer> createState() => _AstryxChatComposerState();
}

class _AstryxChatComposerState extends State<AstryxChatComposer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _text.removeListener(_onChanged);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSend => widget.enabled && _text.text.trim().isNotEmpty;

  void _send() {
    if (!_canSend) return;
    widget.onSend(_text.text.trim());
    _text.clear();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter && !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled; // consume Enter so no newline is inserted
    }
    return KeyEventResult.ignored; // Shift+Enter falls through → newline
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.insetSm),
      decoration: BoxDecoration(
        color: t.color.surfaceDefault,
        borderRadius: t.shape.radiusCard,
        border: Border.all(color: t.color.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: t.spacing.gapSm,
        children: [
          for (final a in widget.leadingActions) a,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.insetXs, vertical: t.spacing.insetXs),
              child: Focus(
                skipTraversal: true,
                onKeyEvent: _onKey,
                child: AstryxEditable(
                  controller: _text,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  hintText: widget.hintText,
                  minLines: 1,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
          ),
          _SendButton(enabled: _canSend, onTap: _send),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: ExcludeSemantics(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: enabled ? t.color.accentDefault : t.color.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: _SendPainter(enabled ? t.color.textOnAccent : t.color.textDisabled),
            ),
          ),
        ),
      ),
    );
  }
}

class _SendPainter extends CustomPainter {
  const _SendPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // An upward arrow (send).
    canvas.drawLine(Offset(w * 0.5, h * 0.7), Offset(w * 0.5, h * 0.3), p);
    canvas.drawPath(Path()..moveTo(w * 0.32, h * 0.46)..lineTo(w * 0.5, h * 0.28)..lineTo(w * 0.68, h * 0.46), p);
  }

  @override
  bool shouldRepaint(_SendPainter old) => old.color != color;
}
