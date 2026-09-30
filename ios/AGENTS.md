# AGENTS.md — Levela iOS

Guidance for AI coding agents working in `ios/`. Keep this file accurate when the
structure changes.

## What this is

Levela's iOS app: SwiftUI, single-window, iOS 18+. The Android app lives in
`../android/` (Kotlin + Jetpack Compose) and is out of scope here.

## Module layout

Three Swift modules. The app and its two features are separate **local Swift
packages**, so module boundaries are real compile boundaries — the iOS analogue
of the Android Gradle modules.

- **`Levela`** (app target) — the application shell.
  - `Levela/LevelaApp.swift` — `@main` entry; registers fonts, shows `LevelaRootView`.
  - `Levela/LevelaRootView.swift` — owns the `NavigationStack`, applies `.levelaTheme()`.
  - Links the two local packages.
- **`Design`** — local Swift package at `Packages/Design`; the shared design system.
- **`Onboarding`** — local Swift package at `Packages/Onboarding`; the onboarding
  feature. Depends on `Design`.

Dependency direction: `Levela → Design`, `Levela → Onboarding`,
`Onboarding → Design`. Features never depend on each other or on the app.

## Build & run

```sh
cd ios
xcodebuild -scheme Levela -destination 'generic/platform=iOS Simulator' build
```

Or open `Levela.xcodeproj` in Xcode and run.

- Deployment target: iOS 18; Swift language mode 5 (`swiftLanguageModes: [.v5]`
  in each `Package.swift`, matching the app's `SWIFT_VERSION = 5.0`).
- The packages are referenced from the project via `XCLocalSwiftPackageReference`
  (`Packages/Design`, `Packages/Onboarding`) and linked to the `Levela` target.
- The Xcode project uses file-system-synchronized groups: files under `Levela/`
  are picked up automatically — no need to edit `project.pbxproj` to add sources
  there. Adding a *new package* does require editing the project.

## Design system (`Design` package)

All theme code is in `Packages/Design/Sources/Design/`:

| File | Contents |
| --- | --- |
| `Color.swift` | `Color` extensions: the brand palette (`purple80`, `pink40`, …). |
| `Fonts.swift` | `LevelaFontFamily`, `LevelaFontWeight`, `LevelaFonts.registerAll()`. |
| `Typography.swift` | `LevelaTypography`: the type scale mapping roles → families. |
| `Theme.swift` | `LevelaColors` (light/dark), the `levelaColors` environment value, and the `levelaTheme()` view modifier. |

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
