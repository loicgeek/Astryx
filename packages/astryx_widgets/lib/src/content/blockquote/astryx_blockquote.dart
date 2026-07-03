import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.blockquote}
/// A quotation with a left accent bar and an optional [citation]. Accepts a
/// [text] string or a custom [child].
/// {@endtemplate}
class AstryxBlockquote extends StatelessWidget {
  const AstryxBlockquote({super.key, this.text, this.child, this.citation})
      : assert(text != null || child != null, 'Provide text or child');

  final String? text;
  final Widget? child;
  final String? citation;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      child: Container(
        padding: EdgeInsets.only(left: t.spacing.insetMd),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: t.color.borderStrong, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: t.spacing.gapSm,
          children: [
            child ??
                Text(
                  text!,
                  style: t.typography.body.copyWith(
                    color: t.color.textDefault,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            if (citation != null)
              Text('— ${citation!}', style: t.typography.label.copyWith(color: t.color.textMuted)),
          ],
        ),
      ),
    );
  }
}
