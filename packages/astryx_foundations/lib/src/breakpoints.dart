import 'package:flutter/widgets.dart';

/// Responsive breakpoints, aligned with the Astryx web scale. Prefer
/// [BuildContext.breakpoint] (MediaQuery-based) or a `LayoutBuilder` for
/// container-query-like behavior.
enum AstryxBreakpoint {
  xs, // < 480  — compact phones
  sm, // < 768  — phones / small tablets
  md, // < 1024 — tablets / small laptops
  lg, // < 1440 — laptops
  xl; // >= 1440 — large desktops

  static AstryxBreakpoint fromWidth(double width) {
    if (width < 480) return AstryxBreakpoint.xs;
    if (width < 768) return AstryxBreakpoint.sm;
    if (width < 1024) return AstryxBreakpoint.md;
    if (width < 1440) return AstryxBreakpoint.lg;
    return AstryxBreakpoint.xl;
  }

  bool operator >=(AstryxBreakpoint other) => index >= other.index;
  bool operator <=(AstryxBreakpoint other) => index <= other.index;
}

extension AstryxBreakpointContext on BuildContext {
  AstryxBreakpoint get breakpoint =>
      AstryxBreakpoint.fromWidth(MediaQuery.sizeOf(this).width);
}

/// A value that varies by breakpoint. Falls back to the nearest smaller
/// defined value (mobile-first cascade).
class ResponsiveValue<T> {
  const ResponsiveValue({required this.xs, this.sm, this.md, this.lg, this.xl});

  final T xs;
  final T? sm;
  final T? md;
  final T? lg;
  final T? xl;

  T resolve(AstryxBreakpoint bp) {
    return switch (bp) {
      AstryxBreakpoint.xl => xl ?? lg ?? md ?? sm ?? xs,
      AstryxBreakpoint.lg => lg ?? md ?? sm ?? xs,
      AstryxBreakpoint.md => md ?? sm ?? xs,
      AstryxBreakpoint.sm => sm ?? xs,
      AstryxBreakpoint.xs => xs,
    };
  }

  T of(BuildContext context) => resolve(context.breakpoint);
}
