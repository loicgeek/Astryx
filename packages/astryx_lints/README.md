# astryx_lints

`custom_lint` rules that enforce Astryx conventions.

Standalone package (not a pub-workspace member) so `custom_lint`'s pinned
analyzer version doesn't conflict with the rest of the workspace.

## Rules

| Rule | Severity | What it flags |
|---|---|---|
| `astryx_avoid_material_import` | warning | `import 'package:flutter/material.dart'` — Astryx is Material-free; import `widgets.dart` and use Astryx components |
| `astryx_prefer_tokens_over_raw_color` | info | raw `Color(...)` construction — prefer `context.tokens.color.*` so theming/dark mode apply |

## Enable in a consumer project

```yaml
# pubspec.yaml
dev_dependencies:
  custom_lint: ^0.7.0
  astryx_lints:
    path: ../astryx_lints   # or a version once published
```

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - custom_lint
```

Then `dart run custom_lint` (or your IDE's Dart analysis) reports the rules. The
`example/` folder is a fixture that exercises both rules.
