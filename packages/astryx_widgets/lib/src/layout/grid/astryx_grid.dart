import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.grid}
/// A responsive, token-gapped grid. The column count adapts to the container
/// width via a [ResponsiveValue] (CSS grid analog). Children are laid out in
/// equal-width tracks and wrap to new rows as needed.
/// {@endtemplate}
class AstryxGrid extends StatelessWidget {
  const AstryxGrid({
    super.key,
    required this.children,
    this.columns = const ResponsiveValue<int>(xs: 1, sm: 2, lg: 3, xl: 4),
    this.gap,
  });

  final List<Widget> children;
  final ResponsiveValue<int> columns;

  /// Spacing between tracks (both axes). Defaults to the `gapMd` token.
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final spacing = gap ?? t.spacing.gapMd;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Container-query-like: choose columns from the available width, not the
        // whole screen.
        final bp = AstryxBreakpoint.fromWidth(constraints.maxWidth);
        final cols = columns.resolve(bp).clamp(1, 24);
        final totalGap = spacing * (cols - 1);
        final itemWidth = (constraints.maxWidth - totalGap) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth < 0 ? 0 : itemWidth, child: child),
          ],
        );
      },
    );
  }
}
