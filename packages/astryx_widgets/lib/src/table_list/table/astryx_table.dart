import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// A table column header.
class AstryxColumn {
  const AstryxColumn({required this.label, this.numeric = false, this.sortable = false, this.flex = 1});
  final String label;
  final bool numeric;
  final bool sortable;
  final int flex;
}

/// A table row: [cells] aligned to the columns, optionally tappable.
class AstryxRow {
  const AstryxRow({required this.cells, this.onTap, this.selected = false});
  final List<Widget> cells;
  final VoidCallback? onTap;
  final bool selected;
}

enum AstryxSortDirection { ascending, descending }

/// {@template astryx.table}
/// A data table with a styled header, flex-aligned columns (numeric columns
/// right-aligned), hover/selectable rows and sortable headers. Tapping a
/// sortable header calls [onSort]; the active column shows a direction arrow.
/// {@endtemplate}
class AstryxTable extends StatelessWidget {
  const AstryxTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortDirection,
    this.onSort,
  });

  final List<AstryxColumn> columns;
  final List<AstryxRow> rows;
  final int? sortColumnIndex;
  final AstryxSortDirection? sortDirection;
  final ValueChanged<int>? onSort;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: t.shape.radiusCard,
          border: Border.all(color: t.color.borderDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(t),
            for (var i = 0; i < rows.length; i++) _DataRow(columns: columns, row: rows[i], isLast: i == rows.length - 1),
          ],
        ),
      ),
    );
  }

  Widget _header(AstryxTokens t) {
    return Container(
      color: t.color.surfaceSunken,
      padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              flex: columns[i].flex,
              child: _HeaderCell(
                column: columns[i],
                active: sortColumnIndex == i,
                direction: sortDirection,
                onSort: columns[i].sortable && onSort != null ? () => onSort!(i) : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.column, required this.active, required this.direction, required this.onSort});
  final AstryxColumn column;
  final bool active;
  final AstryxSortDirection? direction;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = Text(
      column.label,
      style: t.typography.label.copyWith(color: t.color.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
    );
    final content = Row(
      mainAxisAlignment: column.numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        label,
        if (active && direction != null)
          _SortArrow(ascending: direction == AstryxSortDirection.ascending, color: t.color.accentDefault),
      ],
    );
    if (onSort == null) return Align(alignment: column.numeric ? Alignment.centerRight : Alignment.centerLeft, child: content);
    return Semantics(
      button: true,
      label: 'Sort by ${column.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSort,
        child: ExcludeSemantics(
          child: Align(alignment: column.numeric ? Alignment.centerRight : Alignment.centerLeft, child: content),
        ),
      ),
    );
  }
}

class _DataRow extends StatefulWidget {
  const _DataRow({required this.columns, required this.row, required this.isLast});
  final List<AstryxColumn> columns;
  final AstryxRow row;
  final bool isLast;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final interactive = widget.row.onTap != null;
    final bg = widget.row.selected
        ? Color.alphaBlend(t.color.accentDefault.withValues(alpha: 0.10), t.color.surfaceDefault)
        : interactive && _hovered
            ? t.color.surfaceSunken
            : t.color.surfaceDefault;

    Widget row = Container(
      decoration: BoxDecoration(
        color: bg,
        border: widget.isLast ? null : Border(bottom: BorderSide(color: t.color.borderDefault)),
      ),
      padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
      child: DefaultTextStyle.merge(
        style: t.typography.body.copyWith(color: t.color.textDefault),
        child: Row(
          children: [
            for (var i = 0; i < widget.columns.length; i++)
              Expanded(
                flex: widget.columns[i].flex,
                child: Align(
                  alignment: widget.columns[i].numeric ? Alignment.centerRight : Alignment.centerLeft,
                  child: i < widget.row.cells.length ? widget.row.cells[i] : const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );

    if (!interactive) return row;

    return Semantics(
      button: true,
      selected: widget.row.selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.row.onTap, child: row),
      ),
    );
  }
}

class _SortArrow extends StatelessWidget {
  const _SortArrow({required this.ascending, required this.color});
  final bool ascending;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 10, height: 10, child: CustomPaint(painter: _SortArrowPainter(ascending, color)));
}

class _SortArrowPainter extends CustomPainter {
  const _SortArrowPainter(this.ascending, this.color);
  final bool ascending;
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
    final path = ascending
        ? (Path()..moveTo(w * 0.2, h * 0.6)..lineTo(w * 0.5, h * 0.3)..lineTo(w * 0.8, h * 0.6))
        : (Path()..moveTo(w * 0.2, h * 0.4)..lineTo(w * 0.5, h * 0.7)..lineTo(w * 0.8, h * 0.4));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_SortArrowPainter old) => old.ascending != ascending || old.color != color;
}
