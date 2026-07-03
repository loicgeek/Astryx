import 'model.dart';
import 'registry_props.g.dart';

/// The Astryx component registry — the single source of truth the CLI and MCP
/// server read. Editorial fields (category, description, sample, a11y role,
/// composition hints, slots) are curated in [_curatedRegistry]; **props come
/// from [harvestedProps]** (extracted from the real widget constructors by
/// `tool/gen_registry.dart`), so a widget component's API surface can never
/// drift from the code. Function-based entries (showAstryx*) keep curated props.
final List<AstryxComponentDoc> astryxRegistry = [
  for (final c in _curatedRegistry)
    harvestedProps.containsKey(c.name) ? c.withProps(harvestedProps[c.name]!) : c,
];

/// Editorial metadata + curated fallback props (used when no widget constructor
/// is harvested, e.g. for the show*-function components).
const List<AstryxComponentDoc> _curatedRegistry = [
  // ── Action ──────────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxButton',
    category: 'Action',
    a11yRole: 'button',
    description: 'A branded, accessible action button with variants, sizes and loading state.',
    composesWith: ['Toolbar', 'Dialog', 'AstryxField'],
    slots: ['leading', 'trailing'],
    props: [
      AstryxProp('label', 'String', required: true, doc: 'Text label and default accessible name.'),
      AstryxProp('onPressed', 'VoidCallback?', doc: 'Null renders the button disabled.'),
      AstryxProp('variant', 'AstryxButtonVariant', defaultValue: 'primary'),
      AstryxProp('size', 'AstryxButtonSize', defaultValue: 'md'),
      AstryxProp('loading', 'bool', defaultValue: 'false'),
      AstryxProp('style', 'AstryxButtonStyle?', doc: 'Per-instance paint override.'),
    ],
    sample: "AstryxButton(label: 'Save', onPressed: () {})",
  ),
  AstryxComponentDoc(
    name: 'AstryxSegmentedControl',
    category: 'Action',
    a11yRole: 'radiogroup',
    description: 'Single-select inline control; arrow keys move the selection.',
    props: [
      AstryxProp('segments', 'List<AstryxSegment<T>>', required: true),
      AstryxProp('value', 'T', required: true),
      AstryxProp('onChanged', 'ValueChanged<T>?'),
    ],
    sample: "AstryxSegmentedControl<String>(value: v, onChanged: (x) {}, segments: [...])",
  ),
  AstryxComponentDoc(
    name: 'AstryxDropdownMenu',
    category: 'Action',
    a11yRole: 'menu',
    description: 'Button-triggered menu with keyboard navigation and outside/Esc dismiss.',
    slots: ['trigger'],
    props: [
      AstryxProp('trigger', 'Widget', required: true),
      AstryxProp('items', 'List<AstryxMenuItem<T>>', required: true),
      AstryxProp('onSelected', 'ValueChanged<T>', required: true),
    ],
    sample: "AstryxDropdownMenu<String>(trigger: ..., items: [...], onSelected: (x) {})",
  ),
  AstryxComponentDoc(
    name: 'AstryxToolbar',
    category: 'Action',
    a11yRole: 'toolbar',
    description: 'Raised group of controls with Left/Right roving focus; AstryxToolbar.divider() separates groups.',
    props: [AstryxProp('children', 'List<Widget>', required: true)],
    sample: 'AstryxToolbar(children: [AstryxButton(...), AstryxToolbar.divider(), ...])',
  ),

  // ── Container ───────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxCard',
    category: 'Container',
    description: 'Surface container; becomes clickable/selectable when onTap is set.',
    props: [
      AstryxProp('child', 'Widget', required: true),
      AstryxProp('variant', 'AstryxCardVariant', defaultValue: 'outlined'),
      AstryxProp('onTap', 'VoidCallback?'),
      AstryxProp('selected', 'bool', defaultValue: 'false'),
    ],
    sample: "AstryxCard(child: Text('...'))",
  ),
  AstryxComponentDoc(
    name: 'AstryxCollapsible',
    category: 'Container',
    a11yRole: 'button',
    description: 'Disclosure that expands/collapses its child under a tappable title.',
    props: [
      AstryxProp('title', 'String', required: true),
      AstryxProp('child', 'Widget', required: true),
      AstryxProp('initiallyExpanded', 'bool', defaultValue: 'false'),
    ],
    sample: "AstryxCollapsible(title: 'Details', child: Text('...'))",
  ),
  AstryxComponentDoc(
    name: 'AstryxCarousel',
    category: 'Container',
    description: 'Swipeable pager with prev/next arrows, dot indicator and announced position.',
    props: [
      AstryxProp('items', 'List<Widget>', required: true),
      AstryxProp('height', 'double', defaultValue: '200'),
      AstryxProp('showArrows', 'bool', defaultValue: 'true'),
    ],
    sample: 'AstryxCarousel(items: [...])',
  ),

  // ── Content ─────────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxText',
    category: 'Content',
    description: 'Themed text with typography variants and semantic tones.',
    props: [
      AstryxProp('data', 'String', required: true),
      AstryxProp('variant', 'AstryxTextVariant', defaultValue: 'body'),
      AstryxProp('tone', 'AstryxTextTone', defaultValue: 'normal'),
    ],
    sample: "AstryxText('Hello', tone: AstryxTextTone.muted)",
  ),
  AstryxComponentDoc(
    name: 'AstryxHeading',
    category: 'Content',
    a11yRole: 'header',
    description: 'Section heading with a proper header semantics role.',
    props: [
      AstryxProp('data', 'String', required: true),
      AstryxProp('level', 'AstryxHeadingLevel', defaultValue: 'h1'),
    ],
    sample: "AstryxHeading('Settings', level: AstryxHeadingLevel.h2)",
  ),
  AstryxComponentDoc(
    name: 'AstryxAvatar',
    category: 'Content',
    a11yRole: 'image',
    description: 'User/entity representation: image, else initials, else a fallback glyph.',
    props: [
      AstryxProp('label', 'String', required: true, doc: 'Accessible name.'),
      AstryxProp('image', 'ImageProvider?'),
      AstryxProp('initials', 'String?'),
      AstryxProp('size', 'AstryxAvatarSize', defaultValue: 'md'),
    ],
    sample: "AstryxAvatar(initials: 'Ada Lovelace', label: 'Ada Lovelace')",
  ),
  AstryxComponentDoc(
    name: 'AstryxCode',
    category: 'Content',
    description: 'Inline monospace code span.',
    props: [AstryxProp('code', 'String', required: true)],
    sample: "AstryxCode('flutter run')",
  ),
  AstryxComponentDoc(
    name: 'AstryxCodeBlock',
    category: 'Content',
    description: 'Multi-line, horizontally scrollable code block.',
    props: [
      AstryxProp('code', 'String', required: true),
      AstryxProp('language', 'String?'),
    ],
    sample: "AstryxCodeBlock('final x = 1;', language: 'dart')",
  ),
  AstryxComponentDoc(
    name: 'AstryxBlockquote',
    category: 'Content',
    description: 'A quotation with a left accent bar and an optional citation.',
    props: [
      AstryxProp('text', 'String?'),
      AstryxProp('child', 'Widget?'),
      AstryxProp('citation', 'String?'),
    ],
    sample: "AstryxBlockquote(text: 'Stay hungry.', citation: 'Anon')",
  ),
  AstryxComponentDoc(
    name: 'AstryxMarkdown',
    category: 'Content',
    description: 'Renders a subset of Markdown with Astryx components (headings, bold/italic, code, links, quotes, lists, rules).',
    composesWith: ['AstryxHeading', 'AstryxCode', 'AstryxCodeBlock', 'AstryxBlockquote'],
    props: [
      AstryxProp('data', 'String', required: true),
      AstryxProp('onLinkTap', 'ValueChanged<String>?'),
    ],
    sample: "AstryxMarkdown('# Title\\n\\nHello **world**.')",
  ),

  // ── Data Input ──────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxCheckbox',
    category: 'Data Input',
    a11yRole: 'checkbox',
    description: 'Controlled checkbox with tap/keyboard toggle and a focus ring.',
    composesWith: ['AstryxField'],
    props: [
      AstryxProp('value', 'bool', required: true),
      AstryxProp('onChanged', 'ValueChanged<bool>?'),
      AstryxProp('label', 'String?'),
    ],
    sample: "AstryxCheckbox(value: v, label: 'Accept', onChanged: (x) {})",
  ),
  AstryxComponentDoc(
    name: 'AstryxSwitch',
    category: 'Data Input',
    a11yRole: 'switch',
    description: 'Animated on/off switch with toggle semantics.',
    props: [
      AstryxProp('value', 'bool', required: true),
      AstryxProp('onChanged', 'ValueChanged<bool>?'),
      AstryxProp('semanticLabel', 'String', required: true),
    ],
    sample: "AstryxSwitch(value: v, semanticLabel: 'Wifi', onChanged: (x) {})",
  ),
  AstryxComponentDoc(
    name: 'AstryxTextInput',
    category: 'Data Input',
    a11yRole: 'textField',
    description: 'Single-line field with the Astryx frame, focus ring and error state.',
    composesWith: ['AstryxField'],
    slots: ['leading', 'trailing'],
    props: [
      AstryxProp('controller', 'TextEditingController?'),
      AstryxProp('hintText', 'String?'),
      AstryxProp('onChanged', 'ValueChanged<String>?'),
      AstryxProp('hasError', 'bool', defaultValue: 'false'),
    ],
    sample: "AstryxTextInput(hintText: 'Name', onChanged: (x) {})",
  ),
  AstryxComponentDoc(
    name: 'AstryxField',
    category: 'Data Input',
    description: 'Form field scaffold: label (+required), description, input and error.',
    composesWith: ['AstryxTextInput', 'AstryxCheckbox', 'AstryxSlider'],
    slots: ['child'],
    props: [
      AstryxProp('label', 'String', required: true),
      AstryxProp('child', 'Widget', required: true),
      AstryxProp('error', 'String?'),
      AstryxProp('required', 'bool', defaultValue: 'false'),
    ],
    sample: "AstryxField(label: 'Email', child: AstryxTextInput())",
  ),
  AstryxComponentDoc(
    name: 'AstryxSlider',
    category: 'Data Input',
    a11yRole: 'slider',
    description: 'Custom slider with drag + arrow/Home/End keys and slider semantics.',
    props: [
      AstryxProp('value', 'double', required: true),
      AstryxProp('onChanged', 'ValueChanged<double>?'),
      AstryxProp('divisions', 'int?'),
      AstryxProp('semanticLabel', 'String', required: true),
    ],
    sample: "AstryxSlider(value: v, semanticLabel: 'Volume', onChanged: (x) {})",
  ),

  AstryxComponentDoc(
    name: 'AstryxCalendar',
    category: 'Data Input',
    a11yRole: 'grid',
    description: 'Month calendar; one keyboard stop (arrows move day, Enter selects, PageUp/Down month). DST-safe.',
    props: [
      AstryxProp('value', 'DateTime?'),
      AstryxProp('onChanged', 'ValueChanged<DateTime>?'),
      AstryxProp('firstDate', 'DateTime?'),
      AstryxProp('lastDate', 'DateTime?'),
    ],
    sample: 'AstryxCalendar(value: d, onChanged: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxDateInput',
    category: 'Data Input',
    description: 'Field that opens an AstryxCalendar in a popover to pick a date.',
    composesWith: ['AstryxCalendar', 'AstryxField'],
    props: [
      AstryxProp('value', 'DateTime?'),
      AstryxProp('onChanged', 'ValueChanged<DateTime>?'),
    ],
    sample: 'AstryxDateInput(value: d, onChanged: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxTimeInput',
    category: 'Data Input',
    description: 'Field that opens a selectable time list (AstryxTimeOfDay) in a popover.',
    props: [
      AstryxProp('value', 'AstryxTimeOfDay?'),
      AstryxProp('onChanged', 'ValueChanged<AstryxTimeOfDay>?'),
      AstryxProp('intervalMinutes', 'int', defaultValue: '30'),
    ],
    sample: 'AstryxTimeInput(value: t, onChanged: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxTypeahead',
    category: 'Data Input',
    description: 'Text field with a suggestions overlay; ArrowUp/Down highlight, Enter/tap select.',
    composesWith: ['AstryxTextInput', 'AstryxField'],
    props: [
      AstryxProp('suggestions', 'List<T> Function(String)', required: true),
      AstryxProp('itemLabel', 'String Function(T)', required: true),
      AstryxProp('onSelected', 'ValueChanged<T>', required: true),
    ],
    sample: 'AstryxTypeahead<String>(suggestions: f, itemLabel: (s) => s, onSelected: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxMultiSelector',
    category: 'Data Input',
    description: 'Selects multiple options from a checklist popover; the trigger summarizes the selection.',
    composesWith: ['AstryxCheckbox'],
    props: [
      AstryxProp('options', 'List<AstryxSelectOption<T>>', required: true),
      AstryxProp('selected', 'Set<T>', required: true),
      AstryxProp('onChanged', 'ValueChanged<Set<T>>', required: true),
    ],
    sample: 'AstryxMultiSelector<String>(options: [...], selected: s, onChanged: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxTokenizer',
    category: 'Data Input',
    description: 'Turns typed entries into removable chips (comma/Enter add, Backspace/✕ remove).',
    props: [
      AstryxProp('value', 'List<String>', required: true),
      AstryxProp('onChanged', 'ValueChanged<List<String>>', required: true),
    ],
    sample: 'AstryxTokenizer(value: v, onChanged: (x) {})',
  ),

  // ── Feedback ────────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxBadge',
    category: 'Feedback',
    description: 'Compact status/count pill with a semantic tone.',
    props: [
      AstryxProp('label', 'String', required: true),
      AstryxProp('tone', 'AstryxTone', defaultValue: 'neutral'),
    ],
    sample: "AstryxBadge('New', tone: AstryxTone.accent)",
  ),
  AstryxComponentDoc(
    name: 'AstryxStatusDot',
    category: 'Feedback',
    description: 'A labeled status dot (never color-alone).',
    props: [
      AstryxProp('label', 'String', required: true),
      AstryxProp('tone', 'AstryxTone', defaultValue: 'neutral'),
    ],
    sample: "AstryxStatusDot(tone: AstryxTone.success, label: 'Online')",
  ),
  AstryxComponentDoc(
    name: 'AstryxSpinner',
    category: 'Feedback',
    description: 'Indeterminate loading ring; honors reduced motion, announces busy.',
    props: [
      AstryxProp('size', 'AstryxSpinnerSize', defaultValue: 'md'),
      AstryxProp('label', 'String', defaultValue: 'Loading'),
    ],
    sample: 'AstryxSpinner()',
  ),
  AstryxComponentDoc(
    name: 'AstryxBanner',
    category: 'Feedback',
    description: 'Tonal inline message with accent bar, icon/actions slots and dismiss.',
    slots: ['icon', 'actions'],
    props: [
      AstryxProp('message', 'String', required: true),
      AstryxProp('title', 'String?'),
      AstryxProp('tone', 'AstryxTone', defaultValue: 'accent'),
      AstryxProp('onDismiss', 'VoidCallback?'),
    ],
    sample: "AstryxBanner(message: 'Saved', tone: AstryxTone.success)",
  ),
  AstryxComponentDoc(
    name: 'AstryxProgressBar',
    category: 'Feedback',
    a11yRole: 'progressbar',
    description: 'Linear progress; determinate (announces %) or indeterminate. Reduced-motion aware.',
    props: [
      AstryxProp('value', 'double?', doc: 'Null = indeterminate.'),
      AstryxProp('semanticLabel', 'String', defaultValue: 'Progress'),
    ],
    sample: 'AstryxProgressBar(value: 0.4)',
  ),
  AstryxComponentDoc(
    name: 'AstryxSkeleton',
    category: 'Feedback',
    description: 'Shimmer placeholder for loading content (static under reduced motion); AstryxSkeleton.lines(n).',
    props: [
      AstryxProp('width', 'double?'),
      AstryxProp('height', 'double', defaultValue: '16'),
    ],
    sample: 'AstryxSkeleton(width: 120)',
  ),

  // ── Table & List ────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxList',
    category: 'Table & List',
    description: 'Vertical rows with optional dividers; interactive rows get button/selected semantics.',
    props: [
      AstryxProp('items', 'List<AstryxListItem>', required: true),
      AstryxProp('dividers', 'bool', defaultValue: 'true'),
    ],
    sample: 'AstryxList(items: [AstryxListItem(title: ...)])',
  ),
  AstryxComponentDoc(
    name: 'AstryxTable',
    category: 'Table & List',
    a11yRole: 'table',
    description: 'Data table: styled header, flex-aligned columns, hover/selectable rows, sortable headers.',
    props: [
      AstryxProp('columns', 'List<AstryxColumn>', required: true),
      AstryxProp('rows', 'List<AstryxRow>', required: true),
      AstryxProp('sortColumnIndex', 'int?'),
      AstryxProp('onSort', 'ValueChanged<int>?'),
    ],
    sample: 'AstryxTable(columns: [...], rows: [...])',
  ),
  AstryxComponentDoc(
    name: 'AstryxTreeList',
    category: 'Table & List',
    a11yRole: 'tree',
    description: 'Hierarchical expandable list; branches toggle, leaves select, tree-item semantics.',
    props: [
      AstryxProp('roots', 'List<AstryxTreeNode>', required: true),
      AstryxProp('selected', 'Object?'),
      AstryxProp('onSelect', 'ValueChanged<Object?>?'),
    ],
    sample: 'AstryxTreeList(roots: [...], onSelect: (v) {})',
  ),

  // ── Layout ──────────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxDivider',
    category: 'Layout',
    description: 'Hairline separator, optional centered label.',
    props: [
      AstryxProp('axis', 'Axis', defaultValue: 'horizontal'),
      AstryxProp('label', 'String?'),
    ],
    sample: 'AstryxDivider()',
  ),
  AstryxComponentDoc(
    name: 'AstryxSection',
    category: 'Layout',
    description: 'Titled content block (header role) with description + trailing slot.',
    slots: ['trailing', 'child'],
    props: [
      AstryxProp('title', 'String', required: true),
      AstryxProp('child', 'Widget', required: true),
      AstryxProp('description', 'String?'),
    ],
    sample: "AstryxSection(title: 'Members', child: ...)",
  ),
  AstryxComponentDoc(
    name: 'AstryxGrid',
    category: 'Layout',
    description: 'Container-query responsive grid with token-gapped equal tracks.',
    props: [
      AstryxProp('children', 'List<Widget>', required: true),
      AstryxProp('columns', 'ResponsiveValue<int>'),
      AstryxProp('gap', 'double?'),
    ],
    sample: 'AstryxGrid(children: [...])',
  ),
  AstryxComponentDoc(
    name: 'AstryxResizeHandle',
    category: 'Layout',
    description: 'Draggable divider emitting signed deltas; arrow-key nudge, resize cursor.',
    props: [
      AstryxProp('onResize', 'ValueChanged<double>', required: true),
      AstryxProp('axis', 'Axis', defaultValue: 'vertical'),
      AstryxProp('semanticLabel', 'String', required: true),
    ],
    sample: "AstryxResizeHandle(onResize: (d) {}, semanticLabel: 'Resize')",
  ),
  AstryxComponentDoc(
    name: 'AstryxAppShell',
    category: 'Layout',
    description: 'Responsive scaffold: docked rail when wide, slide-in drawer when compact.',
    composesWith: ['AstryxTopNav', 'AstryxSideNav'],
    slots: ['topNav', 'sideNav', 'content'],
    props: [
      AstryxProp('sideNav', 'Widget', required: true),
      AstryxProp('content', 'Widget', required: true),
      AstryxProp('topNav', 'Widget?'),
      AstryxProp('breakpoint', 'double', defaultValue: '1024'),
    ],
    sample: 'AstryxAppShell(sideNav: ..., content: ...)',
  ),

  // ── Navigation ──────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxBreadcrumbs',
    category: 'Navigation',
    description: 'Link trail that wraps; the last crumb is the current page.',
    props: [AstryxProp('items', 'List<AstryxCrumb>', required: true)],
    sample: "AstryxBreadcrumbs(items: [AstryxCrumb(label: 'Home', onTap: () {})])",
  ),
  AstryxComponentDoc(
    name: 'AstryxPagination',
    category: 'Navigation',
    description: 'Prev/next + windowed page numbers with ellipsis.',
    props: [
      AstryxProp('page', 'int', required: true),
      AstryxProp('pageCount', 'int', required: true),
      AstryxProp('onChanged', 'ValueChanged<int>?'),
    ],
    sample: 'AstryxPagination(page: 1, pageCount: 20, onChanged: (p) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxTabList',
    category: 'Navigation',
    a11yRole: 'tablist',
    description: 'Animated-underline tablist; arrow keys move the active tab.',
    props: [
      AstryxProp('tabs', 'List<AstryxTab<T>>', required: true),
      AstryxProp('value', 'T', required: true),
      AstryxProp('onChanged', 'ValueChanged<T>?'),
    ],
    sample: 'AstryxTabList<String>(tabs: [...], value: v, onChanged: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxSideNav',
    category: 'Navigation',
    description: 'Vertical nav rail with grouped sections; selected highlight; collapsible.',
    composesWith: ['AstryxAppShell'],
    slots: ['header', 'footer'],
    props: [
      AstryxProp('sections', 'List<AstryxNavSection<T>>', required: true),
      AstryxProp('selected', 'T?'),
      AstryxProp('onSelect', 'ValueChanged<T>?'),
      AstryxProp('collapsed', 'bool', defaultValue: 'false'),
    ],
    sample: 'AstryxSideNav<String>(sections: [...], selected: v, onSelect: (x) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxTopNav',
    category: 'Navigation',
    description: 'Top bar with brand, inline items and actions; hamburger when compact.',
    composesWith: ['AstryxAppShell', 'AstryxMegaMenu'],
    slots: ['leading', 'items', 'actions'],
    props: [
      AstryxProp('leading', 'Widget?'),
      AstryxProp('items', 'List<Widget>', defaultValue: 'const []'),
      AstryxProp('actions', 'List<Widget>', defaultValue: 'const []'),
    ],
    sample: 'AstryxTopNav(leading: ..., items: [...], actions: [...])',
  ),
  AstryxComponentDoc(
    name: 'AstryxMegaMenu',
    category: 'Navigation',
    description: 'Multi-column overlay panel; opens on hover (pointer) or tap.',
    props: [
      AstryxProp('label', 'String', required: true),
      AstryxProp('columns', 'List<AstryxMegaColumn>', required: true),
    ],
    sample: "AstryxMegaMenu(label: 'Products', columns: [...])",
  ),

  // ── Chat (AI-oriented) ──────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxChatMessage',
    category: 'Chat',
    description: 'A chat bubble: user (accent, plain text) or assistant (avatar + Markdown), with optional tool calls + metadata.',
    composesWith: ['AstryxMarkdown', 'AstryxAvatar', 'AstryxChatToolCalls', 'AstryxChatMessageMetadata'],
    slots: ['avatar', 'toolCalls', 'metadata'],
    props: [
      AstryxProp('role', 'AstryxChatRole', required: true, doc: 'user | assistant'),
      AstryxProp('content', 'String', required: true),
      AstryxProp('avatar', 'Widget?'),
    ],
    sample: "AstryxChatMessage(role: AstryxChatRole.assistant, content: '**Hi**')",
  ),
  AstryxComponentDoc(
    name: 'AstryxChatSystemMessage',
    category: 'Chat',
    description: 'A centered, muted conversation notice between hairlines.',
    props: [AstryxProp('text', 'String', required: true)],
    sample: "AstryxChatSystemMessage('New conversation')",
  ),
  AstryxComponentDoc(
    name: 'AstryxChatMessageMetadata',
    category: 'Chat',
    description: 'Timestamp/model line under a message with trailing action slots.',
    slots: ['actions'],
    props: [
      AstryxProp('timestamp', 'String?'),
      AstryxProp('model', 'String?'),
      AstryxProp('actions', 'List<Widget>', defaultValue: 'const []'),
    ],
    sample: "AstryxChatMessageMetadata(timestamp: '12:04', model: 'opus-4.8')",
  ),
  AstryxComponentDoc(
    name: 'AstryxChatToolCalls',
    category: 'Chat',
    description: 'Collapsible tool-invocation panels with running/success/error status and arguments/result code blocks — for agent chat UIs.',
    composesWith: ['AstryxBadge', 'AstryxSpinner', 'AstryxCodeBlock'],
    props: [AstryxProp('calls', 'List<AstryxToolCall>', required: true)],
    sample: 'AstryxChatToolCalls(calls: [AstryxToolCall(name: ..., status: ...)])',
  ),
  AstryxComponentDoc(
    name: 'AstryxChatComposer',
    category: 'Chat',
    description: 'Multiline message input; Enter sends, Shift+Enter inserts a newline; send disabled while empty.',
    composesWith: ['AstryxChatLayout'],
    slots: ['leadingActions'],
    props: [
      AstryxProp('onSend', 'ValueChanged<String>', required: true),
      AstryxProp('enabled', 'bool', defaultValue: 'true'),
      AstryxProp('hintText', 'String', defaultValue: "'Send a message…'"),
    ],
    sample: 'AstryxChatComposer(onSend: (text) {})',
  ),
  AstryxComponentDoc(
    name: 'AstryxChatLayout',
    category: 'Chat',
    description: 'Scrollable messages + pinned composer with auto-scroll and an optional streaming placeholder.',
    composesWith: ['AstryxChatMessage', 'AstryxChatComposer'],
    slots: ['composer', 'streaming'],
    props: [
      AstryxProp('messages', 'List<Widget>', required: true),
      AstryxProp('composer', 'Widget', required: true),
      AstryxProp('streaming', 'Widget?'),
    ],
    sample: 'AstryxChatLayout(messages: [...], composer: AstryxChatComposer(...))',
  ),

  // ── Overlay ─────────────────────────────────────────────────────────────
  AstryxComponentDoc(
    name: 'AstryxTooltip',
    category: 'Overlay',
    description: 'Contextual label on hover (desktop) or long-press (touch).',
    props: [
      AstryxProp('message', 'String', required: true),
      AstryxProp('child', 'Widget', required: true),
    ],
    sample: "AstryxTooltip(message: 'Info', child: ...)",
  ),
  AstryxComponentDoc(
    name: 'AstryxPopover',
    category: 'Overlay',
    description: 'Anchored floating panel with controller; outside-tap + Esc dismiss.',
    slots: ['anchor'],
    props: [
      AstryxProp('anchor', 'Widget', required: true),
      AstryxProp('builder', 'WidgetBuilder', required: true),
      AstryxProp('controller', 'AstryxPopoverController?'),
    ],
    sample: 'AstryxPopover(anchor: ..., builder: (ctx) => ...)',
  ),
  AstryxComponentDoc(
    name: 'AstryxDialog',
    category: 'Overlay',
    a11yRole: 'dialog',
    description: 'Modal surface presented via showAstryxDialog; focus trap + Esc.',
    composesWith: ['AstryxButton'],
    slots: ['content', 'actions'],
    props: [
      AstryxProp('title', 'String?'),
      AstryxProp('content', 'Widget', required: true),
      AstryxProp('actions', 'List<Widget>', defaultValue: 'const []'),
    ],
    sample: "showAstryxDialog(context: context, builder: (_) => AstryxDialog(content: ...))",
  ),
  AstryxComponentDoc(
    name: 'AstryxToast',
    category: 'Overlay',
    description: 'Transient stacked live-region messages via showAstryxToast.',
    props: [
      AstryxProp('message', 'String', required: true),
      AstryxProp('tone', 'AstryxTone', defaultValue: 'neutral'),
      AstryxProp('duration', 'Duration', defaultValue: '3s'),
    ],
    sample: "showAstryxToast(context, message: 'Saved')",
  ),
  AstryxComponentDoc(
    name: 'AstryxCommandPalette',
    category: 'Overlay',
    description: 'Cmd/Ctrl-K modal: search + filtered commands, arrow nav, Enter runs, Esc dismisses.',
    composesWith: ['AstryxTextInput'],
    props: [
      AstryxProp('commands', 'List<AstryxCommand>', required: true, doc: 'Via showAstryxCommandPalette / AstryxCommandPaletteShortcut.'),
    ],
    sample: 'showAstryxCommandPalette(context, commands: [...])',
  ),
  AstryxComponentDoc(
    name: 'AstryxHoverCard',
    category: 'Overlay',
    description: 'Rich hover content with an open delay that stays while the pointer is over the card.',
    slots: ['card'],
    props: [
      AstryxProp('child', 'Widget', required: true),
      AstryxProp('card', 'Widget', required: true),
      AstryxProp('openDelay', 'Duration', defaultValue: '350ms'),
    ],
    sample: 'AstryxHoverCard(child: ..., card: ...)',
  ),
  AstryxComponentDoc(
    name: 'AstryxLightbox',
    category: 'Overlay',
    description: 'Full-screen zoomable (InteractiveViewer) pager with counter, close and Esc dismiss.',
    props: [
      AstryxProp('items', 'List<Widget>', required: true, doc: 'Via showAstryxLightbox.'),
      AstryxProp('initialIndex', 'int', defaultValue: '0'),
    ],
    sample: 'showAstryxLightbox(context, items: [...])',
  ),
];
