import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// One node in an [AstryxBreadcrumbs] trail.
class AstryxCrumb {
  const AstryxCrumb({required this.label, this.onTap});
  final String label;

  /// Tap handler for navigable crumbs. The last crumb is treated as the current
  /// page and is never tappable.
  final VoidCallback? onTap;
}

/// {@template astryx.breadcrumbs}
/// A navigation trail. All items except the last render as links; the last is
/// the current page (muted, non-interactive, announced as such). Wraps to
/// multiple lines when space is tight.
/// {@endtemplate}
class AstryxBreadcrumbs extends StatelessWidget {
  const AstryxBreadcrumbs({super.key, required this.items});

  final List<AstryxCrumb> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;
      children.add(_Crumb(crumb: items[i], isCurrent: isLast));
      if (!isLast) {
        children.add(Text('/', style: t.typography.label.copyWith(color: t.color.textMuted)));
      }
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Wrap(
        spacing: t.spacing.gapSm,
        runSpacing: t.spacing.gapSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.crumb, required this.isCurrent});
  final AstryxCrumb crumb;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    if (isCurrent) {
      return Semantics(
        label: '${crumb.label}, current page',
        child: ExcludeSemantics(
          child: Text(
            crumb.label,
            style: t.typography.label.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
    return Semantics(
      link: true,
      button: true,
      label: crumb.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: crumb.onTap,
        child: ExcludeSemantics(
          child: Text(crumb.label, style: t.typography.label.copyWith(color: t.color.accentDefault)),
        ),
      ),
    );
  }
}
