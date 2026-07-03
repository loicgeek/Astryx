import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../overlay/popover/astryx_popover.dart';
import '../checkbox/astryx_checkbox.dart';

/// An option in an [AstryxMultiSelector].
class AstryxSelectOption<T> {
  const AstryxSelectOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// {@template astryx.multiselector}
/// Selects multiple options from a checklist in a popover. Controlled via the
/// [selected] set; toggling an option calls [onChanged] with the new set. The
/// trigger summarizes the current selection.
/// {@endtemplate}
class AstryxMultiSelector<T> extends StatefulWidget {
  const AstryxMultiSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.hintText = 'Select…',
  });

  final List<AstryxSelectOption<T>> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final String hintText;

  @override
  State<AstryxMultiSelector<T>> createState() => _AstryxMultiSelectorState<T>();
}

class _AstryxMultiSelectorState<T> extends State<AstryxMultiSelector<T>> {
  final _controller = AstryxPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(T value) {
    final next = {...widget.selected};
    if (!next.add(value)) next.remove(value);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final count = widget.selected.length;
    final summary = count == 0
        ? widget.hintText
        : count == 1
            ? widget.options.firstWhere((o) => o.value == widget.selected.first).label
            : '$count selected';

    return AstryxPopover(
      controller: _controller,
      maxWidth: 260,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapSm,
        children: [
          for (final o in widget.options)
            AstryxCheckbox(
              value: widget.selected.contains(o.value),
              label: o.label,
              onChanged: (_) => _toggle(o.value),
            ),
        ],
      ),
      anchor: Semantics(
        button: true,
        label: '$summary, multi-select',
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
            decoration: BoxDecoration(
              color: t.color.surfaceDefault,
              borderRadius: t.shape.radiusControl,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapMd, children: [
              Text(
                summary,
                style: t.typography.body.copyWith(color: count == 0 ? t.color.textMuted : t.color.textDefault),
              ),
              _Caret(color: t.color.textMuted),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Caret extends StatelessWidget {
  const _Caret({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 12, height: 12, child: CustomPaint(painter: _CaretPainter(color)));
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter(this.color);
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
    canvas.drawPath(Path()..moveTo(w * 0.25, h * 0.4)..lineTo(w * 0.5, h * 0.65)..lineTo(w * 0.75, h * 0.4), p);
  }

  @override
  bool shouldRepaint(_CaretPainter old) => old.color != color;
}
