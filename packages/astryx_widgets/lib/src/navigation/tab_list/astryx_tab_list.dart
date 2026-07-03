import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One tab in an [AstryxTabList].
class AstryxTab<T> {
  const AstryxTab({required this.value, required this.label, this.icon, this.enabled = true});
  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
}

/// {@template astryx.tablist}
/// A horizontal tab bar with an animated underline. Behaves as a tablist: one
/// keyboard stop, Left/Right move the active tab (selection follows focus), and
/// each tab announces its selected state. Selecting invokes [onChanged].
/// {@endtemplate}
class AstryxTabList<T> extends StatelessWidget {
  const AstryxTabList({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.focusNode,
  });

  final List<AstryxTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final FocusNode? focusNode;

  void _move(int dir) {
    if (onChanged == null || tabs.isEmpty) return;
    final enabledTabs = [for (final t in tabs) if (t.enabled) t];
    if (enabledTabs.isEmpty) return;
    final curr = enabledTabs.indexWhere((t) => t.value == value);
    final base = curr < 0 ? 0 : curr;
    final next = (base + dir + enabledTabs.length) % enabledTabs.length;
    onChanged!(enabledTabs[next].value);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _move(1);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final enabled = onChanged != null;

    return _TabFocus(
      focusNode: focusNode,
      canFocus: enabled,
      onKey: enabled ? _onKey : null,
      builder: (context, focused) => Semantics(
        container: true,
        explicitChildNodes: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.color.borderDefault)),
            borderRadius: focused ? t.shape.radiusControl : null,
            boxShadow: focused ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tab in tabs)
                _TabItem<T>(
                  tab: tab,
                  selected: tab.value == value,
                  onTap: enabled && tab.enabled ? () => onChanged!(tab.value) : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem<T> extends StatelessWidget {
  const _TabItem({required this.tab, required this.selected, required this.onTap});
  final AstryxTab<T> tab;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final fg = !tab.enabled
        ? t.color.textDisabled
        : selected
            ? t.color.textDefault
            : t.color.textMuted;

    return Semantics(
      selected: selected,
      button: true,
      enabled: tab.enabled,
      label: tab.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          // The Stack sizes to the padded label; the positioned underline
          // stretches to that width — safe under unbounded constraints.
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  t.spacing.insetMd,
                  t.spacing.insetSm,
                  t.spacing.insetMd,
                  t.spacing.insetSm + 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: t.spacing.gapSm,
                  children: [
                    if (tab.icon != null)
                      IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: tab.icon!),
                    Text(tab.label, style: t.typography.label.copyWith(color: fg, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: motion.durationFast,
                  curve: motion.curveStandard,
                  height: 2,
                  color: selected ? t.color.accentDefault : const Color(0x00000000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A focusable region reporting keyboard-focus state (local to tabs).
class _TabFocus extends StatefulWidget {
  const _TabFocus({required this.builder, this.onKey, this.canFocus = true, this.focusNode});
  final Widget Function(BuildContext, bool focused) builder;
  final FocusOnKeyEventCallback? onKey;
  final bool canFocus;
  final FocusNode? focusNode;

  @override
  State<_TabFocus> createState() => _TabFocusState();
}

class _TabFocusState extends State<_TabFocus> {
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
