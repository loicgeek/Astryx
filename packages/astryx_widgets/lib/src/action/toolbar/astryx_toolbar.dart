import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.toolbar}
/// A horizontal group of controls (buttons, toggles, dividers) on a raised
/// surface. Left/Right arrows move focus between the toolbar's controls (roving
/// tab-stop). Use [AstryxToolbar.divider] to separate groups.
/// {@endtemplate}
class AstryxToolbar extends StatelessWidget {
  const AstryxToolbar({super.key, required this.children});

  final List<Widget> children;

  /// A vertical separator for grouping toolbar items.
  static Widget divider() => const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: FocusTraversalGroup(
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.arrowRight): NextFocusIntent(),
            SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousFocusIntent(),
          },
          child: Container(
            padding: EdgeInsets.all(t.spacing.insetXs),
            decoration: BoxDecoration(
              color: t.color.surfaceRaised,
              borderRadius: t.shape.radiusControl,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: t.spacing.gapSm,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(width: 1, height: 20, color: t.color.borderDefault);
  }
}
