import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.code}
/// Inline monospace code span with a subtle surface + border, for referencing
/// identifiers in running text.
/// {@endtemplate}
class AstryxCode extends StatelessWidget {
  const AstryxCode(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.spacing.insetXs, vertical: 1),
      decoration: BoxDecoration(
        color: t.color.surfaceSunken,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: t.color.borderDefault),
      ),
      child: Text(code, style: t.typography.code.copyWith(color: t.color.textDefault)),
    );
  }
}

/// {@template astryx.codeblock}
/// Multi-line code block: monospace, scrollable horizontally, on a sunken
/// surface. Announced as a single readable region.
/// {@endtemplate}
class AstryxCodeBlock extends StatelessWidget {
  const AstryxCodeBlock(this.code, {super.key, this.language});

  final String code;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: language == null ? 'code block' : 'code block, $language',
      readOnly: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(t.spacing.insetMd),
        decoration: BoxDecoration(
          color: t.color.surfaceSunken,
          borderRadius: t.shape.radiusCard,
          border: Border.all(color: t.color.borderDefault),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            code,
            style: t.typography.code.copyWith(color: t.color.textDefault),
          ),
        ),
      ),
    );
  }
}
