# Astryx for Flutter

A Flutter/Dart port of [Meta's Astryx](https://astryx.atmeta.com/) design system
(React + StyleX → Flutter). Unified branded look across mobile, web, and desktop;
token-driven theming; source-available components (swizzle-ready); with an
AI-parity CLI + MCP server planned (see the plan).

> **Status: all functional milestones (Jalons 0–7) done.** ~57 components across
> 10 categories + the full ~10-theme catalog + a responsive App Shell + the
> AI-oriented chat set, plus the AI-parity tooling (CLI, manifest, MCP server).
> Everything analyzes clean and passes tests (110 Flutter + 24 Dart across the
> workspace). The library depends only on Flutter's `widgets` + theme layer — no
> Material *widgets*.
>
> Advanced tooling done: **registry prop-harvester** (real constructor props via
> the analyzer — the registry can't drift), **real swizzle** (`astryx swizzle
> <name> --apply` copies source + rewrites imports), **`astryx_templates`**
> (drop-in dashboard/form/settings screens), **`astryx_lints`** (custom_lint
> rules: Material-free imports, tokens over raw colors). Optional remaining:
> publishing to a registry.

Jalon 4 (rich input & overlays): **Calendar** (DST-safe keyboard grid),
**Date/Time Input**, **Typeahead**, **Multi Selector**, **Tokenizer**, **Command
Palette** (⌘K), **Hover Card**, **Lightbox**.

Jalon 5 (data display): **List**, **Table** (sortable), **Tree List**,
**Carousel**, **Progress Bar**, **Skeleton**, **Blockquote**, **Markdown**,
**Toolbar**.

Jalon 6 (AI chat): **Chat Message** (Markdown + tool calls), **System Message**,
**Message Metadata**, **Tool Calls** (agent tool panels), **Composer**
(Enter-to-send), **Layout** (auto-scroll + streaming).

## AI-parity tooling (the Astryx signature)

Humans and AI agents work from **one contract**. A shared registry
(`astryx_core`) is the single source of truth for both surfaces:

- **CLI** (`astryx` / alias `xds`): `list`, `component <name> [--json]`,
  `template <name>`, `theme [name]`, `swizzle <name>`, `manifest`.
  ```bash
  dart run astryx_cli:astryx component button --json
  dart run astryx_cli:astryx manifest
  ```
- **`manifest`**: the machine-readable "OpenAPI-for-the-CLI" — every operation
  plus the full catalog (components, templates, themes).
- **MCP server** (`astryx_mcp`): a stdio JSON-RPC server exposing the same
  operations as tools (`astryx_get_component`, `astryx_manifest`, …) and
  resources (`astryx://manifest`, `astryx://components/{name}`,
  `astryx://guidelines/a11y`). A contract test asserts the MCP tool set equals
  the manifest operation set, so the two can't drift.

## Components (by category)

- **Action**: Button, Segmented Control, Dropdown Menu
- **Container**: Card (clickable/selectable), Collapsible
- **Content**: Text, Heading, Avatar, Code / Code Block
- **Data Input**: Checkbox, Switch, Text Input, Field, Slider
- **Feedback**: Badge, Status Dot, Spinner, Banner
- **Layout**: Divider, Section, Grid, Resize Handle, App Shell
- **Navigation**: Breadcrumbs, Pagination, Tab List, Side Nav, Top Nav, Mega Menu
- **Overlay**: Tooltip, Popover, Dialog, Toast

The `example/` gallery wires them into a responsive App Shell (top nav + side
nav) that docks the rail on wide screens and collapses to a drawer on narrow
ones.

## Themes

Ten ready-made themes — `neutral`, `daily`, `butter`, `chocolate`, `matcha`,
`stone`, `gothic` (dark-only), `brutalist` (squared corners), `meta`,
`whatsapp`, `y2k` — each defined as a compact `AstryxThemeSpec` (three seed
colors per brightness + radius + font) and expanded by `buildAstryxTheme`. The
derivation guarantees ≥4.5:1 text and ≥3:1 on-accent contrast in light and dark
(enforced by tests). Swap animates automatically via `AnimatedTheme`. Restyle a
component globally with the `AstryxComponentStyles` theme extension
(`tokens ⊕ theme-level ⊕ per-instance` precedence).

## Components so far

- **Action**: Button, Segmented Control, Dropdown Menu
- **Content**: Text, Heading, Avatar, Code / Code Block
- **Feedback**: Badge, Status Dot, Spinner, Banner
- **Layout**: Divider, Section, Grid
- **Data Input**: Checkbox, Switch, Text Input, Field, Slider
- **Overlay**: Tooltip, Popover, Dialog, Toast

## Monorepo layout

```
tokens/                  # DTCG JSON — single source of truth for design tokens
packages/
  astryx_tokens/         # primitives (const) + semantic ThemeExtensions + context accessors
  astryx_foundations/    # theme-override cascade, reduced-motion, breakpoints, a11y, annotation
  astryx_themes/         # concrete theme bundles (neutral: light + dark)
  astryx_widgets/        # components (Button reference; each swizzle-ready)
  example/               # gallery app dogfooding the system
```

Planned (later milestones): `astryx_icons`, `astryx_registry`, `astryx_core`,
`astryx_cli`, `astryx_mcp`, `astryx_lints`, `astryx_templates`.

## Architecture in one screen

- **Tokens**: authored once in `tokens/*.json`, surfaced as `ThemeExtension`s.
  Components read only *semantic* roles (`context.tokens.color.accentDefault`),
  so any theme drives every component. Primitives are `const` and tree-shakeable.
- **Theming**: `AstryxThemeData.neutral()` → `{ light, dark }` `ThemeData`. Swap is
  animatable (`lerp`); scoped overrides via `AstryxTheme.override(...)`.
- **Styling override** (the `className`/`xstyle` analog): each component ships an
  immutable `*Style` merged over the token default (`AstryxButtonStyle`). Paint →
  style object; structure → builder slots.
- **A11y first**: every component carries `Semantics`, keyboard activation, and a
  keyboard-only focus ring. Reduced motion is honored globally via
  `AstryxMotion.resolve`.

## Run it

```bash
flutter pub get            # resolves the pub workspace (shared lockfile)
flutter analyze            # clean
flutter test               # Button widget/semantics + gallery smoke tests
cd packages/example && flutter run   # the gallery, any platform
```

