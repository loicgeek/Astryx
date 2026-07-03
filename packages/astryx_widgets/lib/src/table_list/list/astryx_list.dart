import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// One row in an [AstryxList].
class AstryxListItem {
  const AstryxListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final String? semanticLabel;
}

/// {@template astryx.list}
/// A vertical list of rows with consistent padding and optional [dividers].
/// Rows with an `onTap` become interactive (hover/press/focus, button
/// semantics, selected state).
/// {@endtemplate}
class AstryxList extends StatelessWidget {
  const AstryxList({super.key, required this.items, this.dividers = true});

  final List<AstryxListItem> items;
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ListTile(item: items[i]),
            if (dividers && i < items.length - 1)
              Container(height: 1, color: t.color.borderDefault),
          ],
        ],
      ),
    );
  }
}

class _ListTile extends StatefulWidget {
  const _ListTile({required this.item});
  final AstryxListItem item;

  @override
  State<_ListTile> createState() => _ListTileState();
}

class _ListTileState extends State<_ListTile> {
  bool _hovered = false;
  bool _focused = false;

  bool get _interactive => widget.item.onTap != null;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final item = widget.item;

    final bg = item.selected
        ? Color.alphaBlend(t.color.accentDefault.withValues(alpha: 0.10), t.color.surfaceDefault)
        : _interactive && _hovered
            ? t.color.surfaceSunken
            : const Color(0x00000000);

    final row = AnimatedContainer(
      duration: motion.durationFast,
      curve: motion.curveStandard,
      padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
      decoration: BoxDecoration(
        color: bg,
        boxShadow: _focused ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)] : null,
      ),
      child: Row(
        spacing: t.spacing.gapMd,
        children: [
          if (item.leading != null)
            IconTheme.merge(data: IconThemeData(color: t.color.textMuted, size: 20), child: item.leading!),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: t.typography.body.copyWith(
                    color: t.color.textDefault,
                    fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (item.subtitle != null)
                  Text(item.subtitle!, overflow: TextOverflow.ellipsis, style: t.typography.label.copyWith(color: t.color.textMuted)),
              ],
            ),
          ),
          if (item.trailing != null) item.trailing!,
        ],
      ),
    );

    if (!_interactive) {
      return Semantics(
        label: item.semanticLabel ?? item.title,
        selected: item.selected ? true : null,
        child: ExcludeSemantics(child: row),
      );
    }

    return Semantics(
      button: true,
      selected: item.selected,
      label: item.semanticLabel ?? item.title,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            item.onTap!();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.onTap,
          child: ExcludeSemantics(child: row),
        ),
      ),
    );
  }
}
