import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/widgets.dart';

/// {@template astryx.settingstemplate}
/// A ready-made settings screen: a preferences section with toggles and an
/// "Advanced" collapsible. Toggle state is internal; wire real handlers by
/// copying/adapting.
/// {@endtemplate}
class AstryxSettingsTemplate extends StatefulWidget {
  const AstryxSettingsTemplate({super.key, this.title = 'Settings'});

  final String title;

  @override
  State<AstryxSettingsTemplate> createState() => _AstryxSettingsTemplateState();
}

class _AstryxSettingsTemplateState extends State<AstryxSettingsTemplate> {
  bool _emailNotifications = true;
  bool _compactMode = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: t.spacing.gapLg,
        children: [
          AstryxHeading(widget.title, level: AstryxHeadingLevel.display),
          AstryxSection(
            title: 'Preferences',
            description: 'Manage how the app behaves.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: t.spacing.gapMd,
              children: [
                _toggleRow(t, 'Email notifications', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
                const AstryxDivider(),
                _toggleRow(t, 'Compact mode', _compactMode, (v) => setState(() => _compactMode = v)),
              ],
            ),
          ),
          const AstryxCollapsible(
            title: 'Advanced',
            child: AstryxBanner(
              message: 'These actions are irreversible.',
              tone: AstryxTone.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(AstryxTokens t, String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(child: AstryxText(label)),
        AstryxSwitch(value: value, semanticLabel: label, onChanged: onChanged),
      ],
    );
  }
}
