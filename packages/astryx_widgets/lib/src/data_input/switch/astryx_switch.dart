import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.switch}
/// A branded on/off switch. Controlled: pass [value] and handle [onChanged]
/// (`null` = disabled). Toggles on tap or keyboard, exposes a toggle semantics
/// node, and animates the thumb via motion tokens (honoring reduced motion).
/// {@endtemplate}
class AstryxSwitch extends StatefulWidget {
  const AstryxSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Accessible name — required, since a bare switch has no visible label.
  final String semanticLabel;

  bool get _enabled => onChanged != null;

  @override
  State<AstryxSwitch> createState() => _AstryxSwitchState();
}

class _AstryxSwitchState extends State<AstryxSwitch> {
  bool _focused = false;

  void _toggle() {
    if (widget._enabled) widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final enabled = widget._enabled;
    final on = widget.value;

    const w = 40.0, h = 24.0, thumb = 18.0;
    final trackColor = on
        ? (enabled ? t.color.accentDefault : t.color.textDisabled)
        : (enabled ? t.color.borderStrong : t.color.borderDefault);

    return Semantics(
      toggled: on,
      enabled: enabled,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _toggle();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: motion.durationNormal,
              curve: motion.curveStandard,
              width: w,
              height: h,
              padding: const EdgeInsets.all(3),
              alignment: on ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(h / 2),
                boxShadow: _focused
                    ? [BoxShadow(color: t.color.borderFocus, spreadRadius: 2)]
                    : null,
              ),
              child: Container(
                width: thumb,
                height: thumb,
                decoration: BoxDecoration(
                  color: t.color.surfaceDefault,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
