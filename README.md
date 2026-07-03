# Astryx for Flutter

A Flutter/Dart port of [Meta's Astryx](https://astryx.atmeta.com/) design system
(React + StyleX → Flutter). Unified branded look across mobile, web, and desktop;
token-driven theming; source-available components (swizzle-ready); with an
AI-parity CLI + MCP server planned (see the plan).

> **Status: Jalon 3 (navigation & structure) — done.** Jalon 0 foundations +
> ~33 components + the full ~10-theme catalog + a responsive App Shell.
> Everything analyzes clean and passes tests (79 across the workspace).
> Remaining milestones (rich inputs, tables, chat, and the CLI/MCP tooling) are
> in the plan.

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

## Full plan

The complete port plan (all milestones, the CLI/MCP parity design, UX/UI
translation strategy) lives at
`~/.claude/plans/je-veux-le-plan-structured-candle.md`.
