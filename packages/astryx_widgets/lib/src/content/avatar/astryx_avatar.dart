import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

enum AstryxAvatarSize { sm, md, lg, xl }

enum AstryxAvatarShape { circle, rounded }

/// {@template astryx.avatar}
/// Represents a user or entity. Renders, in priority order: an [image], then
/// [initials], then a fallback icon. Always exposes an accessible [label].
/// {@endtemplate}
class AstryxAvatar extends StatelessWidget {
  const AstryxAvatar({
    super.key,
    this.image,
    this.initials,
    this.icon,
    this.size = AstryxAvatarSize.md,
    this.shape = AstryxAvatarShape.circle,
    required this.label,
  });

  final ImageProvider? image;
  final String? initials;
  final Widget? icon;
  final AstryxAvatarSize size;
  final AstryxAvatarShape shape;

  /// Accessible name (e.g. the person's full name). Required — an avatar with no
  /// label is invisible to screen readers.
  final String label;

  double get _dimension => switch (size) {
        AstryxAvatarSize.sm => 24,
        AstryxAvatarSize.md => 32,
        AstryxAvatarSize.lg => 40,
        AstryxAvatarSize.xl => 56,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dim = _dimension;
    final radius = switch (shape) {
      AstryxAvatarShape.circle => BorderRadius.circular(dim / 2),
      AstryxAvatarShape.rounded => t.shape.radiusControl,
    };

    Widget child;
    if (image != null) {
      child = Image(image: image!, width: dim, height: dim, fit: BoxFit.cover);
    } else if (initials != null && initials!.isNotEmpty) {
      child = Center(
        child: Text(
          _clampInitials(initials!),
          style: t.typography.label.copyWith(
            color: t.color.textOnAccent,
            fontSize: dim * 0.38,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      child = Center(
        child: IconTheme.merge(
          data: IconThemeData(color: t.color.textOnAccent, size: dim * 0.55),
          child: icon ?? const _FallbackGlyph(),
        ),
      );
    }

    return Semantics(
      label: label,
      image: true,
      container: true,
      // Initials/icon are decorative — the avatar announces [label], not "AL".
      excludeSemantics: true,
      child: Container(
        width: dim,
        height: dim,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.color.accentDefault,
          borderRadius: radius,
        ),
        child: child,
      ),
    );
  }

  String _clampInitials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts.first[0] + parts[1][0]).toUpperCase();
    }
    return s.trim().substring(0, s.trim().length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _FallbackGlyph extends StatelessWidget {
  const _FallbackGlyph();

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? const Color(0xFFFFFFFF);
    final size = IconTheme.of(context).size ?? 18;
    // A simple person silhouette drawn without a Material icon dependency.
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PersonPainter(color)),
    );
  }
}

class _PersonPainter extends CustomPainter {
  const _PersonPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final w = size.width, h = size.height;
    canvas.drawCircle(Offset(w / 2, h * 0.32), w * 0.2, p);
    final body = Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.6, h * 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.3)),
      p,
    );
  }

  @override
  bool shouldRepaint(_PersonPainter old) => old.color != color;
}
