import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/widgets.dart';

import '../../content/code/astryx_code.dart';
import '../../feedback/badge/astryx_badge.dart';
import '../../feedback/spinner/astryx_spinner.dart';

/// Execution state of a tool call.
enum AstryxToolStatus { running, success, error }

/// One tool invocation by the assistant.
class AstryxToolCall {
  const AstryxToolCall({
    required this.name,
    required this.status,
    this.arguments,
    this.result,
  });

  final String name;
  final AstryxToolStatus status;

  /// Serialized arguments (shown in a code block when expanded).
  final String? arguments;

  /// Serialized result/output (shown when expanded).
  final String? result;
}

/// {@template astryx.chattoolcalls}
/// Renders an assistant's tool invocations as collapsible panels. Each shows the
/// tool name and a status (running spinner / success / error badge); expanding
/// reveals the arguments and result as code blocks. For building agent chat UIs.
/// {@endtemplate}
class AstryxChatToolCalls extends StatelessWidget {
  const AstryxChatToolCalls({super.key, required this.calls});

  final List<AstryxToolCall> calls;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapSm,
        children: [for (final c in calls) _ToolCallPanel(call: c)],
      ),
    );
  }
}

class _ToolCallPanel extends StatefulWidget {
  const _ToolCallPanel({required this.call});
  final AstryxToolCall call;

  @override
  State<_ToolCallPanel> createState() => _ToolCallPanelState();
}

class _ToolCallPanelState extends State<_ToolCallPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final motion = AstryxMotion.resolve(context);
    final call = widget.call;
    final canExpand = call.arguments != null || call.result != null;

    return Container(
      decoration: BoxDecoration(
        color: t.color.surfaceSunken,
        borderRadius: t.shape.radiusControl,
        border: Border.all(color: t.color.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: canExpand,
            expanded: canExpand ? _expanded : null,
            label: 'Tool ${call.name}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: canExpand ? () => setState(() => _expanded = !_expanded) : null,
              child: ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsets.all(t.spacing.insetSm),
                  child: Row(
                    spacing: t.spacing.gapMd,
                    children: [
                      if (canExpand)
                        AnimatedRotation(
                          turns: _expanded ? 0.25 : 0,
                          duration: motion.durationFast,
                          child: SizedBox(width: 14, height: 14, child: CustomPaint(painter: _ChevronPainter(t.color.textMuted))),
                        ),
                      _wrench(t),
                      Expanded(
                        child: Text(
                          call.name,
                          style: t.typography.code.copyWith(color: t.color.textDefault, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _status(call.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_expanded && canExpand)
            Padding(
              padding: EdgeInsets.fromLTRB(t.spacing.insetSm, 0, t.spacing.insetSm, t.spacing.insetSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: t.spacing.gapSm,
                children: [
                  if (call.arguments != null) ...[
                    _sectionLabel(t, 'Arguments'),
                    AstryxCodeBlock(call.arguments!),
                  ],
                  if (call.result != null) ...[
                    _sectionLabel(t, 'Result'),
                    AstryxCodeBlock(call.result!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(AstryxTokens t, String text) =>
      Text(text.toUpperCase(), style: t.typography.label.copyWith(color: t.color.textMuted, fontSize: 10, letterSpacing: 0.6));

  Widget _status(AstryxToolStatus status) {
    return switch (status) {
      AstryxToolStatus.running => const AstryxSpinner(size: AstryxSpinnerSize.sm, label: 'Running'),
      AstryxToolStatus.success => const AstryxBadge('done', tone: AstryxTone.success),
      AstryxToolStatus.error => const AstryxBadge('error', tone: AstryxTone.danger),
    };
  }

  Widget _wrench(AstryxTokens t) =>
      SizedBox(width: 14, height: 14, child: CustomPaint(painter: _WrenchPainter(t.color.textMuted)));
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
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
    canvas.drawPath(Path()..moveTo(w * 0.4, h * 0.28)..lineTo(w * 0.62, h * 0.5)..lineTo(w * 0.4, h * 0.72), p);
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}

class _WrenchPainter extends CustomPainter {
  const _WrenchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // A simple terminal/command glyph: a chevron + underscore.
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawPath(Path()..moveTo(w * 0.2, h * 0.3)..lineTo(w * 0.4, h * 0.5)..lineTo(w * 0.2, h * 0.7), p);
    canvas.drawLine(Offset(w * 0.5, h * 0.72), Offset(w * 0.8, h * 0.72), p);
  }

  @override
  bool shouldRepaint(_WrenchPainter old) => old.color != color;
}
