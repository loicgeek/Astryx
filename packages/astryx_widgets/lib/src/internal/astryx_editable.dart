import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A minimal, **Material-free** single-line text editor built on [EditableText]
/// (from the widgets library) — so `astryx_widgets` never depends on Material.
/// It provides the text-editing machinery (cursor, IME, formatters, submit)
/// under the Astryx look; the surrounding frame is drawn by the caller.
class AstryxEditable extends StatefulWidget {
  const AstryxEditable({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.expandsWidth = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  /// When false, the editor sizes to its content (used inside the tokenizer's Wrap).
  final bool expandsWidth;

  @override
  State<AstryxEditable> createState() => _AstryxEditableState();
}

class _AstryxEditableState extends State<AstryxEditable> {
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textStyle = t.typography.body.copyWith(color: t.color.textDefault);

    final editable = EditableText(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: !widget.enabled,
      style: textStyle,
      strutStyle: StrutStyle.fromTextStyle(textStyle),
      cursorColor: t.color.accentDefault,
      backgroundCursorColor: t.color.borderStrong,
      selectionColor: t.color.accentDefault.withValues(alpha: 0.3),
      cursorOpacityAnimates: true,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: 1,
      rendererIgnoresPointer: false,
      showCursor: true,
    );

    // Hint overlay shown while empty; rebuilds with the controller.
    final stack = Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        if (widget.hintText != null)
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => widget.controller.text.isEmpty
                ? IgnorePointer(
                    child: Text(
                      widget.hintText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.typography.body.copyWith(color: t.color.textMuted),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        editable,
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.enabled && !widget.focusNode.hasFocus) widget.focusNode.requestFocus();
      },
      child: widget.expandsWidth ? SizedBox(width: double.infinity, child: stack) : stack,
    );
  }
}
