import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.divider}
/// A hairline separator using the theme's border token. Horizontal by default;
/// set [axis] to [Axis.vertical] inside a Row. An optional [label] renders a
/// centered caption with rules on either side.
/// {@endtemplate}
class AstryxDivider extends StatelessWidget {
  const AstryxDivider({super.key, this.axis = Axis.horizontal, this.label});

  final Axis axis;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final line = Container(
      color: t.color.borderDefault,
      height: axis == Axis.horizontal ? 1 : null,
      width: axis == Axis.vertical ? 1 : null,
    );

    if (label == null) {
      return Semantics(
        // A plain rule is decorative; expose it as a separator with no label.
        child: axis == Axis.horizontal ? SizedBox(height: 1, child: line) : SizedBox(width: 1, child: line),
      );
    }

    // Labeled divider is only meaningful horizontally.
    return Row(
      children: [
        Expanded(child: SizedBox(height: 1, child: line)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: t.spacing.insetSm),
          child: Text(label!, style: t.typography.label.copyWith(color: t.color.textMuted)),
        ),
        Expanded(child: SizedBox(height: 1, child: Container(color: t.color.borderDefault))),
      ],
    );
  }
}
