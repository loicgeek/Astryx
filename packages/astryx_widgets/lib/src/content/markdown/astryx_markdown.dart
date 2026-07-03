import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../content/code/astryx_code.dart';
import '../../content/heading/astryx_heading.dart';
import '../blockquote/astryx_blockquote.dart';
import '../../layout/divider/astryx_divider.dart';

/// {@template astryx.markdown}
/// Renders a pragmatic subset of Markdown with Astryx typography and components:
/// headings (`#`–`####`), paragraphs, bold `**`, italic `*`/`_`, inline `` `code` ``,
/// fenced ``` code blocks, links `[t](url)`, blockquotes `>`, unordered/ordered
/// lists, and horizontal rules. Not a full CommonMark parser — meant for docs,
/// chat, and release-note style content.
/// {@endtemplate}
class AstryxMarkdown extends StatefulWidget {
  const AstryxMarkdown(this.data, {super.key, this.onLinkTap});

  final String data;
  final ValueChanged<String>? onLinkTap;

  @override
  State<AstryxMarkdown> createState() => _AstryxMarkdownState();
}

class _AstryxMarkdownState extends State<AstryxMarkdown> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _blocks(context, t),
    );
  }

  List<Widget> _blocks(BuildContext context, AstryxTokens t) {
    final lines = widget.data.split('\n');
    final out = <Widget>[];
    void gap() {
      if (out.isNotEmpty) out.add(SizedBox(height: t.spacing.gapMd));
    }

    final ul = RegExp(r'^\s*[-*]\s+');
    final ol = RegExp(r'^\s*\d+\.\s+');
    var i = 0;
    while (i < lines.length) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        i++;
        continue;
      }
      final trimmed = line.trim();

      // Fenced code block.
      if (trimmed.startsWith('```')) {
        final lang = trimmed.substring(3).trim();
        final buf = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          buf.add(lines[i]);
          i++;
        }
        i++; // closing fence
        gap();
        out.add(AstryxCodeBlock(buf.join('\n'), language: lang.isEmpty ? null : lang));
        continue;
      }

      // Heading.
      final h = RegExp(r'^(#{1,4})\s+(.*)$').firstMatch(trimmed);
      if (h != null) {
        gap();
        out.add(AstryxHeading(h.group(2)!, level: _headingLevel(h.group(1)!.length)));
        i++;
        continue;
      }

      // Horizontal rule.
      if (RegExp(r'^(-{3,}|\*{3,})$').hasMatch(trimmed)) {
        gap();
        out.add(const AstryxDivider());
        i++;
        continue;
      }

      // Blockquote.
      if (trimmed.startsWith('>')) {
        final buf = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('>')) {
          buf.add(lines[i].trim().replaceFirst(RegExp(r'^>\s?'), ''));
          i++;
        }
        gap();
        out.add(AstryxBlockquote(child: _richText(buf.join(' '), t)));
        continue;
      }

      // Lists.
      if (ul.hasMatch(line) || ol.hasMatch(line)) {
        final ordered = ol.hasMatch(line);
        final marker = ordered ? ol : ul;
        final items = <String>[];
        while (i < lines.length && marker.hasMatch(lines[i])) {
          items.add(lines[i].replaceFirst(marker, ''));
          i++;
        }
        gap();
        out.add(_list(items, ordered, t));
        continue;
      }

      // Paragraph (until a blank line or a new block start).
      final buf = <String>[];
      while (i < lines.length &&
          lines[i].trim().isNotEmpty &&
          !_isBlockStart(lines[i], ul, ol)) {
        buf.add(lines[i].trim());
        i++;
      }
      gap();
      out.add(_richText(buf.join(' '), t));
    }
    return out;
  }

  bool _isBlockStart(String line, RegExp ul, RegExp ol) {
    final tr = line.trim();
    return tr.startsWith('#') ||
        tr.startsWith('>') ||
        tr.startsWith('```') ||
        RegExp(r'^(-{3,}|\*{3,})$').hasMatch(tr) ||
        ul.hasMatch(line) ||
        ol.hasMatch(line);
  }

  Widget _list(List<String> items, bool ordered, AstryxTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 0; n < items.length; n++)
          Padding(
            padding: EdgeInsets.only(bottom: t.spacing.gapSm, left: t.spacing.insetSm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    ordered ? '${n + 1}.' : '•',
                    style: t.typography.body.copyWith(color: t.color.textMuted),
                  ),
                ),
                Expanded(child: _richText(items[n].trim(), t)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _richText(String text, AstryxTokens t) {
    final base = t.typography.body.copyWith(color: t.color.textDefault);
    return Text.rich(TextSpan(children: _inline(text, base, t)));
  }

  List<InlineSpan> _inline(String text, TextStyle base, AstryxTokens t) {
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    void flush() {
      if (buffer.isNotEmpty) {
        spans.add(TextSpan(text: buffer.toString(), style: base));
        buffer.clear();
      }
    }

    var i = 0;
    while (i < text.length) {
      // Inline code.
      if (text[i] == '`') {
        final end = text.indexOf('`', i + 1);
        if (end > i) {
          flush();
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AstryxCode(text.substring(i + 1, end)),
          ));
          i = end + 1;
          continue;
        }
      }
      // Bold.
      if (text.startsWith('**', i)) {
        final end = text.indexOf('**', i + 2);
        if (end > i) {
          flush();
          spans.addAll(_inline(text.substring(i + 2, end), base.copyWith(fontWeight: FontWeight.w700), t));
          i = end + 2;
          continue;
        }
      }
      // Italic.
      if (text[i] == '*' || text[i] == '_') {
        final marker = text[i];
        final end = text.indexOf(marker, i + 1);
        if (end > i + 1) {
          flush();
          spans.addAll(_inline(text.substring(i + 1, end), base.copyWith(fontStyle: FontStyle.italic), t));
          i = end + 1;
          continue;
        }
      }
      // Link.
      if (text[i] == '[') {
        final closeB = text.indexOf(']', i);
        if (closeB > i && closeB + 1 < text.length && text[closeB + 1] == '(') {
          final closeP = text.indexOf(')', closeB + 2);
          if (closeP > closeB) {
            flush();
            final label = text.substring(i + 1, closeB);
            final url = text.substring(closeB + 2, closeP);
            TapGestureRecognizer? rec;
            if (widget.onLinkTap != null) {
              rec = TapGestureRecognizer()..onTap = () => widget.onLinkTap!(url);
              _recognizers.add(rec);
            }
            spans.add(TextSpan(
              text: label,
              style: base.copyWith(color: t.color.accentDefault, decoration: TextDecoration.underline),
              recognizer: rec,
            ));
            i = closeP + 1;
            continue;
          }
        }
      }
      buffer.write(text[i]);
      i++;
    }
    flush();
    return spans;
  }

  AstryxHeadingLevel _headingLevel(int hashes) => switch (hashes) {
        1 => AstryxHeadingLevel.display,
        2 => AstryxHeadingLevel.h1,
        3 => AstryxHeadingLevel.h2,
        _ => AstryxHeadingLevel.h3,
      };
}
