import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A link inside an [AstryxMegaColumn].
class AstryxMegaLink {
  const AstryxMegaLink({required this.label, this.description, this.onTap});
  final String label;
  final String? description;
  final VoidCallback? onTap;
}

/// A titled column of links in an [AstryxMegaMenu] panel.
class AstryxMegaColumn {
  const AstryxMegaColumn({this.title, required this.links});
  final String? title;
  final List<AstryxMegaLink> links;
}

/// {@template astryx.megamenu}
/// A top-nav entry that opens a multi-column panel of links. Opens on tap
/// (all platforms) or hover (pointer devices) and dismisses on outside tap or
/// Escape. On touch the same panel simply opens below the trigger.
/// {@endtemplate}
class AstryxMegaMenu extends StatefulWidget {
  const AstryxMegaMenu({super.key, required this.label, required this.columns, this.columnWidth = 200});

  final String label;
  final List<AstryxMegaColumn> columns;
  final double columnWidth;

  @override
  State<AstryxMegaMenu> createState() => _AstryxMegaMenuState();
}

class _AstryxMegaMenuState extends State<AstryxMegaMenu> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();

  void _open() => _portal.show();
  void _close() => _portal.hide();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _open(),
        child: OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (context) => _MegaOverlay(
            link: _link,
            tokens: t,
            columns: widget.columns,
            columnWidth: widget.columnWidth,
            onDismiss: _close,
          ),
          child: Semantics(
            button: true,
            label: widget.label,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _portal.toggle,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: t.spacing.gapSm,
                  children: [
                    Text(widget.label, style: t.typography.label.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w600)),
                    _Caret(color: t.color.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MegaOverlay extends StatelessWidget {
  const _MegaOverlay({
    required this.link,
    required this.tokens,
    required this.columns,
    required this.columnWidth,
    required this.onDismiss,
  });

  final LayerLink link;
  final AstryxTokens tokens;
  final List<AstryxMegaColumn> columns;
  final double columnWidth;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: onDismiss),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, t.spacing.gapSm),
          child: Align(
            alignment: Alignment.topLeft,
            child: CallbackShortcuts(
              bindings: {const SingleActivator(LogicalKeyboardKey.escape): onDismiss},
              child: Focus(
                autofocus: true,
                child: AstryxTextDefaults(
                  child: Container(
                    padding: EdgeInsets.all(t.spacing.insetMd),
                    decoration: BoxDecoration(
                      color: t.color.surfaceOverlay,
                      borderRadius: t.shape.radiusOverlay,
                      boxShadow: t.elevation.overlay,
                      border: Border.all(color: t.color.borderDefault),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: t.spacing.gapLg,
                      children: [
                        for (final col in columns)
                          SizedBox(
                            width: columnWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: t.spacing.gapSm,
                              children: [
                                if (col.title != null)
                                  Text(col.title!.toUpperCase(),
                                      style: t.typography.label.copyWith(color: t.color.textMuted, fontSize: 11, letterSpacing: 0.6)),
                                for (final linkItem in col.links)
                                  _MegaLinkTile(link: linkItem, tokens: t, onNavigate: onDismiss),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MegaLinkTile extends StatelessWidget {
  const _MegaLinkTile({required this.link, required this.tokens, required this.onNavigate});
  final AstryxMegaLink link;
  final AstryxTokens tokens;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Semantics(
      button: true,
      label: link.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          link.onTap?.call();
          onNavigate();
        },
        child: ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: t.spacing.insetXs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.label, style: t.typography.body.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w600)),
                if (link.description != null)
                  Text(link.description!, style: t.typography.label.copyWith(color: t.color.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A tiny chevron-down glyph (no Material dependency).
class _Caret extends StatelessWidget {
  const _Caret({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 12, height: 12, child: CustomPaint(painter: _CaretPainter(color)));
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.25, h * 0.4)
        ..lineTo(w * 0.5, h * 0.65)
        ..lineTo(w * 0.75, h * 0.4),
      p,
    );
  }

  @override
  bool shouldRepaint(_CaretPainter old) => old.color != color;
}
