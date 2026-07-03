import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../overlay/popover/astryx_popover.dart';
import '../calendar/astryx_calendar.dart';
import '../calendar/date_utils.dart';

/// {@template astryx.dateinput}
/// A field that displays the selected date and opens an [AstryxCalendar] in a
/// popover to pick one. Controlled via [value]; selecting a day calls
/// [onChanged] and closes the popover.
/// {@endtemplate}
class AstryxDateInput extends StatefulWidget {
  const AstryxDateInput({
    super.key,
    this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.today,
    this.hintText = 'Select a date',
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? today;
  final String hintText;

  @override
  State<AstryxDateInput> createState() => _AstryxDateInputState();
}

class _AstryxDateInputState extends State<AstryxDateInput> {
  final _controller = AstryxPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasValue = widget.value != null;
    final text = hasValue ? AstryxDates.longDate(widget.value!) : widget.hintText;

    return AstryxPopover(
      controller: _controller,
      maxWidth: 320,
      builder: (context) => AstryxCalendar(
        value: widget.value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        today: widget.today,
        onChanged: (d) {
          widget.onChanged?.call(d);
          _controller.close();
        },
      ),
      anchor: Semantics(
        button: true,
        label: hasValue ? 'Date: ${AstryxDates.longDate(widget.value!)}' : widget.hintText,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
            decoration: BoxDecoration(
              color: t.color.surfaceDefault,
              borderRadius: t.shape.radiusControl,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: t.spacing.gapMd,
              children: [
                _CalendarGlyph(color: t.color.textMuted),
                Text(
                  text,
                  style: t.typography.body.copyWith(
                    color: hasValue ? t.color.textDefault : t.color.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarGlyph extends StatelessWidget {
  const _CalendarGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 16, height: 16, child: CustomPaint(painter: _CalendarPainter(color)));
}

class _CalendarPainter extends CustomPainter {
  const _CalendarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.7),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, p);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.4), Offset(size.width * 0.9, size.height * 0.4), p);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.1), Offset(size.width * 0.3, size.height * 0.3), p);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.1), Offset(size.width * 0.7, size.height * 0.3), p);
  }

  @override
  bool shouldRepaint(_CalendarPainter old) => old.color != color;
}
