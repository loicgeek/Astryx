import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

/// Exposes the [AstryxAppShell]'s drawer control + compact state to descendants
/// (e.g. a top-nav hamburger). Read via [AstryxAppShellScope.of].
class AstryxAppShellScope extends InheritedWidget {
  const AstryxAppShellScope({
    super.key,
    required this.isCompact,
    required this.isDrawerOpen,
    required this.toggleDrawer,
    required super.child,
  });

  final bool isCompact;
  final bool isDrawerOpen;
  final VoidCallback toggleDrawer;

  static AstryxAppShellScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AstryxAppShellScope>();

  @override
  bool updateShouldNotify(AstryxAppShellScope old) =>
      isCompact != old.isCompact || isDrawerOpen != old.isDrawerOpen;
}

/// {@template astryx.appshell}
/// A responsive application scaffold: an optional [topNav] over a [sideNav] +
/// [content] region. Above [breakpoint] the side nav is docked inline; below
/// it collapses to a slide-in drawer toggled via [AstryxAppShellScope]
/// (e.g. a top-nav hamburger).
/// {@endtemplate}
class AstryxAppShell extends StatefulWidget {
  const AstryxAppShell({
    super.key,
    required this.sideNav,
    required this.content,
    this.topNav,
    this.sideNavWidth = 260,
    this.breakpoint = 1024,
  });

  final Widget sideNav;
  final Widget content;
  final Widget? topNav;
  final double sideNavWidth;
  final double breakpoint;

  @override
  State<AstryxAppShell> createState() => _AstryxAppShellState();
}

class _AstryxAppShellState extends State<AstryxAppShell> {
  bool _drawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < widget.breakpoint;
        if (!compact && _drawerOpen) {
          // Docking the rail; ensure the drawer state resets.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _drawerOpen = false);
          });
        }

        return AstryxAppShellScope(
          isCompact: compact,
          isDrawerOpen: _drawerOpen,
          toggleDrawer: () => setState(() => _drawerOpen = !_drawerOpen),
          child: compact ? _buildCompact(t, motion) : _buildWide(t),
        );
      },
    );
  }

  Widget _buildWide(AstryxTokens t) {
    return Column(
      children: [
        if (widget.topNav != null) widget.topNav!,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: widget.sideNavWidth, child: widget.sideNav),
              Container(width: 1, color: t.color.borderDefault),
              Expanded(child: widget.content),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(AstryxTokens t, AstryxMotionTokens motion) {
    return Stack(
      children: [
        Column(
          children: [
            if (widget.topNav != null) widget.topNav!,
            Expanded(child: widget.content),
          ],
        ),
        // Scrim + slide-in drawer.
        if (_drawerOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _drawerOpen = false),
              child: ColoredBox(color: const Color(0x66000000)),
            ),
          ),
        AnimatedPositioned(
          duration: motion.durationNormal,
          curve: motion.curveDecelerate,
          top: 0,
          bottom: 0,
          left: _drawerOpen ? 0 : -widget.sideNavWidth,
          width: widget.sideNavWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(boxShadow: _drawerOpen ? t.elevation.overlay : const []),
            child: widget.sideNav,
          ),
        ),
      ],
    );
  }
}
