import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// One entry in an [AstryxSideNav].
class AstryxNavItem<T> {
  const AstryxNavItem({required this.value, required this.label, this.icon, this.trailing});
  final T value;
  final String label;
  final Widget? icon;
  final Widget? trailing;
}

/// A titled group of nav items.
class AstryxNavSection<T> {
  const AstryxNavSection({this.title, required this.items});
  final String? title;
  final List<AstryxNavItem<T>> items;
}

/// {@template astryx.sidenav}
/// A vertical navigation rail: optional [header]/[footer] with grouped
/// [sections] of items. The [selected] item is highlighted and announced as
/// selected. When [collapsed], items render icon-only (label moves to the
/// accessible name).
/// {@endtemplate}
class AstryxSideNav<T> extends StatelessWidget {
  const AstryxSideNav({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelect,
    this.header,
    this.footer,
    this.collapsed = false,
  });

  final List<AstryxNavSection<T>> sections;
  final T? selected;
  final ValueChanged<T>? onSelect;
  final Widget? header;
  final Widget? footer;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        color: t.color.surfaceRaised,
        padding: EdgeInsets.symmetric(vertical: t.spacing.insetMd, horizontal: t.spacing.insetSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) ...[
              Padding(padding: EdgeInsets.all(t.spacing.insetSm), child: header!),
              SizedBox(height: t.spacing.gapMd),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final section in sections) ...[
                      if (section.title != null && !collapsed)
                        Padding(
                          padding: EdgeInsets.fromLTRB(t.spacing.insetSm, t.spacing.insetSm, 0, t.spacing.insetXs),
                          child: Text(
                            section.title!.toUpperCase(),
                            style: t.typography.label.copyWith(
                              color: t.color.textMuted,
                              fontSize: 11,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      for (final item in section.items)
                        _NavItemTile<T>(
                          item: item,
                          selected: item.value == selected,
                          collapsed: collapsed,
                          onTap: onSelect == null ? null : () => onSelect!(item.value),
                        ),
                      SizedBox(height: t.spacing.gapSm),
                    ],
                  ],
                ),
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: t.spacing.gapMd),
              Padding(padding: EdgeInsets.all(t.spacing.insetSm), child: footer!),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItemTile<T> extends StatefulWidget {
  const _NavItemTile({required this.item, required this.selected, required this.collapsed, required this.onTap});
  final AstryxNavItem<T> item;
  final bool selected;
  final bool collapsed;
  final VoidCallback? onTap;

  @override
  State<_NavItemTile<T>> createState() => _NavItemTileState<T>();
}

class _NavItemTileState<T> extends State<_NavItemTile<T>> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final selected = widget.selected;
    final fg = selected ? t.color.accentDefault : t.color.textDefault;
    final bg = selected
        ? Color.alphaBlend(t.color.accentDefault.withValues(alpha: 0.12), t.color.surfaceRaised)
        : _hovered
            ? t.color.surfaceSunken
            : const Color(0x00000000);

    return Semantics(
      button: true,
      selected: selected,
      label: widget.item.label,
      child: FocusableActionDetector(
        enabled: widget.onTap != null,
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap?.call();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: motion.durationFast,
              curve: motion.curveStandard,
              margin: EdgeInsets.symmetric(vertical: 1),
              padding: EdgeInsets.symmetric(horizontal: t.spacing.insetSm, vertical: t.spacing.insetSm),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: t.shape.radiusControl,
                boxShadow: _focused ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)] : null,
              ),
              child: Row(
                mainAxisAlignment: widget.collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                spacing: t.spacing.gapMd,
                children: [
                  if (widget.item.icon != null)
                    IconTheme.merge(data: IconThemeData(color: fg, size: 18), child: widget.item.icon!),
                  if (!widget.collapsed) ...[
                    Expanded(
                      child: Text(
                        widget.item.label,
                        overflow: TextOverflow.ellipsis,
                        style: t.typography.body.copyWith(
                          color: fg,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (widget.item.trailing != null) widget.item.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
