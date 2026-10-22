# AGENTS.md — Levela Android

Guidance for AI coding agents working in `android/`. Keep this file accurate when
the structure changes.

## What this is

Levela's Android app: Kotlin + Jetpack Compose, Material 3, single-activity.
The iOS app lives in `../ios/` (SwiftUI + SwiftData) and is out of scope here.

## Module layout

Seven Gradle modules, declared in `settings.gradle.kts`:

- **`:app`** — the application. Entry point is
  `app/src/main/java/com/yuzutaru/levela/MainActivity.kt`
  (`ComponentActivity` → `setContent` → `LevelaTheme`), which drives a small
  `LevelaFlow` (`Splash` → `Onboarding` → `MainMenu`) crossfade. `RootViewModel`
  resolves the launch-time "has profile?" state: a new guest walks
  `SplashView` → `OnboardingView` → `MainMenuScreen` (`presentation/MainMenuScreen.kt`,
  the bottom-navigation main menu: Today · Nutrition · Train · Profile — the
  Today and Nutrition destinations live in the `:mainmenu` module; Train and
  Profile are placeholders), while
  a returning user (profile already saved) skips
  onboarding and lands on `MainMenuScreen` straight after the splash. Hosts the
  app-level use cases; view models follow ViewModel → UseCase → Repository (see
  the Layering section).
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
- **`:onboarding`** — the post-guest onboarding flow (welcome, goal, gender, age,
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
- **`:mainmenu`** — the Today and Nutrition destinations (the main menu's
  landing destinations) under `mainmenu/src/main/java/com/yuzutaru/mainmenu/`.
  Holds `TodayScreen` (the summary cards plus the fasting tracker),
  `NutritionScreen` (the Nutrition page title), `FastingSection` (the fasting
  tracker card, in its own file), `TodayTokens`, `NutritionTokens`, the shared
  page chrome (`MenuPage.kt` — the page padding and the `MenuPageTitle` heading),
  the fasting widgets and the mock `FastingSummary`;
  depends on `:design` and `:summary` (the shell draws the shared splash-style
  background). The iOS counterpart is the `MainMenu` Swift package.
- **`:summary`** — the shared dashboard summary cards under
  `summary/src/main/java/com/yuzutaru/summary/`. Holds `SummaryCards` (the
  three-card row), the nutrition summary card, the macro ring, the step and
  active-minutes cards, and the `summaryCard()` chrome. Depends only on `:design`.
  Consumed by `:mainmenu` (Today). The iOS counterpart is the `Summary` Swift
  package.

Namespaces: `com.yuzutaru.levela` (`:app`), `com.yuzutaru.profile` (`:profile`),
`com.yuzutaru.design` (`:design`), `com.yuzutaru.onboarding` (`:onboarding`),
`com.yuzutaru.splash` (`:splash`), `com.yuzutaru.mainmenu` (`:mainmenu`),
`com.yuzutaru.summary` (`:summary`).

## Build & run

```sh
cd android
./gradlew assembleDebug          # debug APK -> app/build/outputs/apk/debug/
./gradlew :app:test              # app unit tests
./gradlew :design:test           # design unit tests
./gradlew :profile:test          # profile unit tests
./gradlew :mainmenu:test         # mainmenu unit tests
./gradlew :summary:test          # summary unit tests
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
| `Color.kt` | The icon-derived primitive scale from `THEME_COLORS.md` (`Blue500`, `Green500`, `Orange500`, `LightBlue*`, `Pink*`, `Gray*`, `Navy*`, `Ink100`, `White`). |
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
[`../assets/theme/THEME_COLORS.md`](../assets/theme/THEME_COLORS.md) (`Blue500`, `Green500`, `Orange500`,
`LightBlue*`, `Pink*`, `Gray*`, `Navy*`, `Ink100`, `White`). `LevelaTheme` maps these onto
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
Next stays disabled until a goal is chosen), the gender step (a single-screen
snapping carousel of colour-coded gender cards — each a large gender symbol,
a label and a selection check, pink female / blue male / orange neutral — where
Continue stays disabled until a gender is chosen, plus a **Prefer to skip this**
pill), the age step (a vertical snapping wheel
picker — the centred age in a solid blue card, neighbours scaled and faded —
Next always enabled), the weight and height steps (progress segments, unit
toggle, a draggable snapping ruler picker on a tinted value card, back + Next
buttons) and the activity step (single-select activity-level cards, Next disabled
until a level is chosen). Tapping Next on the final step asks
`OnboardingViewModel.complete()`,
which persists the collected profile through its injected
`suspend (OnboardingProfile) -> Unit` save function; once saved, the view reports
completion through `onFinished`. The welcome illustration lives in
`onboarding/src/main/res/drawable-*/welcome_illustration.png` (generated from
`assets/onboarding/welcome-illustration.png`). Canonical values are stored
in kg / cm; switching units converts them. It is shown from `:app` after the
splash guest entry. See
[`../assets/onboarding/README.md`](../assets/onboarding/README.md).

Tests: `onboarding/src/test/.../OnboardingViewModelTest.kt` covers the state and
unit conversions (with `MainDispatcherRule.kt` swapping `Dispatchers.Main`);
`onboarding/src/androidTest/.../OnboardingViewTest.kt` drives
the real composables (step gating, unit toggles, the age wheel and gender
carousel tap/**drag** paths, completion wiring). The guest path through the whole
app is covered end-to-end by `app/src/androidTest/.../MainActivityOnboardingE2ETest.kt`
(splash guest entry → seven steps → main menu, asserting the persisted profile);
it enters through the splash guest button's `SplashGuestButtonTag`
(`splash:guest`). The returning-user path is covered by
`app/src/androidTest/.../MainActivityRoutingTest.kt` (seeds a profile, launches
the activity and asserts it lands on the main menu). Run the instrumented suites
with
`./gradlew :onboarding:connectedDebugAndroidTest :app:connectedDebugAndroidTest`.

Related docs: [`../ios/AGENTS.md`](../ios/AGENTS.md) (iOS counterpart),
[`../README.md`](../README.md) (project overview).

## Today

The Today destination (the main menu's landing destination) lives in `:mainmenu`
under `mainmenu/src/main/java/com/yuzutaru/mainmenu/`. It is a scrollable screen:
a large top-left heading, then the shared summary row from `:summary` — a mock
nutrition summary card (consumed calories, a macro progress ring, per-macro
rows), a mock step summary card (the day's step count and the distance it
corresponds to) and a mock active minutes card (the day's active minutes and the
daily average) — and, below it, the fasting tracker card.

The summary row (`SummaryCards`) is the nutrition card on the left half and, on
the right half, the step summary card (`StepsCard`) on top of the active minutes
card (`ActiveMinutesCard`), each filling half of the nutrition card's height and
sharing the card chrome through the `summaryCard()` modifier.

The fasting tracker lives in its own file, `FastingSection.kt` (the counterpart of
iOS's `Presentation/FastingSection.swift`), and stacks a `PhaseBanner` ("New
Phase!"), a `FastingRing` (the elapsed arc, the flame badge at its leading edge,
stage markers, a static timer and a skip control), `FastingTimes` (the start/end
times) and the `EndFastingButton` — mock data shaped for the future model
(`FastingSummary`), with the timer, the banner's ✕, the skip control and End
Fasting visual-only. The whole section is wrapped in the shared `summaryCard()`
chrome (white surface, 28dp corner, 12dp shadow, 20dp inner padding), so the
fasting tracker reads as a card like the summary row above it.

`TodayTokens` holds the heading copy and the stable `mainmenu.today` test tag that
the app-level routing and end-to-end tests assert against. The shared splash-style
background is drawn by the app shell (`MenuBackground` in `MainMenuScreen`); the
module paints content only and depends on `:design` and `:summary`. The iOS
counterpart is the `MainMenu` Swift package.

## Nutrition

The Nutrition destination lives in `:mainmenu` next to Today, in
`NutritionScreen.kt` (the counterpart of iOS's `Presentation/NutritionView.swift`).
It is a scrollable screen carrying just the page title — the content is empty
until the nutrition widgets land. `NutritionTokens` holds the title copy
("Nutrition") and the stable `mainmenu.nutrition` test tag.

Every destination titles itself the same way: a large top-left heading
(`displaySmall`, `Navy900`) over the page's content, with the page padding
(24dp horizontal, 8dp top, 24dp bottom) held in `MenuPageLayout` and the
heading itself in `MenuPageTitle` (both in `MenuPage.kt`). Today, Nutrition and
the app shell's Train/Profile placeholders all use them, so the titles cannot
drift apart.

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
(no third-party container): `ios/Levela/Di/AppModule.swift` is the `@Module`,
`ios/Levela/Di/AppContainer.swift` is the composition root, and view models
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
- **Commit convention**: enforce platform-scoped subject in commit messages
  (`feat(android)` / `fix(android)` / `feat(ios)` / `fix(ios)` etc.);
  the `commit-msg` hook validates this and the `pre-commit` hook enforces
  the platform split.
- Unit tests live beside the code under `src/test`; the app module covers the
  mapping, both app-level use cases and `RootViewModel`
  (`ProfileMappingTest`, `domain/usecase/CompleteOnboardingUseCaseTest`,
  `domain/usecase/HasActiveProfileUseCaseTest`, `presentation/RootViewModelTest`),
  sharing an in-memory `FakeUserProfileRepository`. Instrumented tests
  (`src/androidTest`) cover the routing (`MainActivityRoutingTest`) and the guest
  end-to-end path (`MainActivityOnboardingE2ETest`). The generated
  `ExampleUnitTest` / `ExampleInstrumentedTest` stubs remain only as placeholders.
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
