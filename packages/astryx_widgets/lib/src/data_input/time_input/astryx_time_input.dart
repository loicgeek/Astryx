import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../overlay/popover/astryx_popover.dart';

/// A simple wall-clock time (24-hour), independent of any date.
class AstryxTimeOfDay {
  const AstryxTimeOfDay(this.hour, this.minute);
  final int hour;
  final int minute;

  int get _minutes => hour * 60 + minute;
  String format() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is AstryxTimeOfDay && other.hour == hour && other.minute == minute;
  @override
  int get hashCode => _minutes;
}

/// {@template astryx.timeinput}
/// A field that displays a time and opens a scrollable list of selectable times
/// (every [intervalMinutes]) in a popover. Controlled via [value].
/// {@endtemplate}
class AstryxTimeInput extends StatefulWidget {
  const AstryxTimeInput({
    super.key,
    this.value,
    required this.onChanged,
    this.intervalMinutes = 30,
    this.hintText = 'Select a time',
  });

  final AstryxTimeOfDay? value;
  final ValueChanged<AstryxTimeOfDay>? onChanged;
  final int intervalMinutes;
  final String hintText;

  @override
  State<AstryxTimeInput> createState() => _AstryxTimeInputState();
}

class _AstryxTimeInputState extends State<AstryxTimeInput> {
  final _controller = AstryxPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<AstryxTimeOfDay> _times() => [
        for (var m = 0; m < 24 * 60; m += widget.intervalMinutes) AstryxTimeOfDay(m ~/ 60, m % 60),
      ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hasValue = widget.value != null;
    final text = hasValue ? widget.value!.format() : widget.hintText;

    return AstryxPopover(
      controller: _controller,
      maxWidth: 160,
      builder: (context) => SizedBox(
        height: 220,
        width: 132,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final time in _times())
                _TimeOption(
                  time: time,
                  selected: time == widget.value,
                  onTap: () {
                    widget.onChanged?.call(time);
                    _controller.close();
                  },
                ),
            ],
          ),
        ),
      ),
      anchor: Semantics(
        button: true,
        label: hasValue ? 'Time: ${widget.value!.format()}' : widget.hintText,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
            decoration: BoxDecoration(
              color: t.color.surfaceDefault,
              borderRadius: t.shape.radiusControl,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapMd, children: [
              _ClockGlyph(color: t.color.textMuted),
              Text(text, style: t.typography.body.copyWith(color: hasValue ? t.color.textDefault : t.color.textMuted)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TimeOption extends StatefulWidget {
  const _TimeOption({required this.time, required this.selected, required this.onTap});
  final AstryxTimeOfDay time;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TimeOption> createState() => _TimeOptionState();
}

class _TimeOptionState extends State<_TimeOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bg = widget.selected
        ? Color.alphaBlend(t.color.accentDefault.withValues(alpha: 0.14), t.color.surfaceOverlay)
        : _hovered
            ? t.color.surfaceSunken
            : const Color(0x00000000);
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.time.format(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.insetSm, vertical: t.spacing.insetSm),
              decoration: BoxDecoration(color: bg, borderRadius: t.shape.radiusControl),
              child: Text(
                widget.time.format(),
                style: t.typography.body.copyWith(
                  color: widget.selected ? t.color.accentDefault : t.color.textDefault,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockGlyph extends StatelessWidget {
  const _ClockGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 16, height: 16, child: CustomPaint(painter: _ClockPainter(color)));
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, size.width * 0.42, p);
    canvas.drawLine(c, c + Offset(0, -size.height * 0.26), p);
    canvas.drawLine(c, c + Offset(size.width * 0.2, 0), p);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.color != color;
}
