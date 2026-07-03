import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Opens a full-screen lightbox over [items] (usually images). Pinch/scroll to
/// zoom, swipe to page, and dismiss with the close button or Escape.
Future<void> showAstryxLightbox(
  BuildContext context, {
  required List<Widget> items,
  int initialIndex = 0,
}) {
  final motion = AstryxMotion.resolve(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xE6000000),
    transitionDuration: motion.durationNormal,
    pageBuilder: (context, _, __) => _Lightbox(items: items, initialIndex: initialIndex),
    transitionBuilder: (context, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: motion.curveDecelerate),
      child: child,
    ),
  );
}

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.items, required this.initialIndex});
  final List<Widget> items;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).maybePop()},
      child: Focus(
        autofocus: true,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          label: 'Lightbox, item ${_index + 1} of ${widget.items.length}',
          child: Stack(
            children: [
              PageView.builder(
                controller: _pages,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: widget.items[i],
                  ),
                ),
              ),
              Positioned(
                top: t.spacing.insetLg,
                right: t.spacing.insetLg,
                child: SafeArea(child: _CloseButton(onTap: () => Navigator.of(context).maybePop())),
              ),
              if (widget.items.length > 1)
                Positioned(
                  bottom: t.spacing.insetLg,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Center(
                      child: Text(
                        '${_index + 1} / ${widget.items.length}',
                        style: t.typography.label.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
          child: const CustomPaint(painter: _XPainter(Color(0xFFFFFFFF))),
        ),
      ),
    );
  }
}

class _XPainter extends CustomPainter {
  const _XPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final pad = size.width * 0.34;
    canvas.drawLine(Offset(pad, pad), Offset(size.width - pad, size.height - pad), p);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(pad, size.height - pad), p);
  }

  @override
  bool shouldRepaint(_XPainter old) => false;
}
