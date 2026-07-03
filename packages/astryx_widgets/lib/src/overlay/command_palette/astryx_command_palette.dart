import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../data_input/text_input/astryx_text_input.dart';

/// One entry in an [AstryxCommandPalette].
class AstryxCommand {
  const AstryxCommand({required this.label, required this.onRun, this.hint, this.keywords = const []});
  final String label;
  final VoidCallback onRun;
  final String? hint;

  /// Extra terms matched by the search, beyond [label].
  final List<String> keywords;
}

/// Opens the command palette as a modal (Cmd/Ctrl-K style). Type to filter,
/// ArrowUp/Down to move, Enter to run, Escape to dismiss.
Future<void> showAstryxCommandPalette(
  BuildContext context, {
  required List<AstryxCommand> commands,
  String hintText = 'Type a command…',
}) {
  final motion = AstryxMotion.resolve(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0x66000000),
    transitionDuration: motion.durationFast,
    pageBuilder: (context, _, __) => _CommandPalette(commands: commands, hintText: hintText),
    transitionBuilder: (context, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: motion.curveDecelerate),
      child: child,
    ),
  );
}

/// Wraps [child] so Cmd/Ctrl+K opens the command palette anywhere beneath it.
class AstryxCommandPaletteShortcut extends StatelessWidget {
  const AstryxCommandPaletteShortcut({super.key, required this.commands, required this.child});

  final List<AstryxCommand> commands;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showAstryxCommandPalette(context, commands: commands),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showAstryxCommandPalette(context, commands: commands),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

class _CommandPalette extends StatefulWidget {
  const _CommandPalette({required this.commands, required this.hintText});
  final List<AstryxCommand> commands;
  final String hintText;

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  final _text = TextEditingController();
  final _fieldFocus = FocusNode();
  String _query = '';
  int _highlight = 0;

  @override
  void initState() {
    super.initState();
    _fieldFocus.requestFocus();
  }

  @override
  void dispose() {
    _text.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  List<AstryxCommand> get _matches {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.commands;
    return [
      for (final c in widget.commands)
        if (c.label.toLowerCase().contains(q) ||
            (c.hint?.toLowerCase().contains(q) ?? false) ||
            c.keywords.any((k) => k.toLowerCase().contains(q)))
          c,
    ];
  }

  void _run(AstryxCommand c) {
    Navigator.of(context).pop();
    c.onRun();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final matches = _matches;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        setState(() => _highlight = matches.isEmpty ? 0 : (_highlight + 1) % matches.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        setState(() => _highlight = matches.isEmpty ? 0 : (_highlight - 1 + matches.length) % matches.length);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final matches = _matches;
    final highlight = matches.isEmpty ? -1 : _highlight.clamp(0, matches.length - 1);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).maybePop()},
      child: Align(
        alignment: const Alignment(0, -0.5),
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: Container(
            width: 560,
            margin: EdgeInsets.all(t.spacing.insetLg),
            constraints: const BoxConstraints(maxHeight: 420),
            decoration: BoxDecoration(
              color: t.color.surfaceOverlay,
              borderRadius: t.shape.radiusOverlay,
              boxShadow: t.elevation.overlay,
              border: Border.all(color: t.color.borderDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(t.spacing.insetMd),
                  child: Focus(
                    skipTraversal: true,
                    onKeyEvent: _onKey,
                    child: AstryxTextInput(
                      controller: _text,
                      focusNode: _fieldFocus,
                      hintText: widget.hintText,
                      leading: _SearchGlyph(color: t.color.textMuted),
                      textInputAction: TextInputAction.go,
                      onChanged: (v) => setState(() {
                        _query = v;
                        _highlight = 0;
                      }),
                      onSubmitted: (_) {
                        if (highlight >= 0) _run(matches[highlight]);
                      },
                    ),
                  ),
                ),
                Container(height: 1, color: t.color.borderDefault),
                Flexible(
                  child: matches.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(t.spacing.insetLg),
                          child: Text('No matching commands',
                              style: t.typography.body.copyWith(color: t.color.textMuted)),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(t.spacing.insetXs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < matches.length; i++)
                                _CommandTile(
                                  command: matches[i],
                                  highlighted: i == highlight,
                                  tokens: t,
                                  onTap: () => _run(matches[i]),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandTile extends StatelessWidget {
  const _CommandTile({required this.command, required this.highlighted, required this.tokens, required this.onTap});
  final AstryxCommand command;
  final bool highlighted;
  final AstryxTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Semantics(
      button: true,
      selected: highlighted,
      label: command.label,
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
            child: Row(
              children: [
                Expanded(child: Text(command.label, style: t.typography.body.copyWith(color: t.color.textDefault))),
                if (command.hint != null)
                  Text(command.hint!, style: t.typography.label.copyWith(color: t.color.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchGlyph extends StatelessWidget {
  const _SearchGlyph({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 16, height: 16, child: CustomPaint(painter: _SearchPainter(color)));
}

class _SearchPainter extends CustomPainter {
  const _SearchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width * 0.42, size.height * 0.42);
    canvas.drawCircle(c, size.width * 0.28, p);
    canvas.drawLine(Offset(size.width * 0.62, size.height * 0.62), Offset(size.width * 0.85, size.height * 0.85), p);
  }

  @override
  bool shouldRepaint(_SearchPainter old) => old.color != color;
}
