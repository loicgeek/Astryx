import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../text_input/astryx_text_input.dart';

/// {@template astryx.typeahead}
/// A text field with a suggestions overlay. As the user types, [suggestions]
/// is queried and matches appear below the field; ArrowUp/Down move the
/// highlight, Enter selects it, Escape closes, and items are also tappable.
/// [itemLabel] renders each suggestion; [onSelected] fires on choice.
/// {@endtemplate}
class AstryxTypeahead<T> extends StatefulWidget {
  const AstryxTypeahead({
    super.key,
    required this.suggestions,
    required this.itemLabel,
    required this.onSelected,
    this.controller,
    this.hintText,
    this.maxSuggestions = 8,
  });

  /// Returns the matches for the current query (already filtered/sorted).
  final List<T> Function(String query) suggestions;
  final String Function(T item) itemLabel;
  final ValueChanged<T> onSelected;
  final TextEditingController? controller;
  final String? hintText;
  final int maxSuggestions;

  @override
  State<AstryxTypeahead<T>> createState() => _AstryxTypeaheadState<T>();
}

class _AstryxTypeaheadState<T> extends State<AstryxTypeahead<T>> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final TextEditingController _text = widget.controller ?? TextEditingController();
  final _fieldFocus = FocusNode();

  List<T> _matches = const [];
  int _highlight = -1;

  @override
  void dispose() {
    if (widget.controller == null) _text.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final matches = widget.suggestions(value).take(widget.maxSuggestions).toList();
    setState(() {
      _matches = matches;
      _highlight = matches.isEmpty ? -1 : 0;
    });
    if (matches.isEmpty) {
      _portal.hide();
    } else {
      _portal.show();
    }
  }

  void _select(T item) {
    widget.onSelected(item);
    _text.text = widget.itemLabel(item);
    _portal.hide();
    setState(() => _matches = const []);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _matches.isEmpty) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        setState(() => _highlight = (_highlight + 1) % _matches.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        setState(() => _highlight = (_highlight - 1 + _matches.length) % _matches.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        _portal.hide();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => _SuggestionsOverlay(
          link: _link,
          tokens: t,
          count: _matches.length,
          highlight: _highlight,
          itemBuilder: (i) => widget.itemLabel(_matches[i]),
          onPick: (i) => _select(_matches[i]),
        ),
        child: Focus(
          // Ancestor of the field: catches arrows/Escape the text editor ignores.
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: AstryxTextInput(
            controller: _text,
            focusNode: _fieldFocus,
            hintText: widget.hintText,
            onChanged: _onChanged,
            onSubmitted: (_) {
              if (_highlight >= 0 && _highlight < _matches.length) _select(_matches[_highlight]);
            },
          ),
        ),
      ),
    );
  }
}

class _SuggestionsOverlay extends StatelessWidget {
  const _SuggestionsOverlay({
    required this.link,
    required this.tokens,
    required this.count,
    required this.highlight,
    required this.itemBuilder,
    required this.onPick,
  });

  final LayerLink link;
  final AstryxTokens tokens;
  final int count;
  final int highlight;
  final String Function(int) itemBuilder;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return CompositedTransformFollower(
      link: link,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: Offset(0, t.spacing.gapSm),
      child: Align(
        alignment: Alignment.topLeft,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 260, minWidth: 200, maxWidth: 360),
            padding: EdgeInsets.all(t.spacing.insetXs),
            decoration: BoxDecoration(
              color: t.color.surfaceOverlay,
              borderRadius: t.shape.radiusOverlay,
              boxShadow: t.elevation.overlay,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < count; i++)
                    _SuggestionTile(
                      label: itemBuilder(i),
                      highlighted: i == highlight,
                      tokens: t,
                      onTap: () => onPick(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.label,
    required this.highlighted,
    required this.tokens,
    required this.onTap,
  });

  final String label;
  final bool highlighted;
  final AstryxTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Semantics(
      button: true,
      selected: highlighted,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: t.spacing.insetSm, vertical: t.spacing.insetSm),
            decoration: BoxDecoration(
              color: highlighted ? t.color.surfaceSunken : const Color(0x00000000),
              borderRadius: t.shape.radiusControl,
            ),
            child: Text(label, style: t.typography.body.copyWith(color: t.color.textDefault)),
          ),
        ),
      ),
    );
  }
}
