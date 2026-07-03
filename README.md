# Astryx for Flutter

A Flutter/Dart port of [Meta's Astryx](https://astryx.atmeta.com/) design system
(React + StyleX → Flutter). Unified branded look across mobile, web, and desktop;
token-driven theming; source-available components (swizzle-ready); with an
AI-parity CLI + MCP server planned (see the plan).

> **Status: Jalon 0 (Foundations) — complete & verified.** Token layer, theming
> cascade, the reference **Button** component, and a gallery example all compile,
> analyze clean, and pass tests. Remaining milestones (MVP component set, themes,
> navigation, tooling) are in the plan.

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
