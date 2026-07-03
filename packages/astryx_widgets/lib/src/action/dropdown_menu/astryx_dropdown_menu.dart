import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One item in an [AstryxDropdownMenu].
class AstryxMenuItem<T> {
  const AstryxMenuItem({required this.value, required this.label, this.leading, this.enabled = true});
  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;
}

/// {@template astryx.dropdownmenu}
/// A button-triggered menu. Tapping [trigger] opens an anchored list; selecting
/// an item invokes [onSelected] and closes. Arrow keys move focus between items,
/// Enter/Space selects, Escape or an outside tap dismisses.
/// {@endtemplate}
class AstryxDropdownMenu<T> extends StatefulWidget {
  const AstryxDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    required this.onSelected,
    this.maxWidth = 280,
  });

  final Widget trigger;
  final List<AstryxMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final double maxWidth;

  @override
  State<AstryxDropdownMenu<T>> createState() => _AstryxDropdownMenuState<T>();
}

class _AstryxDropdownMenuState<T> extends State<AstryxDropdownMenu<T>> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();

  void _close() => _portal.hide();

  void _select(T value) {
    _close();
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: Offset(0, t.spacing.gapSm),
              child: Align(
                alignment: Alignment.topLeft,
                child: _MenuPanel<T>(
                  tokens: t,
                  maxWidth: widget.maxWidth,
                  items: widget.items,
                  onSelected: _select,
                  onDismiss: _close,
                ),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _portal.toggle,
          child: widget.trigger,
        ),
      ),
    );
  }
}

class _MenuPanel<T> extends StatelessWidget {
  const _MenuPanel({
    required this.tokens,
    required this.maxWidth,
    required this.items,
    required this.onSelected,
    required this.onDismiss,
  });

  final AstryxTokens tokens;
  final double maxWidth;
  final List<AstryxMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            FocusScope.of(context).nextFocus(),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            FocusScope.of(context).previousFocus(),
      },
      child: FocusTraversalGroup(
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.all(tokens.spacing.insetXs),
            decoration: BoxDecoration(
              color: tokens.color.surfaceOverlay,
              borderRadius: tokens.shape.radiusOverlay,
              boxShadow: tokens.elevation.overlay,
              border: Border.all(color: tokens.color.borderDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++)
                  _MenuItemButton<T>(
                    tokens: tokens,
                    item: items[i],
                    autofocus: i == 0,
                    onSelected: onSelected,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemButton<T> extends StatefulWidget {
  const _MenuItemButton({
    required this.tokens,
    required this.item,
    required this.autofocus,
    required this.onSelected,
  });

  final AstryxTokens tokens;
  final AstryxMenuItem<T> item;
  final bool autofocus;
  final ValueChanged<T> onSelected;

  @override
  State<_MenuItemButton<T>> createState() => _MenuItemButtonState<T>();
}

class _MenuItemButtonState<T> extends State<_MenuItemButton<T>> {
  bool _highlighted = false;

  void _invoke() {
    if (widget.item.enabled) widget.onSelected(widget.item.value);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final item = widget.item;
    final fg = item.enabled ? t.color.textDefault : t.color.textDisabled;

    return Semantics(
      button: true,
      enabled: item.enabled,
      label: item.label,
      child: FocusableActionDetector(
        enabled: item.enabled,
        autofocus: widget.autofocus,
        mouseCursor: item.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _highlighted = v),
        onShowFocusHighlight: (v) => setState(() => _highlighted = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            _invoke();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? _invoke : null,
          child: ExcludeSemantics(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: t.spacing.insetSm,
                vertical: t.spacing.insetSm,
              ),
              decoration: BoxDecoration(
                color: _highlighted ? t.color.surfaceSunken : const Color(0x00000000),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                spacing: t.spacing.gapMd,
                children: [
                  if (item.leading != null)
                    IconTheme.merge(data: IconThemeData(color: fg, size: 16), child: item.leading!),
                  Expanded(child: Text(item.label, style: t.typography.body.copyWith(color: fg))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
