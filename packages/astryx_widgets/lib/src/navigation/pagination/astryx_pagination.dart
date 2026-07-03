import 'dart:math' as math;

import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.pagination}
/// Page navigation with previous/next controls and a windowed set of page
/// numbers (collapsing distant pages to an ellipsis). 1-based [page]; selecting
/// a page calls [onChanged]. The current page is announced as selected.
/// {@endtemplate}
class AstryxPagination extends StatelessWidget {
  const AstryxPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.siblingCount = 1,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int>? onChanged;
  final int siblingCount;

  /// The pages to render; `null` entries are ellipses.
  List<int?> _window() {
    if (pageCount <= 7) return [for (var i = 1; i <= pageCount; i++) i];
    final left = math.max(2, page - siblingCount);
    final right = math.min(pageCount - 1, page + siblingCount);
    return [
      1,
      if (left > 2) null,
      for (var i = left; i <= right; i++) i,
      if (right < pageCount - 1) null,
      pageCount,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onChanged != null;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapSm,
        children: [
          _ArrowButton(
            label: 'Previous page',
            forward: false,
            onTap: enabled && page > 1 ? () => onChanged!(page - 1) : null,
          ),
          for (final p in _window())
            if (p == null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: t.spacing.insetXs),
                child: Text('…', style: t.typography.label.copyWith(color: t.color.textMuted)),
              )
            else
              _PageButton(
                page: p,
                selected: p == page,
                onTap: enabled ? () => onChanged!(p) : null,
              ),
          _ArrowButton(
            label: 'Next page',
            forward: true,
            onTap: enabled && page < pageCount ? () => onChanged!(page + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatefulWidget {
  const _PageButton({required this.page, required this.selected, required this.onTap});
  final int page;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_PageButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<_PageButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Page ${widget.page}',
      child: FocusableActionDetector(
        enabled: widget.onTap != null,
        mouseCursor: SystemMouseCursors.click,
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
            child: Container(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? t.color.accentDefault : const Color(0x00000000),
                borderRadius: t.shape.radiusControl,
                border: Border.all(color: selected ? t.color.accentDefault : t.color.borderDefault),
                boxShadow: _focused ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)] : null,
              ),
              child: Text(
                '${widget.page}',
                style: t.typography.label.copyWith(
                  color: selected ? t.color.textOnAccent : t.color.textDefault,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.label, required this.forward, required this.onTap});
  final String label;
  final bool forward;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onTap != null;
    final color = enabled ? t.color.textDefault : t.color.textDisabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            onTap?.call();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: t.shape.radiusControl,
                border: Border.all(color: t.color.borderDefault),
              ),
              child: CustomPaint(
                size: const Size(10, 10),
                painter: _ArrowPainter(color: color, forward: forward),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color, required this.forward});
  final Color color;
  final bool forward;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    final path = forward
        ? (Path()
          ..moveTo(w * 0.35, h * 0.2)
          ..lineTo(w * 0.65, h * 0.5)
          ..lineTo(w * 0.35, h * 0.8))
        : (Path()
          ..moveTo(w * 0.65, h * 0.2)
          ..lineTo(w * 0.35, h * 0.5)
          ..lineTo(w * 0.65, h * 0.8));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color || old.forward != forward;
}
