# AGENTS.md — Levela iOS

Guidance for AI coding agents working in `ios/`. Keep this file accurate when the
structure changes.

## What this is

Levela's iOS app: SwiftUI, single-window, iOS 18+. The Android app lives in
`../android/` (Kotlin + Jetpack Compose) and is out of scope here; its agent
guide is at `../android/AGENTS.md`.

## Module layout

Four Swift modules. The app and its feature packages are separate **local Swift
packages**, so module boundaries are real compile boundaries — the iOS analogue
of the Android Gradle modules.

- **`Levela`** (app target) — the application shell.
  - `Levela/LevelaApp.swift` — `@main` entry; registers fonts, shows `LevelaRootView`.
  - `Levela/LevelaRootView.swift` — owns the `NavigationStack`, applies `.levelaTheme()`.
  - Links the local packages.
- **`Design`** — local Swift package at `Packages/Design`; the shared design system.
- **`Onboarding`** — local Swift package at `Packages/Onboarding`; the onboarding
  feature. Depends on `Design`.
- **`Splash`** — local Swift package at `Packages/Splash`; the launch welcome
  flow. Depends on `Design`. The Android counterpart is the `:splash` module.

Dependency direction: `Levela → Design`, `Levela → Onboarding`, `Levela → Splash`,
`Onboarding → Design`, `Splash → Design`. Features never depend on each other or
on the app.

## Build & run

```sh
cd ios
xcodebuild -scheme Levela -destination 'generic/platform=iOS Simulator' build
```

Or open `Levela.xcodeproj` in Xcode and run.

- Deployment target: iOS 18; Swift language mode 5 (`swiftLanguageModes: [.v5]`
  in each `Package.swift`, matching the app's `SWIFT_VERSION = 5.0`).
- The packages are referenced from the project via `XCLocalSwiftPackageReference`
  (`Packages/Design`, `Packages/Onboarding`, `Packages/Splash`) and linked to the
  `Levela` target.
- The Xcode project uses file-system-synchronized groups: files under `Levela/`
  are picked up automatically — no need to edit `project.pbxproj` to add sources
  there. Adding a *new package* does require editing the project.

## Design system (`Design` package)

All theme code is in `Packages/Design/Sources/Design/`:

| File | Contents |
| --- | --- |
| `Color.swift` | `Color` extensions: the icon-derived primitive scale from `THEME_COLORS.md` (`blue500`, `green500`, `orange500`, `lightBlue*`, `gray*`, `navy*`, `ink100`). |
| `Fonts.swift` | `LevelaFontFamily`, `LevelaFontWeight`, `LevelaFonts.registerAll()`. |
| `Typography.swift` | `LevelaTypography`: the type scale mapping roles → families. |
| `Theme.swift` | `LevelaColors` (light/dark), the `levelaColors` environment value, and the `levelaTheme()` view modifier. |

`Design` maps 1:1 to Android's `:design` module (same palette, font families, and
role→family mapping); the graphify graph in `graphify-out/` is the iOS counterpart
of the one built under `../android/graphify-out/`.

Typography convention (mirrors Android):

- Headings (`display*`, `headline*`, `title*`) use **Poppins**.
- Body text and labels (`body*`, `label*`) use **Inter**.
- **Plus Jakarta Sans** and **Urbanist** are also available via `LevelaFontFamily`
  and are not wired into the scale.

Theming: `levelaTheme()` resolves `LevelaColors` from the system light/dark
appearance. iOS has no Material You dynamic color, so (unlike Android) there is
no dynamic-color branch — just light vs. dark.

Fonts live in `Packages/Design/Sources/Design/Resources/` (flat, so
`Bundle.module` finds them by name). Because they sit inside a package resource
bundle — which the app's `UIAppFonts` Info.plist key cannot reach — they are
registered with CoreText via `LevelaFonts.registerAll()` at launch, then used by
PostScript name.

> **Gotcha:** the bundled Inter files are the 24pt optical size, so their
> PostScript names are `Inter24pt-*`, not `Inter-*`. `Fonts.swift` accounts for
> this; keep it in sync if the font files change.

## App icon

App icons are **generated** — do not hand-edit
`Levela/Assets.xcassets/AppIcon.appiconset/`. The set (`AppIcon-1024.png` for
light, `-dark`, `-tinted`) comes from the shared contract in `../assets/app-icon/`:

```sh
./scripts/generate_icons.sh            # regenerate Android + iOS, then verify
./scripts/generate_icons.sh --verify   # check without writing
```

Light is opaque white, dark is opaque navy (`#0B1220`, matching the dark app
background), and tinted is opaque grayscale on black — matching Apple's iOS 18
requirements. See [`../assets/app-icon/README.md`](../assets/app-icon/README.md).

## Theme colors

`Color.swift` holds the icon-derived primitive scale from
[`../THEME_COLORS.md`](../THEME_COLORS.md) (`blue500`, `green500`, `orange500`,
`lightBlue*`, `gray*`, `navy*`, `ink100`). `LevelaColors` in `Theme.swift` maps
these to semantic roles for light (white background, blue/green/orange accents)
and dark (deep navy) appearances; `levelaTheme()` picks by system appearance.

## Splash

The launch welcome flow lives in the `Splash` package and is defined once, for
both platforms, by the shared contract in `../assets/splash/`:

```sh
./scripts/verify_splash_parity.sh --strict     # require both platforms
```

`SplashView` shows the app icon, injected from the app target as
`Image("SplashIcon")` — a normal imageset in `Levela/Assets.xcassets`, because
iOS app icons (`AppIcon.appiconset`) are **not** loadable at runtime via
`UIImage(named: "AppIcon")`. It auto-advances through `SplashStage` (`brand` →
`welcome` → `actions`) and reports completion through `onFinished`. The Login /
Register / guest actions are visual only for now. See
[`../assets/splash/README.md`](../assets/splash/README.md).

Related docs: [`../android/AGENTS.md`](../android/AGENTS.md) (Android counterpart),
[`../README.md`](../README.md) (project overview).

## Conventions

- SwiftUI only; no storyboards. `#Preview` accompanies UI code.
- Cross-module symbols must be `public` (Swift packages do not expose internals).
- Feature view models are `@Observable @MainActor` and held by the view with
  `@State` — the iOS counterpart to Android's Hilt + `ViewModel`. There is no DI
  container; inject via initializers / the SwiftUI environment.
- App-level navigation lives in `LevelaRootView`. Features expose a route type
  (e.g. `OnboardingRoute`) so the app never reaches into feature internals.
- Persistence (SwiftData) is intentionally not wired yet; add a dedicated
  `Core`/`Persistence` package when a feature actually needs it.

## Knowledge graph (graphify)

A graphify knowledge graph can be generated in `graphify-out/`. That directory is
**gitignored** — it is local generated output, not committed:

- `graph.html` — interactive graph, open in a browser.
- `GRAPH_REPORT.md` — community/god-node audit.
- `graph.json` — raw nodes/edges.

Generate or refresh it from this directory with `/graphify ios`. Extraction is
structural (Swift AST, no LLM key) plus semantic extraction of this `AGENTS.md`,
so it rebuilds cheaply. Prefer `graphify query "<question>"` over re-reading files
for architecture questions, and never edit `graphify-out/` by hand — regenerate it
instead.
