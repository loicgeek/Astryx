import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AstryxGalleryApp());

class AstryxGalleryApp extends StatefulWidget {
  const AstryxGalleryApp({super.key});

  @override
  State<AstryxGalleryApp> createState() => _AstryxGalleryAppState();
}

class _AstryxGalleryAppState extends State<AstryxGalleryApp> {
  AstryxThemeSpec _spec = AstryxThemeCatalog.neutral;
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    // MaterialApp wraps this in an AnimatedTheme, so swapping theme/mode lerps
    // the token extensions (colors, spacing, shape) for a smooth transition.
    final theme = AstryxThemeCatalog.build(_spec);
    return MaterialApp(
      title: 'Astryx Gallery',
      debugShowCheckedModeBanner: false,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: _mode,
      home: GalleryScreen(
        themeName: _spec.name,
        themeNames: [for (final s in AstryxThemeCatalog.specs) s.name],
        onSelectTheme: (name) => setState(() => _spec = AstryxThemeCatalog.specs.firstWhere((s) => s.name == name)),
        isDark: _mode == ThemeMode.dark,
        onToggleMode: () => setState(() {
          _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    required this.themeName,
    required this.themeNames,
    required this.onSelectTheme,
    required this.isDark,
    required this.onToggleMode,
  });

  final String themeName;
  final List<String> themeNames;
  final ValueChanged<String> onSelectTheme;
  final bool isDark;
  final VoidCallback onToggleMode;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _checked = true;
  bool _switched = false;
  double _volume = 0.4;
  String _view = 'list';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.color.surfaceDefault,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(t.spacing.insetLg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: t.spacing.gapLg,
                children: [
                  _header(t),
                  const AstryxDivider(),
                  _content(t),
                  _actions(t),
                  _inputs(t),
                  _feedback(context, t),
                  _overlays(context, t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(AstryxTokens t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            spacing: t.spacing.gapMd,
            children: [
              const AstryxAvatar(initials: 'Astryx', label: 'Astryx', size: AstryxAvatarSize.lg),
              Flexible(child: AstryxHeading('Astryx • ${widget.themeName}', level: AstryxHeadingLevel.display, maxLines: 1)),
            ],
          ),
        ),
        Row(spacing: t.spacing.gapMd, children: [
          AstryxDropdownMenu<String>(
            trigger: Container(
              padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
              decoration: BoxDecoration(
                color: t.color.surfaceRaised,
                borderRadius: t.shape.radiusControl,
                border: Border.all(color: t.color.borderDefault),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapSm, children: [
                AstryxText('Theme: ${widget.themeName}', variant: AstryxTextVariant.label),
                Icon(Icons.expand_more, size: 16, color: t.color.textMuted),
              ]),
            ),
            onSelected: widget.onSelectTheme,
            items: [for (final name in widget.themeNames) AstryxMenuItem(value: name, label: name)],
          ),
          AstryxButton(
            label: widget.isDark ? 'Light' : 'Dark',
            variant: AstryxButtonVariant.secondary,
            leading: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleMode,
          ),
        ]),
      ],
    );
  }

  Widget _content(AstryxTokens t) {
    return AstryxSection(
      title: 'Content',
      description: 'Typography, avatars and code.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapMd,
        children: [
          const AstryxText('Body text reads from the typography tokens, so every theme restyles it.'),
          Wrap(spacing: t.spacing.gapSm, runSpacing: t.spacing.gapSm, children: const [
            AstryxCode('flutter run'),
            AstryxText('Muted caption', tone: AstryxTextTone.muted),
            AstryxText('Accent link', tone: AstryxTextTone.accent),
          ]),
          const AstryxCodeBlock("AstryxButton(label: 'Save', onPressed: () {});", language: 'dart'),
        ],
      ),
    );
  }

  Widget _actions(AstryxTokens t) {
    return AstryxSection(
      title: 'Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapMd,
        children: [
          Wrap(spacing: t.spacing.gapMd, runSpacing: t.spacing.gapMd, children: [
            AstryxButton(label: 'Primary', onPressed: () {}),
            AstryxButton(label: 'Secondary', variant: AstryxButtonVariant.secondary, onPressed: () {}),
            AstryxButton(label: 'Ghost', variant: AstryxButtonVariant.ghost, onPressed: () {}),
            AstryxButton(label: 'Danger', variant: AstryxButtonVariant.danger, onPressed: () {}),
            const AstryxButton(label: 'Disabled'),
          ]),
          Row(spacing: t.spacing.gapMd, children: [
            AstryxSegmentedControl<String>(
              value: _view,
              onChanged: (v) => setState(() => _view = v),
              segments: const [
                AstryxSegment(value: 'list', label: 'List', icon: Icon(Icons.list)),
                AstryxSegment(value: 'grid', label: 'Grid', icon: Icon(Icons.grid_view)),
                AstryxSegment(value: 'kanban', label: 'Board'),
              ],
            ),
            AstryxDropdownMenu<String>(
              trigger: Container(
                padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
                decoration: BoxDecoration(
                  color: t.color.surfaceRaised,
                  borderRadius: t.shape.radiusControl,
                  border: Border.all(color: t.color.borderDefault),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapSm, children: [
                  AstryxText('Menu', variant: AstryxTextVariant.label),
                  Icon(Icons.expand_more, size: 16, color: t.color.textMuted),
                ]),
              ),
              onSelected: (_) {},
              items: const [
                AstryxMenuItem(value: 'edit', label: 'Edit', leading: Icon(Icons.edit)),
                AstryxMenuItem(value: 'dupe', label: 'Duplicate', leading: Icon(Icons.copy)),
                AstryxMenuItem(value: 'del', label: 'Delete', leading: Icon(Icons.delete)),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _inputs(AstryxTokens t) {
    return AstryxSection(
      title: 'Data input',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapLg,
        children: [
          AstryxField(
            label: 'Search',
            description: 'Type to filter results.',
            child: AstryxTextInput(
              controller: _search,
              hintText: 'Search projects…',
              leading: const Icon(Icons.search),
            ),
          ),
          Row(spacing: t.spacing.gapLg, children: [
            AstryxCheckbox(value: _checked, label: 'Subscribe', onChanged: (v) => setState(() => _checked = v)),
            AstryxSwitch(value: _switched, semanticLabel: 'Notifications', onChanged: (v) => setState(() => _switched = v)),
          ]),
          SizedBox(
            width: 260,
            child: AstryxSlider(
              value: _volume,
              semanticLabel: 'Volume',
              onChanged: (v) => setState(() => _volume = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedback(BuildContext context, AstryxTokens t) {
    return AstryxSection(
      title: 'Feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapMd,
        children: [
          Wrap(spacing: t.spacing.gapSm, runSpacing: t.spacing.gapSm, children: const [
            AstryxBadge('Default'),
            AstryxBadge('Active', tone: AstryxTone.accent, leadingDot: true),
            AstryxBadge('Success', tone: AstryxTone.success),
            AstryxBadge('Failed', tone: AstryxTone.danger),
            AstryxStatusDot(tone: AstryxTone.success, label: 'Online'),
            AstryxSpinner(size: AstryxSpinnerSize.sm),
          ]),
          const AstryxBanner(
            title: 'Trial ending',
            message: 'Your workspace trial ends in 3 days.',
            tone: AstryxTone.warning,
          ),
        ],
      ),
    );
  }

  Widget _overlays(BuildContext context, AstryxTokens t) {
    return AstryxSection(
      title: 'Overlays',
      child: Wrap(spacing: t.spacing.gapMd, runSpacing: t.spacing.gapMd, children: [
        const AstryxTooltip(
          message: 'Helpful hint',
          child: AstryxBadge('Hover me', tone: AstryxTone.accent),
        ),
        AstryxButton(
          label: 'Open dialog',
          variant: AstryxButtonVariant.secondary,
          onPressed: () => showAstryxDialog<void>(
            context: context,
            builder: (ctx) => AstryxDialog(
              title: 'Delete project?',
              content: const AstryxText('This action cannot be undone.'),
              actions: [
                AstryxButton(label: 'Cancel', variant: AstryxButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                AstryxButton(label: 'Delete', variant: AstryxButtonVariant.danger, onPressed: () => Navigator.pop(ctx)),
              ],
            ),
          ),
        ),
        AstryxButton(
          label: 'Show toast',
          variant: AstryxButtonVariant.secondary,
          onPressed: () => showAstryxToast(context, message: 'Saved successfully', tone: AstryxTone.success),
        ),
      ]),
    );
  }
}
