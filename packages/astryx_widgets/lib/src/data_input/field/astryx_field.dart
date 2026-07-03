import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.field}
/// Form field scaffold: a label (with optional required marker), optional
/// description, the input [child], and an error message. Groups everything into
/// one labeled region so screen readers announce the label with the control.
/// {@endtemplate}
class AstryxField extends StatelessWidget {
  const AstryxField({
    super.key,
    required this.label,
    required this.child,
    this.description,
    this.error,
    this.required = false,
  });

  final String label;
  final Widget child;
  final String? description;

  /// When non-null, renders the error text in the danger tone below the input.
  final String? error;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: required ? '$label, required' : label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapSm,
        children: [
          ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: t.typography.label.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w600)),
                if (required)
                  Padding(
                    padding: EdgeInsets.only(left: t.spacing.insetXs / 2),
                    child: Text('*', style: t.typography.label.copyWith(color: t.color.danger)),
                  ),
              ],
            ),
          ),
          if (description != null)
            ExcludeSemantics(
              child: Text(description!, style: t.typography.label.copyWith(color: t.color.textMuted)),
            ),
          child,
          if (error != null)
            Text(
              error!,
              style: t.typography.label.copyWith(color: t.color.danger),
            ),
        ],
      ),
    );
  }
}
