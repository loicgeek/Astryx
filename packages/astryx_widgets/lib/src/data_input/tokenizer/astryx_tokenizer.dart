import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/astryx_editable.dart';

/// {@template astryx.tokenizer}
/// A free-form input that turns entries into removable chips. Type and press
/// Enter or comma to add a token; Backspace on an empty field removes the last.
/// Controlled via [value]; edits call [onChanged]. Each token exposes a remove
/// button.
/// {@endtemplate}
class AstryxTokenizer extends StatefulWidget {
  const AstryxTokenizer({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText = 'Add…',
  });

  final List<String> value;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  @override
  State<AstryxTokenizer> createState() => _AstryxTokenizerState();
}

class _AstryxTokenizerState extends State<AstryxTokenizer> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final token = raw.trim();
    if (token.isEmpty || widget.value.contains(token)) {
      _text.clear();
      return;
    }
    widget.onChanged([...widget.value, token]);
    _text.clear();
  }

  void _removeAt(int index) {
    final next = [...widget.value]..removeAt(index);
    widget.onChanged(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _text.text.isEmpty &&
        widget.value.isNotEmpty) {
      _removeAt(widget.value.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: GestureDetector(
        onTap: _focus.requestFocus,
        child: Container(
          padding: EdgeInsets.all(t.spacing.insetSm),
          decoration: BoxDecoration(
            color: t.color.surfaceDefault,
            borderRadius: t.shape.radiusControl,
            border: Border.all(color: t.color.borderDefault),
          ),
          child: Wrap(
            spacing: t.spacing.gapSm,
            runSpacing: t.spacing.gapSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < widget.value.length; i++)
                _Token(label: widget.value[i], onRemove: () => _removeAt(i)),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 120),
                child: Focus(
                  skipTraversal: true,
                  onKeyEvent: _onKey,
                  child: AstryxEditable(
                    controller: _text,
                    focusNode: _focus,
                    expandsWidth: false,
                    hintText: widget.value.isEmpty ? widget.hintText : null,
                    inputFormatters: [
                      // Adding on comma keeps typing fluid; Enter also adds.
                      TextInputFormatter.withFunction((oldV, newV) {
                        if (newV.text.endsWith(',')) {
                          _add(newV.text.substring(0, newV.text.length - 1));
                          return const TextEditingValue();
                        }
                        return newV;
                      }),
                    ],
                    onSubmitted: _add,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        padding: EdgeInsets.only(left: t.spacing.insetSm, right: t.spacing.insetXs, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: t.color.surfaceSunken,
          borderRadius: t.shape.radiusPill,
          border: Border.all(color: t.color.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: t.spacing.gapSm,
          children: [
            Text(label, style: t.typography.label.copyWith(color: t.color.textDefault)),
            Semantics(
              button: true,
              label: 'Remove $label',
              child: GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(width: 16, height: 16, child: CustomPaint(painter: _XPainter(t.color.textMuted))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _XPainter extends CustomPainter {
  const _XPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final pad = size.width * 0.32;
    canvas.drawLine(Offset(pad, pad), Offset(size.width - pad, size.height - pad), p);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(pad, size.height - pad), p);
  }

  @override
  bool shouldRepaint(_XPainter old) => old.color != color;
}
