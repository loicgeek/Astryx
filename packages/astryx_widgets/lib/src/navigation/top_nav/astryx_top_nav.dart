import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../layout/app_shell/astryx_app_shell.dart';

/// {@template astryx.topnav}
/// A top application bar: a [leading] brand, inline [items] (nav links / mega
/// menus), and right-aligned [actions]. Inside an [AstryxAppShell] it shows a
/// hamburger and hides the inline items when compact, toggling the shell's
/// drawer.
/// {@endtemplate}
class AstryxTopNav extends StatelessWidget {
  const AstryxTopNav({
    super.key,
    this.leading,
    this.items = const [],
    this.actions = const [],
    this.compactBreakpoint = 720,
  });

  final Widget? leading;
  final List<Widget> items;
  final List<Widget> actions;

  /// Used only when not inside an [AstryxAppShell] (which supplies its own).
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final scope = AstryxAppShellScope.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = scope?.isCompact ?? (constraints.maxWidth < compactBreakpoint);
        return Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd),
          decoration: BoxDecoration(
            color: t.color.surfaceRaised,
            border: Border(bottom: BorderSide(color: t.color.borderDefault)),
          ),
          child: Row(
            children: [
              if (compact && scope != null) ...[
                _Hamburger(color: t.color.textDefault, onTap: scope.toggleDrawer),
                SizedBox(width: t.spacing.gapMd),
              ],
              if (leading != null) leading!,
              if (!compact) ...[
                SizedBox(width: t.spacing.gapLg),
                for (final item in items)
                  Padding(padding: EdgeInsets.only(right: t.spacing.gapMd), child: item),
              ],
              const Spacer(),
              for (final action in actions)
                Padding(padding: EdgeInsets.only(left: t.spacing.gapSm), child: action),
            ],
          ),
        );
      },
    );
  }
}

class _Hamburger extends StatelessWidget {
  const _Hamburger({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open navigation',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(painter: _HamburgerPainter(color)),
        ),
      ),
    );
  }
}

class _HamburgerPainter extends CustomPainter {
  const _HamburgerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    for (final fy in [0.34, 0.5, 0.66]) {
      canvas.drawLine(Offset(w * 0.25, size.height * fy), Offset(w * 0.75, size.height * fy), p);
    }
  }

  @override
  bool shouldRepaint(_HamburgerPainter old) => old.color != color;
}
