# Agrisell Flutter - Agent Rules

These instructions apply to every agent working in this repository unless the
user explicitly gives a conflicting instruction.

## Working rules

- Read the relevant code before editing it. Follow the existing Flutter, Dart,
  naming, widget structure, and styling conventions.
- Keep each change focused on the user's request. Do not refactor, rename, or
  reformat unrelated code.
- Preserve existing user changes. Never overwrite, discard, reset, or revert
  work that the agent did not create unless the user explicitly asks.
- Prefer small, maintainable Flutter and Dart changes. Do not introduce
  dependencies, configuration changes, platform changes, or new architecture
  without a clear need and the user's approval.
- Build accessible Flutter UI: use semantic labels where needed, keep controls
  reachable by keyboard/screen readers when applicable, provide meaningful
  alternatives for images/icons, and keep sufficient color contrast.
- Use app UI font sizes from 12 to 15 only. Do not introduce `TextStyle`
  `fontSize` values below 12 or above 15 unless the user explicitly requests an
  exception. Scale typography responsively within that range so it remains
  readable on small and large screens. Header text must remain larger than its
  related body copy.
- Make font sizes, containers, buttons, and icons adaptive across mobile screen
  sizes. Use responsive constraints, flexible layouts, and `MediaQuery` or
  `LayoutBuilder` where appropriate so text, button dimensions and padding,
  icon sizes, and icon-and-label layouts fit cleanly without clipping,
  overflowing, or looking oversized. Keep icon tap targets accessible.
- Reuse project assets before adding new ones. Prefer icons and images from
  `assets/icons/`, `assets/images/`, and `assets/logo/`; use Material or
  Cupertino icons when appropriate. Do not add an icon dependency unless it is
  needed for a missing icon style.
- Keep Dart code strongly typed: avoid unnecessary `dynamic`, unsafe casts,
  ignored analyzer warnings, and broad `// ignore` comments. Reuse existing
  models, widgets, themes, and helpers where appropriate.
- Follow Dart naming conventions: use `lowerCamelCase` for variables,
  functions, parameters, methods, and fields; use `UpperCamelCase` for classes,
  widgets, enums, extensions, and typedefs; use `lower_snake_case` for Dart
  filenames and directories.
- Prefer `const` constructors and widgets where practical, keep widgets small
  enough to read, and extract reusable widgets only when reuse or readability
  actually improves.
- Keep source files to a maximum of 200 lines of code. If a change would make
  a file exceed that limit, split the code into focused widgets, helpers,
  services, or feature files that match the project structure.
- Do not expose secrets, tokens, credentials, private data, or environment
  values in source code, logs, commits, or responses.
- Do not run destructive commands (`git reset --hard`, broad deletion, force
  pushes, etc.) or deploy/publish changes unless the user explicitly requests
  it.
- Before finishing an implementation, run the most relevant available checks.
  For normal application changes, run `flutter analyze` and `flutter test` when
  practical; run a targeted `flutter build` only when the change affects build
  configuration, assets, platform code, or release behavior. Clearly report any
  check that cannot be run or fails.
- Report the outcome concisely: files changed, what changed, and validation
  performed. Call out assumptions, trade-offs, and blockers plainly.

## Project conventions

- This repository is a Flutter application. Keep application source code inside
  `lib/`, tests inside `test/`, and static assets inside `assets/`.
- Platform folders such as `android/` and `web/` should only be edited when the
  requested change requires platform configuration or platform-specific code.
- Keep visual styling centralized in `lib/core/theme/`. Use only the existing
  Agrisell color palette and semantic theme colors for text, surfaces, buttons,
  borders, icons, and states; do not hard-code duplicate or unapproved colors
  in widgets.
- Prefer reusable widgets over duplicated UI markup when the same behavior or
  layout is needed more than once.
- Keep user-facing app copy clear and consistent with existing Agrisell
  terminology.

## Required project structure

Always choose the correct location below before adding a file. Do not place new
source files at the root of `lib/` unless they are application entry files such
as `main.dart` or a root app widget.

```text
lib/                    Flutter application source
  main.dart             Application entry point and bootstrap
  core/                 Shared app infrastructure
    theme/              Agrisell colors, typography, ThemeData, and styling
    constants/          App-wide constants, route names, and fixed values
    services/           App-wide services and integrations
    utils/              Pure reusable helpers and formatting utilities
    widgets/            Shared widgets used across multiple features
  features/             Feature modules added as the app grows
    <feature_name>/
      data/             API, local storage, DTOs, and repositories
      domain/           Feature models, entities, and business rules
      presentation/     Screens, pages, controllers, and feature widgets
assets/                 Static assets declared in pubspec.yaml
  fonts/                Font files used by the Flutter app
  icons/                Icon assets
  images/               Image assets
  logo/                 Agrisell logo assets
test/                   Widget, unit, and integration-facing tests
android/                Android platform project and configuration
web/                    Web platform project and configuration
```

### Placement and dependency rules

- API request code and persistence integrations belong in a feature `data/`
  folder or in `lib/core/services/` when shared across the whole app. Do not
  embed networking or storage logic directly inside widgets.
- Put screen-level orchestration in feature `presentation/` folders. Extract
  shared UI to `lib/core/widgets/` only when it is reused across features.
- Keep shared theming in `lib/core/theme/`. Use existing Agrisell palette and
  theme values before introducing new colors, fonts, text styles, or component
  styling.
- Keep static assets under `assets/` and declare any new asset paths in
  `pubspec.yaml`. Prefer existing `assets/logo/`, `assets/icons/`, and
  `assets/images/` folders before creating new asset categories.
- Keep tests near the behavior they validate under `test/`, using Flutter's
  standard test tools and the existing lint rules from `analysis_options.yaml`.
- Preserve existing files in their current location unless the user explicitly
  requests a migration. All newly created files and all moved files must use
  this structure.

* Use compact mobile button sizing. For normal buttons, prefer a height of `38` to `40` logical pixels. For smaller secondary buttons, use `36` to `38` logical pixels. Avoid large button heights such as `48`, `52`, or above unless the user explicitly requests a large button.
* For Login, Signup, and main form action buttons, prefer:
  - Height: `38`
  - Max width: `280` to `300`
  - Border radius: `8`
  - Font size: `12` to `13`
  - Horizontal padding: `12` to `14`

* Keep buttons and their icons visually small, clean, and balanced on both compact and large mobile screens such as Samsung S23 Ultra. Adapt widths, padding, and icon spacing to available space; do not make a button unnecessarily tall or full-screen-looking when the content already fits.
* Keep button styling centralized in the existing Agrisell theme or reusable button widgets. Do not hard-code duplicate button sizes across multiple screens when a shared style can be reused.
