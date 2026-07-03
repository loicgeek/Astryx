import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// A node in an [AstryxTreeList]. Nodes with [children] are expandable.
class AstryxTreeNode {
  const AstryxTreeNode({required this.label, this.value, this.icon, this.children = const []});
  final String label;
  final Object? value;
  final Widget? icon;
  final List<AstryxTreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}

/// {@template astryx.treelist}
/// A hierarchical, expandable list. Branch nodes toggle open on tap of their
/// chevron; leaf nodes select (calls [onSelect]). Each node announces its
/// expanded/selected state with tree-item semantics.
/// {@endtemplate}
class AstryxTreeList extends StatefulWidget {
  const AstryxTreeList({
    super.key,
    required this.roots,
    this.selected,
    this.onSelect,
    this.initiallyExpanded = const {},
  });

  final List<AstryxTreeNode> roots;
  final Object? selected;
  final ValueChanged<Object?>? onSelect;

  /// Node values that start expanded.
  final Set<Object?> initiallyExpanded;

  @override
  State<AstryxTreeList> createState() => _AstryxTreeListState();
}

class _AstryxTreeListState extends State<AstryxTreeList> {
  final _expanded = <AstryxTreeNode>{};

  @override
  void initState() {
    super.initState();
    void seed(List<AstryxTreeNode> nodes) {
      for (final n in nodes) {
        if (widget.initiallyExpanded.contains(n.value)) _expanded.add(n);
        seed(n.children);
      }
    }

    seed(widget.roots);
  }

  void _toggle(AstryxTreeNode node) {
    setState(() => _expanded.contains(node) ? _expanded.remove(node) : _expanded.add(node));
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [for (final n in widget.roots) ..._build(n, 0)],
      ),
    );
  }

  List<Widget> _build(AstryxTreeNode node, int depth) {
    final expanded = _expanded.contains(node);
    return [
      _TreeRow(
        node: node,
        depth: depth,
        expanded: expanded,
        selected: node.value != null && node.value == widget.selected,
        onToggle: node.hasChildren ? () => _toggle(node) : null,
        onSelect: widget.onSelect == null ? null : () => widget.onSelect!(node.value),
      ),
      if (expanded)
        for (final child in node.children) ..._build(child, depth + 1),
    ];
  }
}

class _TreeRow extends StatefulWidget {
  const _TreeRow({
    required this.node,
    required this.depth,
    required this.expanded,
    required this.selected,
    required this.onToggle,
    required this.onSelect,
  });

  final AstryxTreeNode node;
  final int depth;
  final bool expanded;
  final bool selected;
  final VoidCallback? onToggle;
  final VoidCallback? onSelect;

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final node = widget.node;
    final fg = widget.selected ? t.color.accentDefault : t.color.textDefault;
    final bg = widget.selected
        ? Color.alphaBlend(t.color.accentDefault.withValues(alpha: 0.10), t.color.surfaceDefault)
        : _hovered
            ? t.color.surfaceSunken
            : const Color(0x00000000);

    return Semantics(
      button: true,
      selected: widget.selected,
      expanded: node.hasChildren ? widget.expanded : null,
      label: node.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: node.hasChildren ? widget.onToggle : widget.onSelect,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.only(
                left: t.spacing.insetSm + widget.depth * 16.0,
                right: t.spacing.insetSm,
                top: t.spacing.insetXs,
                bottom: t.spacing.insetXs,
              ),
              decoration: BoxDecoration(color: bg, borderRadius: t.shape.radiusControl),
              child: Row(
                spacing: t.spacing.gapSm,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: node.hasChildren
                        ? AnimatedRotation(
                            turns: widget.expanded ? 0.25 : 0,
                            duration: motion.durationFast,
                            child: CustomPaint(painter: _ChevronPainter(t.color.textMuted)),
                          )
                        : null,
                  ),
                  if (node.icon != null)
                    IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: node.icon!),
                  Flexible(
                    child: Text(
                      node.label,
                      overflow: TextOverflow.ellipsis,
                      style: t.typography.body.copyWith(
                        color: fg,
                        fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawPath(Path()..moveTo(w * 0.4, h * 0.28)..lineTo(w * 0.62, h * 0.5)..lineTo(w * 0.4, h * 0.72), p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}
