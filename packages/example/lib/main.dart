import 'package:astryx_foundations/astryx_foundations.dart';
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
        onToggleMode: () => setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light),
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
  String _nav = 'components';
  String _tab = 'overview';
  int _page = 3;
  bool _checked = true;
  bool _switched = false;
  double _volume = 0.4;
  String _view = 'list';
  DateTime? _date;
  List<String> _tags = ['design', 'flutter'];
  final _search = TextEditingController();

  static const _fruits = ['Apple', 'Apricot', 'Avocado', 'Banana', 'Blueberry', 'Cherry'];

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
      body: AstryxAppShell(
        breakpoint: 900,
        sideNavWidth: 240,
        topNav: _topNav(t),
        sideNav: _sideNav(t),
        content: _content(t),
      ),
    );
  }

  Widget _topNav(AstryxTokens t) {
    return AstryxTopNav(
      leading: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapSm, children: [
        const AstryxAvatar(initials: 'Astryx', label: 'Astryx', size: AstryxAvatarSize.sm),
        AstryxText('Astryx', variant: AstryxTextVariant.label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
      items: [
        AstryxMegaMenu(
          label: 'Components',
          columns: const [
            AstryxMegaColumn(title: 'Input', links: [
              AstryxMegaLink(label: 'Text Input', description: 'Single-line field'),
              AstryxMegaLink(label: 'Slider', description: 'Range selection'),
            ]),
            AstryxMegaColumn(title: 'Overlay', links: [
              AstryxMegaLink(label: 'Dialog', description: 'Modal surface'),
              AstryxMegaLink(label: 'Toast', description: 'Transient message'),
            ]),
          ],
        ),
      ],
      actions: [
        AstryxDropdownMenu<String>(
          trigger: _pill(t, 'Theme: ${widget.themeName}'),
          onSelected: widget.onSelectTheme,
          items: [for (final name in widget.themeNames) AstryxMenuItem(value: name, label: name)],
        ),
        AstryxButton(
          label: widget.isDark ? 'Light' : 'Dark',
          variant: AstryxButtonVariant.secondary,
          size: AstryxButtonSize.sm,
          onPressed: widget.onToggleMode,
        ),
      ],
    );
  }

  Widget _pill(AstryxTokens t, String label) => Container(
        padding: EdgeInsets.symmetric(horizontal: t.spacing.insetMd, vertical: t.spacing.insetSm),
        decoration: BoxDecoration(
          color: t.color.surfaceRaised,
          borderRadius: t.shape.radiusControl,
          border: Border.all(color: t.color.borderDefault),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, spacing: t.spacing.gapSm, children: [
          AstryxText(label, variant: AstryxTextVariant.label),
          Icon(Icons.expand_more, size: 16, color: t.color.textMuted),
        ]),
      );

  Widget _sideNav(AstryxTokens t) {
    return AstryxSideNav<String>(
      selected: _nav,
      onSelect: (v) => setState(() => _nav = v),
      sections: const [
        AstryxNavSection(title: 'Explore', items: [
          AstryxNavItem(value: 'components', label: 'Components', icon: Icon(Icons.widgets)),
          AstryxNavItem(value: 'themes', label: 'Themes', icon: Icon(Icons.palette)),
          AstryxNavItem(value: 'tokens', label: 'Tokens', icon: Icon(Icons.style)),
        ]),
        AstryxNavSection(title: 'Account', items: [
          AstryxNavItem(value: 'settings', label: 'Settings', icon: Icon(Icons.settings)),
        ]),
      ],
    );
  }

  String get _navLabel => switch (_nav) {
        'themes' => 'Themes',
        'tokens' => 'Tokens',
        'settings' => 'Settings',
        _ => 'Components',
      };

  Widget _content(AstryxTokens t) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(t.spacing.insetLg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: t.spacing.gapLg,
            children: [
              AstryxBreadcrumbs(items: [
                AstryxCrumb(label: 'Astryx', onTap: () {}),
                AstryxCrumb(label: 'Gallery', onTap: () {}),
                AstryxCrumb(label: _navLabel),
              ]),
              AstryxHeading(_navLabel, level: AstryxHeadingLevel.display),
              AstryxText('Section “$_navLabel” · theme “${widget.themeName}”.', tone: AstryxTextTone.muted),
              _navigation(t),
              _dataDisplay(t),
              _actions(t),
              _inputs(t),
              _feedback(context, t),
              _overlays(context, t),
              _chat(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigation(AstryxTokens t) {
    return AstryxSection(
      title: 'Navigation',
      description: 'Tabs, cards, collapsible and pagination.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapLg,
        children: [
          AstryxTabList<String>(
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
            tabs: const [
              AstryxTab(value: 'overview', label: 'Overview'),
              AstryxTab(value: 'activity', label: 'Activity'),
              AstryxTab(value: 'settings', label: 'Settings'),
            ],
          ),
          AstryxCard(child: AstryxText('Selected tab: $_tab')),
          AstryxGrid(
            columns: const ResponsiveValue<int>(xs: 1, sm: 2, lg: 3),
            children: [
              for (final plan in ['Starter', 'Pro', 'Enterprise'])
                AstryxCard(
                  variant: AstryxCardVariant.raised,
                  selected: plan == 'Pro',
                  onTap: () {},
                  semanticLabel: '$plan plan',
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: t.spacing.gapSm, children: [
                    AstryxHeading(plan, level: AstryxHeadingLevel.h3),
                    AstryxText('Everything you need.', tone: AstryxTextTone.muted),
                  ]),
                ),
            ],
          ),
          const AstryxCollapsible(
            title: 'Advanced options',
            child: AstryxText('Hidden configuration lives here.'),
          ),
          AstryxPagination(
            page: _page,
            pageCount: 12,
            onChanged: (p) => setState(() => _page = p),
          ),
        ],
      ),
    );
  }

  Widget _dataDisplay(AstryxTokens t) {
    return AstryxSection(
      title: 'Data & content',
      description: 'Tables, lists, progress and markdown.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: t.spacing.gapLg,
        children: [
          AstryxTable(
            sortColumnIndex: 1,
            sortDirection: AstryxSortDirection.descending,
            onSort: (_) {},
            columns: const [
              AstryxColumn(label: 'File', sortable: true, flex: 2),
              AstryxColumn(label: 'Size', numeric: true, sortable: true),
              AstryxColumn(label: 'Owner'),
            ],
            rows: [
              AstryxRow(cells: const [Text('report.pdf'), Text('2.4 MB'), Text('Ada')], onTap: () {}),
              AstryxRow(cells: const [Text('notes.txt'), Text('12 KB'), Text('Grace')], onTap: () {}),
              AstryxRow(cells: const [Text('logo.svg'), Text('3 KB'), Text('Alan')], onTap: () {}),
            ],
          ),
          const AstryxProgressBar(value: 0.62, semanticLabel: 'Storage used'),
          AstryxCarousel(
            height: 120,
            items: [
              for (final (i, tone) in [
                (1, t.color.accentDefault),
                (2, t.color.success),
                (3, t.color.warning),
              ])
                Container(
                  color: Color.alphaBlend(tone.withValues(alpha: 0.15), t.color.surfaceSunken),
                  alignment: Alignment.center,
                  child: AstryxHeading('Slide $i', level: AstryxHeadingLevel.h2),
                ),
            ],
          ),
          const AstryxMarkdown('Supports **bold**, `code`, and [links](https://astryx.dev). '
              '\n\n> Rendered with Astryx components.'),
        ],
      ),
    );
  }

  Widget _chat(AstryxTokens t) {
    return AstryxSection(
      title: 'Chat',
      description: 'Message bubbles, tool calls, metadata and a composer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AstryxChatSystemMessage('Today'),
          const AstryxChatMessage(role: AstryxChatRole.user, content: 'Show me the Q2 sales.'),
          AstryxChatMessage(
            role: AstryxChatRole.assistant,
            avatar: const AstryxAvatar(initials: 'AI', label: 'Assistant', size: AstryxAvatarSize.sm),
            content: 'Here are the **Q2** results:\n\n'
                '- Revenue up 12%\n'
                '- Churn down\n\n'
                'Pulled with `query_sales`.',
            toolCalls: const AstryxChatToolCalls(calls: [
              AstryxToolCall(
                name: 'query_sales',
                status: AstryxToolStatus.success,
                arguments: '{ "quarter": "Q2" }',
                result: '42 rows',
              ),
            ]),
            metadata: const AstryxChatMessageMetadata(timestamp: '12:04', model: 'opus-4.8'),
          ),
          SizedBox(height: t.spacing.gapMd),
          AstryxChatComposer(onSend: (_) {}),
        ],
      ),
    );
  }

  Widget _actions(AstryxTokens t) {
    return AstryxSection(
      title: 'Actions',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: t.spacing.gapMd, children: [
        Wrap(spacing: t.spacing.gapMd, runSpacing: t.spacing.gapMd, children: [
          AstryxButton(label: 'Primary', onPressed: () {}),
          AstryxButton(label: 'Secondary', variant: AstryxButtonVariant.secondary, onPressed: () {}),
          AstryxButton(label: 'Ghost', variant: AstryxButtonVariant.ghost, onPressed: () {}),
          AstryxButton(label: 'Danger', variant: AstryxButtonVariant.danger, onPressed: () {}),
        ]),
        AstryxSegmentedControl<String>(
          value: _view,
          onChanged: (v) => setState(() => _view = v),
          segments: const [
            AstryxSegment(value: 'list', label: 'List', icon: Icon(Icons.list)),
            AstryxSegment(value: 'grid', label: 'Grid', icon: Icon(Icons.grid_view)),
          ],
        ),
      ]),
    );
  }

  Widget _inputs(AstryxTokens t) {
    return AstryxSection(
      title: 'Data input',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: t.spacing.gapLg, children: [
        AstryxField(
          label: 'Search',
          description: 'Type to filter results.',
          child: AstryxTextInput(controller: _search, hintText: 'Search…', leading: const Icon(Icons.search)),
        ),
        Row(spacing: t.spacing.gapLg, children: [
          AstryxCheckbox(value: _checked, label: 'Subscribe', onChanged: (v) => setState(() => _checked = v)),
          AstryxSwitch(value: _switched, semanticLabel: 'Notifications', onChanged: (v) => setState(() => _switched = v)),
        ]),
        SizedBox(width: 260, child: AstryxSlider(value: _volume, semanticLabel: 'Volume', onChanged: (v) => setState(() => _volume = v))),
        Wrap(spacing: t.spacing.gapLg, runSpacing: t.spacing.gapMd, crossAxisAlignment: WrapCrossAlignment.center, children: [
          AstryxDateInput(value: _date, onChanged: (d) => setState(() => _date = d)),
          SizedBox(
            width: 220,
            child: AstryxTypeahead<String>(
              hintText: 'Search fruit…',
              suggestions: (q) => _fruits.where((f) => f.toLowerCase().contains(q.toLowerCase())).toList(),
              itemLabel: (s) => s,
              onSelected: (_) {},
            ),
          ),
        ]),
        SizedBox(width: 360, child: AstryxTokenizer(value: _tags, onChanged: (v) => setState(() => _tags = v))),
      ]),
    );
  }

  Widget _feedback(BuildContext context, AstryxTokens t) {
    return AstryxSection(
      title: 'Feedback',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: t.spacing.gapMd, children: [
        Wrap(spacing: t.spacing.gapSm, runSpacing: t.spacing.gapSm, children: const [
          AstryxBadge('Default'),
          AstryxBadge('Active', tone: AstryxTone.accent, leadingDot: true),
          AstryxBadge('Success', tone: AstryxTone.success),
          AstryxStatusDot(tone: AstryxTone.success, label: 'Online'),
          AstryxSpinner(size: AstryxSpinnerSize.sm),
        ]),
        const AstryxBanner(title: 'Trial ending', message: 'Your workspace trial ends in 3 days.', tone: AstryxTone.warning),
      ]),
    );
  }

  Widget _overlays(BuildContext context, AstryxTokens t) {
    return AstryxSection(
      title: 'Overlays',
      child: Wrap(spacing: t.spacing.gapMd, runSpacing: t.spacing.gapMd, children: [
        const AstryxTooltip(message: 'Helpful hint', child: AstryxBadge('Hover me', tone: AstryxTone.accent)),
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
        AstryxButton(
          label: 'Command palette',
          variant: AstryxButtonVariant.secondary,
          onPressed: () => showAstryxCommandPalette(context, commands: [
            AstryxCommand(label: 'Toggle theme', hint: '⌘T', onRun: widget.onToggleMode),
            AstryxCommand(label: 'New project', onRun: () {}),
            AstryxCommand(label: 'Open settings', onRun: () {}),
          ]),
        ),
        AstryxHoverCard(
          card: const SizedBox(
            width: 200,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AstryxHeading('Astryx', level: AstryxHeadingLevel.h3),
              AstryxText('Hover cards hold rich, interactive content.', tone: AstryxTextTone.muted),
            ]),
          ),
          child: const AstryxBadge('Hover card', tone: AstryxTone.accent),
        ),
      ]),
    );
  }
}
