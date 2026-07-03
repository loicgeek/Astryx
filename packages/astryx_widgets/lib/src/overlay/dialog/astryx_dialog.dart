import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../content/heading/astryx_heading.dart';

/// {@template astryx.dialog}
/// A modal dialog surface: optional title (header role), content, and a trailing
/// actions row. Presented via [showAstryxDialog], which traps focus, dims the
/// page, and dismisses on backdrop tap or Escape.
/// {@endtemplate}
class AstryxDialog extends StatelessWidget {
  const AstryxDialog({
    super.key,
    this.title,
    required this.content,
    this.actions = const [],
    this.maxWidth = 440,
  });

  final String? title;
  final Widget content;
  final List<Widget> actions;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: title != null,
      label: title,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            margin: EdgeInsets.all(t.spacing.insetLg),
            padding: EdgeInsets.all(t.spacing.insetLg),
            decoration: BoxDecoration(
              color: t.color.surfaceOverlay,
              borderRadius: t.shape.radiusOverlay,
              boxShadow: t.elevation.overlay,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: t.spacing.gapLg,
              children: [
                if (title != null) AstryxHeading(title!, level: AstryxHeadingLevel.h2),
                content,
                if (actions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: t.spacing.gapMd,
                    children: actions,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Presents [builder]'s widget (typically an [AstryxDialog]) as a modal route.
/// Honors reduced motion (instant when animations are disabled).
Future<T?> showAstryxDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final motion = AstryxMotion.resolve(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0x8A000000),
    transitionDuration: motion.durationNormal,
    pageBuilder: (context, _, __) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).maybePop(),
        },
        child: Focus(autofocus: true, child: AstryxTextDefaults(child: builder(context))),
      );
    },
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: motion.curveDecelerate);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
