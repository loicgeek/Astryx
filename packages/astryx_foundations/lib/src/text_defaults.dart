import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Establishes token-based [DefaultTextStyle] and [IconTheme] for a subtree.
///
/// Content rendered in the root [Overlay] (dialogs, popovers, menus, toasts) has
/// no ambient `DefaultTextStyle` — since Astryx is Material-free there is no
/// `Material` to supply one — so bare `Text` there would fall back to the
/// framework's debug style (the amber double-underline). Wrap every overlay
/// surface in this so all text/icons inherit the theme.
class AstryxTextDefaults extends StatelessWidget {
  const AstryxTextDefaults({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DefaultTextStyle(
      style: t.typography.body.copyWith(
        color: t.color.textDefault,
        decoration: TextDecoration.none,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: t.color.textDefault, size: 18),
        child: child,
      ),
    );
  }
}
