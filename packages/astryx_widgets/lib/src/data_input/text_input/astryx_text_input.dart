import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../internal/astryx_editable.dart';

/// {@template astryx.textinput}
/// A single-line text field with the Astryx look. Wraps the framework's text
/// editing (cursor, selection, IME) but strips all Material chrome, drawing its
/// own token-driven container with a focus ring and error state.
///
/// Controlled/uncontrolled: pass a [controller] to own the text, or let it
/// manage one internally. `enabled: false` disables input.
/// {@endtemplate}
class AstryxTextInput extends StatefulWidget {
  const AstryxTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.hasError = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool hasError;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  /// Structural slots inside the field frame (e.g. a search or clear icon).
  final Widget? leading;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  State<AstryxTextInput> createState() => _AstryxTextInputState();
}

class _AstryxTextInputState extends State<AstryxTextInput> {
  FocusNode? _internalNode;
  FocusNode get _node => widget.focusNode ?? (_internalNode ??= FocusNode());
  TextEditingController? _internalController;
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _node.hasFocus);

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _internalNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);

    final Color borderColor = !widget.enabled
        ? t.color.borderDefault
        : widget.hasError
            ? t.color.danger
            : _focused
                ? t.color.borderFocus
                : t.color.borderDefault;

    return Semantics(
      textField: true,
      label: widget.semanticLabel,
      enabled: widget.enabled,
      child: AnimatedContainer(
        duration: motion.durationFast,
        curve: motion.curveStandard,
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.insetMd,
          vertical: t.spacing.insetSm,
        ),
        decoration: BoxDecoration(
          color: widget.enabled ? t.color.surfaceDefault : t.color.surfaceSunken,
          borderRadius: t.shape.radiusControl,
          border: Border.all(color: borderColor, width: _focused || widget.hasError ? 1.5 : 1),
        ),
        child: Row(
          spacing: t.spacing.gapMd,
          children: [
            if (widget.leading != null)
              IconTheme.merge(
                data: IconThemeData(color: t.color.textMuted, size: 18),
                child: widget.leading!,
              ),
            Expanded(
              child: AstryxEditable(
                controller: _controller,
                focusNode: _node,
                hintText: widget.hintText,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
              ),
            ),
            if (widget.trailing != null)
              IconTheme.merge(
                data: IconThemeData(color: t.color.textMuted, size: 18),
                child: widget.trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
