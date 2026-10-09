# AGENTS.md — Levela Android

Guidance for AI coding agents working in `android/`. Keep this file accurate when
the structure changes.

## What this is

Levela's Android app: Kotlin + Jetpack Compose, Material 3, single-activity.
The iOS app lives in `../ios/` (SwiftUI + SwiftData) and is out of scope here.

## Module layout

Four Gradle modules, declared in `settings.gradle.kts`:

- **`:app`** — the application. Entry point is
  `app/src/main/java/com/yuzutaru/levela/MainActivity.kt`
  (`ComponentActivity` → `setContent` → `LevelaTheme` → `SplashView`, then
  `OnboardingView` after the guest entry).
- **`:design`** — a library module holding the shared design system under
  `design/src/main/java/com/yuzutaru/design/ui/theme/`. `:app` depends on
  `project(":design")`, so all theme primitives live here, not in `:app`.
- **`:onboarding`** — the post-guest onboarding flow (weight, height) under
  `onboarding/src/main/java/com/yuzutaru/onboarding/`. Depends on `:design`; the
  iOS counterpart is the `Onboarding` Swift package.
- **`:splash`** — the launch welcome flow under
  `splash/src/main/java/com/yuzutaru/splash/`. Depends on `:design`; `:app`
  depends on it. The iOS counterpart is the `Splash` Swift package.

Namespaces: `com.yuzutaru.levela` (`:app`), `com.yuzutaru.design` (`:design`),
`com.yuzutaru.onboarding` (`:onboarding`), `com.yuzutaru.splash` (`:splash`).

## Build & run

```sh
cd android
./gradlew assembleDebug          # debug APK -> app/build/outputs/apk/debug/
./gradlew :app:test              # app unit tests
./gradlew :design:test           # design unit tests
./gradlew connectedAndroidTest   # instrumented tests (needs a device/emulator)
```

- JDK 11 (source/target compatibility is `VERSION_11`).
- `compileSdk = 37`, `targetSdk = 37`, `minSdk = 24`.
- Versions are centralized in `gradle/libs.versions.toml`; reference dependencies
  via the `libs.*` accessors, not hardcoded strings.
- AGP `9.x` uses the block form `compileSdk { version = release(37) }`.

## Design system (`:design`)

All theme code is in `com/yuzutaru/design/ui/theme/`:

| File | Contents |
| --- | --- |
| `Color.kt` | The icon-derived primitive scale from `THEME_COLORS.md` (`Blue500`, `Green500`, `Orange500`, `LightBlue*`, `Gray*`, `Navy*`, `Ink100`, `White`). |
| `Font.kt` | `FontFamily` definitions backed by `res/font/*.ttf`. |
| `Type.kt` | The Material 3 `Typography` scale mapping styles → families. |
| `Theme.kt` | `LevelaTheme` composable: light/dark color schemes + typography + (opt-in) dynamic color. |

Typography convention (kept in `Type.kt`):

- Headings (`display*`, `headline*`, `title*`) use **Poppins**.
- Body text and labels (`body*`, `label*`) use **Inter**.
- **Plus Jakarta Sans** and **Urbanist** are also defined in `Font.kt` and are
  available for ad-hoc use — they are not wired into `Typography`.

`LevelaTheme` selects the light or dark `ColorScheme` from the system
appearance. **Dynamic color is off by default** (`dynamicColor = false`) so the
app matches the icon on every device; pass `dynamicColor = true` to opt into
Material You on Android 12+ (`Build.VERSION_CODES.S`).

Fonts live in `design/src/main/res/font/`. The raw font downloads are gitignored
at the repo root; only the bundled `.ttf` files are tracked.

## App icon

Launcher icons are **generated** — do not hand-edit `app/src/main/res/mipmap-*`,
`drawable-*/ic_launcher_foreground.png`, or `drawable-*/ic_launcher_monochrome.png`.
They come from the shared contract in `../assets/app-icon/`:

```sh
./scripts/generate_icons.sh            # regenerate Android + iOS, then verify
./scripts/generate_icons.sh --verify   # check without writing
```

The adaptive icon (`mipmap-anydpi-v26/ic_launcher{,_round}.xml`) composes
`@color/ic_launcher_background` (white in `values/colors.xml`, navy in
`values-night/colors.xml`), the safe-zone foreground layer, and an Android 13
monochrome layer. See [`../assets/app-icon/README.md`](../assets/app-icon/README.md).

## Theme colors

`Color.kt` holds the icon-derived primitive scale from
[`../THEME_COLORS.md`](../THEME_COLORS.md) (`Blue500`, `Green500`, `Orange500`,
`LightBlue*`, `Gray*`, `Navy*`, `Ink100`, `White`). `LevelaTheme` maps these onto
the Material 3 light/dark `ColorScheme`s: a white light background with
blue/green/orange accents, and a deep-navy dark theme.

## Splash

The launch welcome flow lives in `:splash` and is defined once, for both
platforms, by the shared contract in `../assets/splash/`:

```sh
./scripts/verify_splash_parity.sh --strict     # require both platforms
```

`SplashView` shows the app's launcher icon foreground (`ic_launcher_foreground`,
injected from `:app`), auto-advances through `SplashStage` (`Brand` → `Welcome` →
`Actions`) and reports completion through `onFinished` when the guest button is
tapped (the app then shows the onboarding flow). The Login / Register buttons are
defined but hidden while accounts are deferred (offline-first), gated by
`SplashTokens.ShowAuthActions`; the guest entry is a primary
`Continue as a guest` button (`SplashTokens.ShowGuestButton`), with the old text
link defined but hidden (`SplashTokens.ShowGuestLink`). See
[`../assets/splash/README.md`](../assets/splash/README.md).

## Onboarding

The post-guest onboarding flow lives in `:onboarding` and is defined once, for
both platforms, by the shared contract in `../assets/onboarding/`:

```sh
./scripts/verify_onboarding_parity.sh --strict     # require both platforms
```

`OnboardingView` shows the welcome step (title, subtitle, hero illustration) and
the weight and height steps (progress segments, unit toggle, a draggable snapping
ruler picker on a tinted value card, back + Next buttons) and reports completion
through `onFinished`. The welcome illustration lives in
`onboarding/src/main/res/drawable-*/welcome_illustration.png` (generated from
`assets/onboarding/welcome-illustration.png`). Canonical values are stored
in kg / cm; switching units converts them. It is shown from `:app` after the
splash guest entry. See
[`../assets/onboarding/README.md`](../assets/onboarding/README.md).

Related docs: [`../ios/AGENTS.md`](../ios/AGENTS.md) (iOS counterpart),
[`../README.md`](../README.md) (project overview).

## Conventions

- Compose-only UI; no XML layouts. `@Preview` composables accompany UI code.
- Commits are platform-separated: the tracked `pre-commit` hook
  (`scripts/install-hooks.sh`) rejects a commit that stages changes under both
  `android/` and `ios/`. Keep Android and iOS changes in separate commits.
- Tests are the generated Compose/AndroidX stubs (`ExampleUnitTest`,
  `ExampleInstrumentedTest`) — replace them with real tests as features land.
- `android/gradlew` is the Gradle wrapper shell script; do not hand-edit it.

## Knowledge graph (graphify)

A graphify knowledge graph can be generated in `graphify-out/`. That directory is
**gitignored** — it is local generated output, not committed:

- `graph.html` — interactive graph, open in a browser.
- `GRAPH_REPORT.md` — community/god-node audit.
- `graph.json` — raw nodes/edges.

Generate or refresh it from this directory with `/graphify android`. Extraction is
code-only (AST, no LLM key), so it rebuilds cheaply. Prefer
`graphify query "<question>"` over re-reading files for architecture questions,
and never edit `graphify-out/` by hand — regenerate it instead.
