# AGENTS.md — Levela Android

Guidance for AI coding agents working in `android/`. Keep this file accurate when
the structure changes.

## What this is

Levela's Android app: Kotlin + Jetpack Compose, Material 3, single-activity.
The iOS app lives in `../ios/` (SwiftUI + SwiftData) and is out of scope here.

## Module layout

Five Gradle modules, declared in `settings.gradle.kts`:

- **`:app`** — the application. Entry point is
  `app/src/main/java/com/yuzutaru/levela/MainActivity.kt`
  (`ComponentActivity` → `setContent` → `LevelaTheme` → `SplashView`, then
  `OnboardingView` after the guest entry). Hosts the app-level use cases; view
  models follow ViewModel → UseCase → Repository (see the Layering section).
- **`:design`** — a library module holding the shared design system under
  `design/src/main/java/com/yuzutaru/design/ui/theme/`. `:app` depends on
  `project(":design")`, so all theme primitives live here, not in `:app`.
- **`:profile`** — the profile feature: the offline-first persistence layer (Room)
  under `profile/src/main/java/com/yuzutaru/profile/`, holding the `user_profile`
  table plus its DAO, database and repository. Room types never leave the module.
  `:app` depends on it and owns it via Hilt (`ProfileDataModule` provides the
  repository), and it will host the profile screen. The iOS counterpart is the
  `Profile` package. It is consumed only through use cases (see the Layering
  section).
- **`:onboarding`** — the post-guest onboarding flow (welcome, goal, profile,
  weight, height, activity) under
  `onboarding/src/main/java/com/yuzutaru/onboarding/`. Holds a lifecycle
  `OnboardingViewModel` that persists through an injected
  `suspend (OnboardingProfile) -> Unit` save function (the app supplies the
  persistence-backed implementation, so this module never sees `:profile`).
  Depends on `:design` and `lifecycle-viewmodel`; the iOS counterpart is the
  `Onboarding` Swift package. The injected function is backed by an app-side use
  case (see the Layering section).
- **`:splash`** — the launch welcome flow under
  `splash/src/main/java/com/yuzutaru/splash/`. Depends on `:design`; `:app`
  depends on it. The iOS counterpart is the `Splash` Swift package.

Namespaces: `com.yuzutaru.levela` (`:app`), `com.yuzutaru.profile` (`:profile`),
`com.yuzutaru.design` (`:design`), `com.yuzutaru.onboarding` (`:onboarding`),
`com.yuzutaru.splash` (`:splash`).

## Build & run

```sh
cd android
./gradlew assembleDebug          # debug APK -> app/build/outputs/apk/debug/
./gradlew :app:test              # app unit tests
./gradlew :design:test           # design unit tests
./gradlew :profile:test          # profile unit tests
./gradlew connectedAndroidTest   # instrumented tests (needs a device/emulator)
```

- JDK 11 (source/target compatibility is `VERSION_11`).
- `compileSdk = 37`, `targetSdk = 37`, `minSdk = 24`.
- Versions are centralized in `gradle/libs.versions.toml`; reference dependencies
  via the `libs.*` accessors, not hardcoded strings.
- AGP `9.x` uses the block form `compileSdk { version = release(37) }`.
- `android.disallowKotlinSourceSets=false` is set in `gradle.properties`: AGP 9's
  built-in Kotlin rejects the generated source dirs KSP registers for Room.

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

`OnboardingView` shows the welcome step (title, subtitle, hero illustration), the
goal step (single-select goal cards — a status dot plus title and subtitle — where
Next stays disabled until a goal is chosen), the profile step (an age ruler picker
plus single-select biological-sex cards, Next disabled until a sex option is
chosen), the weight and height steps (progress segments, unit toggle, a
draggable snapping ruler picker on a tinted value card, back + Next buttons) and
the activity step (single-select activity-level cards, Next disabled until a level
is chosen). Tapping Next on the final step asks `OnboardingViewModel.complete()`,
which persists the collected profile through its injected
`suspend (OnboardingProfile) -> Unit` save function; once saved, the view reports
completion through `onFinished`. The welcome illustration lives in
`onboarding/src/main/res/drawable-*/welcome_illustration.png` (generated from
`assets/onboarding/welcome-illustration.png`). Canonical values are stored
in kg / cm; switching units converts them. It is shown from `:app` after the
splash guest entry. See
[`../assets/onboarding/README.md`](../assets/onboarding/README.md).

Related docs: [`../ios/AGENTS.md`](../ios/AGENTS.md) (iOS counterpart),
[`../README.md`](../README.md) (project overview).

## Dependency injection (Hilt)

DI is Hilt (`com.google.dagger.hilt.android` plugin, `hilt-android` +
`hilt-compiler` via KSP, centrally versioned in `gradle/libs.versions.toml` —
must be 2.60+ for AGP 9 support). `LevelaApplication` is `@HiltAndroidApp` and
`MainActivity` is `@AndroidEntryPoint`. The old hand-rolled `AppContainer` was
removed; the graph is now:

- `app/di/AppModule.kt` — binds `CompleteOnboardingUseCase`,
  `HasActiveProfileUseCase` and the `suspend (OnboardingProfile) -> Unit` save
  function.
- `profile/src/main/java/com/yuzutaru/profile/data/di/ProfileDataModule.kt` —
  provides `ProfileData` and `UserProfileRepository`.
- View models are `@HiltViewModel` with `@Inject` constructors and are resolved
  in Compose with `hiltViewModel()`; features (`:onboarding`) may declare their
  own `@HiltViewModel` but must not depend on `:profile`.

When injecting Kotlin functional types, annotate both the `@Provides` return
type and the injection site with `@JvmSuppressWildcards` so the generic
signatures match.

The iOS counterpart is a hand-rolled composition root that mirrors this graph
(no third-party container): `ios/Levela/AppModule.swift` is the `@Module`,
`ios/Levela/AppContainer.swift` is the composition root, and view models
(`RootViewModel`, `OnboardingViewModel`) are built there instead of by
`hiltViewModel()`. Keep the two graphs in step when either changes — see
[`../ios/AGENTS.md`](../ios/AGENTS.md#dependency-injection).

## Layering: ViewModel → UseCase → Repository

Every path from the UI to persistence flows one direction: **ViewModel → UseCase
→ Repository → data source** (Room / network). A view model never depends on a
repository (or any persistence/network type) directly — not even for a trivial
read. Use cases are the only consumers of repositories.

- **App-level view models** (e.g. `RootViewModel`) inject a use case directly
  (`HasActiveProfileUseCase`).
- **Feature-module view models** (e.g. `OnboardingViewModel`) inject a plain
  functional type (`suspend (OnboardingProfile) -> Unit`), which `:app` backs
  with a use case, so the feature never sees `:profile`.
- Bind every new use case in `app/di/AppModule.kt` and mirror the change on iOS
  (see [`../ios/AGENTS.md`](../ios/AGENTS.md), Layering section).

## Persistence (`:profile`)

The offline-first store. `:profile` holds a Room database (`ProfileDatabase`) with
one `user_profile` table and a `UserProfileRepository`. Room types never leave the
module: `ProfileData` builds the database and hands out repositories, Hilt
provides it to `:app` through `ProfileDataModule`. Onboarding completion is
persisted by `:app`'s `CompleteOnboardingUseCase` — it maps `OnboardingProfile`
to a `UserProfile` row (`ProfileMapping.kt`) and calls the repository. The use
case and the `suspend (OnboardingProfile) -> Unit` save function are bound in
`app/di/AppModule.kt`; view models are `@HiltViewModel` classes retrieved with
`hiltViewModel()`, and `MainActivity` (`@AndroidEntryPoint`) only handles
navigation.

The schema is **sync-ready now, synced later**: every row carries a
client-generated `id` (UUID), a nullable `accountUserId`, a `syncState` (a
`SyncState` enum), an `updatedAt` timestamp and a `deleted` tombstone. Onboarding
rows are written guest-owned (`accountUserId = null`, `syncState = Pending`) with
no network. When accounts land, registering re-parents the row
(`UserProfileRepository.attachToAccount`) rather than copying it, and the same
UUID upserts on the backend.

- Room schema JSON is exported to `profile/schemas/`; bump the DB version and add a
  `Migration` on schema changes — never a destructive fallback.

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
