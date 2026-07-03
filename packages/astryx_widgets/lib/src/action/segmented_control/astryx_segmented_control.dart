import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One choice in an [AstryxSegmentedControl].
class AstryxSegment<T> {
  const AstryxSegment({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final Widget? icon;
}

/// {@template astryx.segmentedcontrol}
/// A single-select control rendering mutually-exclusive [segments] inline.
/// Behaves like a radio group: one keyboard stop, Left/Right (or Up/Down) move
/// the selection; each segment announces its selected state.
/// {@endtemplate}
class AstryxSegmentedControl<T> extends StatelessWidget {
  const AstryxSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.focusNode,
  });

  final List<AstryxSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final FocusNode? focusNode;

  void _move(int dir) {
    if (onChanged == null || segments.isEmpty) return;
    final i = segments.indexWhere((s) => s.value == value);
    final next = ((i < 0 ? 0 : i) + dir) % segments.length;
    onChanged!(segments[(next + segments.length) % segments.length].value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight || LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onChanged != null;

    return _FocusRing(
      focusNode: focusNode,
      builder: (context, focused) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: t.color.surfaceSunken,
          borderRadius: t.shape.radiusControl,
          boxShadow: focused ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            for (final seg in segments)
              _SegmentButton(
                selected: seg.value == value,
                enabled: enabled,
                label: seg.label,
                icon: seg.icon,
                onTap: enabled ? () => onChanged!(seg.value) : null,
              ),
          ],
        ),
      ),
      onKey: enabled ? _onKey : null,
      canFocus: enabled,
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.selected,
    required this.enabled,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final fg = !enabled
        ? t.color.textDisabled
        : selected
            ? t.color.textDefault
            : t.color.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: AnimatedContainer(
            duration: motion.durationFast,
            curve: motion.curveStandard,
            padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
            decoration: BoxDecoration(
              color: selected ? t.color.surfaceDefault : const Color(0x00000000),
              borderRadius: BorderRadius.circular(6),
              boxShadow: selected ? t.elevation.raised : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: t.spacing.gapSm,
              children: [
                if (icon != null)
                  IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: icon!),
                Text(label, style: t.typography.label.copyWith(color: fg, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper: a focusable region reporting keyboard-focus state.
class _FocusRing extends StatefulWidget {
  const _FocusRing({required this.builder, this.onKey, this.canFocus = true, this.focusNode});
  final Widget Function(BuildContext, bool focused) builder;
  final FocusOnKeyEventCallback? onKey;
  final bool canFocus;
  final FocusNode? focusNode;

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: widget.canFocus,
      onKeyEvent: widget.onKey,
      onFocusChange: (v) => setState(() => _focused = v),
      child: widget.builder(context, _focused),
    );
  }
}
