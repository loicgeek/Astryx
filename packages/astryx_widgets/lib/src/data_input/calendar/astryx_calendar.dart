import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'date_utils.dart';

/// {@template astryx.calendar}
/// A month calendar. Controlled via [value] within optional [firstDate] /
/// [lastDate] bounds; selecting a day calls [onChanged]. The grid is a single
/// keyboard stop: arrow keys move the focused day (crossing months), Enter/Space
/// selects, PageUp/PageDown change month. Each day exposes a button with its
/// selected state; today is outlined.
/// {@endtemplate}
class AstryxCalendar extends StatefulWidget {
  const AstryxCalendar({
    super.key,
    this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.today,
    this.focusNode,
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Overridable "today" (tests pass a fixed date; defaults to DateTime.now()).
  final DateTime? today;
  final FocusNode? focusNode;

  @override
  State<AstryxCalendar> createState() => _AstryxCalendarState();
}

class _AstryxCalendarState extends State<AstryxCalendar> {
  late DateTime _visibleMonth;
  late DateTime _focused;

  DateTime get _today => AstryxDates.dateOnly(widget.today ?? DateTime.now());

  @override
  void initState() {
    super.initState();
    final anchor = widget.value ?? widget.today ?? DateTime.now();
    _visibleMonth = AstryxDates.firstOfMonth(anchor);
    _focused = AstryxDates.dateOnly(anchor);
  }

  bool _enabled(DateTime d) =>
      widget.onChanged != null && AstryxDates.inRange(d, widget.firstDate, widget.lastDate);

  void _select(DateTime d) {
    if (_enabled(d)) widget.onChanged!(AstryxDates.dateOnly(d));
  }

  void _moveFocus(int days) {
    setState(() {
      // Component arithmetic (not Duration) so day-stepping is DST-safe.
      _focused = AstryxDates.addDays(_focused, days);
      if (!AstryxDates.sameMonth(_focused, _visibleMonth)) {
        _visibleMonth = AstryxDates.firstOfMonth(_focused);
      }
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = AstryxDates.addMonths(_visibleMonth, delta);
      _focused = AstryxDates.firstOfMonth(_visibleMonth);
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _moveFocus(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _moveFocus(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveFocus(-7);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _moveFocus(7);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        _changeMonth(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        _changeMonth(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.space:
        _select(_focused);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final blanks = AstryxDates.leadingBlanks(_visibleMonth);
    final count = AstryxDates.daysInMonth(_visibleMonth);

    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: _onKey,
      child: Container(
        width: 300,
        padding: EdgeInsets.all(t.spacing.insetMd),
        decoration: BoxDecoration(
          color: t.color.surfaceDefault,
          borderRadius: t.shape.radiusCard,
          border: Border.all(color: t.color.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(t),
            SizedBox(height: t.spacing.gapMd),
            _weekdayRow(t),
            SizedBox(height: t.spacing.gapSm),
            for (var row = 0; row < 6; row++)
              if (row * 7 - blanks < count)
                Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      Expanded(child: _cell(t, row * 7 + col - blanks + 1, count)),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _header(AstryxTokens t) {
    return Row(
      children: [
        _monthButton(t, forward: false),
        Expanded(
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Text(
                AstryxDates.monthYear(_visibleMonth),
                style: t.typography.label.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        _monthButton(t, forward: true),
      ],
    );
  }

  Widget _monthButton(AstryxTokens t, {required bool forward}) {
    return Semantics(
      button: true,
      label: forward ? 'Next month' : 'Previous month',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _changeMonth(forward ? 1 : -1),
        child: ExcludeSemantics(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: _ChevronPainter(color: t.color.textMuted, forward: forward)),
          ),
        ),
      ),
    );
  }

  Widget _weekdayRow(AstryxTokens t) {
    return Row(
      children: [
        for (final w in AstryxDates.weekdayAbbr)
          Expanded(
            child: Center(
              child: Text(w, style: t.typography.label.copyWith(color: t.color.textMuted, fontSize: 11)),
            ),
          ),
      ],
    );
  }

  Widget _cell(AstryxTokens t, int day, int count) {
    if (day < 1 || day > count) return const SizedBox(height: 36);
    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
    final selected = widget.value != null && AstryxDates.sameDay(date, widget.value!);
    final isToday = AstryxDates.sameDay(date, _today);
    final isFocused = AstryxDates.sameDay(date, _focused);
    final enabled = _enabled(date);

    final fg = !enabled
        ? t.color.textDisabled
        : selected
            ? t.color.textOnAccent
            : t.color.textDefault;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: AstryxDates.longDate(date) + (isToday ? ', today' : ''),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => _select(date) : null,
        child: ExcludeSemantics(
          child: Container(
            height: 36,
            margin: const EdgeInsets.all(1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? t.color.accentDefault : const Color(0x00000000),
              borderRadius: t.shape.radiusControl,
              border: Border.all(
                color: isFocused
                    ? t.color.borderFocus
                    : isToday && !selected
                        ? t.color.borderStrong
                        : const Color(0x00000000),
                width: isFocused ? 2 : 1,
              ),
            ),
            child: Text(
              '$day',
              style: t.typography.label.copyWith(
                color: fg,
                fontWeight: selected || isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.forward});
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
        ? (Path()..moveTo(w * 0.42, h * 0.3)..lineTo(w * 0.6, h * 0.5)..lineTo(w * 0.42, h * 0.7))
        : (Path()..moveTo(w * 0.58, h * 0.3)..lineTo(w * 0.4, h * 0.5)..lineTo(w * 0.58, h * 0.7));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color || old.forward != forward;
}
