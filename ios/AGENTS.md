# AGENTS.md — Levela iOS

Guidance for AI coding agents working in `ios/`. Keep this file accurate when the
structure changes.

## What this is

Levela's iOS app: SwiftUI, single-window, iOS 18+. The Android app lives in
`../android/` (Kotlin + Jetpack Compose) and is out of scope here; its agent
guide is at `../android/AGENTS.md`.

## Module layout

Five Swift modules. The app and its feature packages are separate **local Swift
packages**, so module boundaries are real compile boundaries — the iOS analogue
of the Android Gradle modules.

- **`Levela`** (app target) — the application shell.
  - `Levela/LevelaApp.swift` — `@main` entry; registers fonts, opens the store
    and builds the `AppContainer`, then shows `LevelaRootView`.
  - `Levela/LevelaRootView.swift` — owns the `NavigationStack`, applies `.levelaTheme()`,
    and resolves the launch-time "has profile?" state through `RootViewModel`.
  - `Levela/AppContainer.swift` — the app's dependency graph (composition root;
    holds `ProfileData`, the use cases and the view models).
  - `Levela/AppModule.swift` — the app-level graph bindings (the iOS counterpart
    of Android's `AppModule.kt`).
  - `Levela/RootViewModel.swift` — owns the launch-time profile check (the iOS
    counterpart of Android's `RootViewModel`).
  - `Levela/HasActiveProfileUseCase.swift` — the app-side use case behind that
    check (the counterpart of Android's `HasActiveProfileUseCase`).
  - `Levela/CompleteOnboardingUseCase.swift` + `Levela/ProfileMapping.swift` — the
    app-side use case that maps `OnboardingProfile` → `UserProfile` and saves it.
  - Links the local packages.
- **`Design`** — local Swift package at `Packages/Design`; the shared design system.
- **`Onboarding`** — local Swift package at `Packages/Onboarding`; the onboarding
  feature. Depends on `Design`.
- **`Splash`** — local Swift package at `Packages/Splash`; the launch welcome
  flow. Depends on `Design`. The Android counterpart is the `:splash` module.
- **`Profile`** — local Swift package at `Packages/Profile`; the offline-first
  SwiftData store (a `UserProfileEntity` `@Model` behind a `UserProfileDao`, a
  `UserProfileRepository` and `ProfileData`). No dependencies. The Android
  counterpart is the `:profile` module. It is consumed only through use cases
  (see the Layering section).

Dependency direction: `Levela → Design`, `Levela → Onboarding`, `Levela → Splash`,
`Levela → Profile`, `Onboarding → Design`, `Splash → Design`. Features never
depend on each other or on the app.

## Build & run

```sh
cd ios
xcodebuild -scheme Levela -destination 'generic/platform=iOS Simulator' build
```

Or open `Levela.xcodeproj` in Xcode and run.

- Deployment target: iOS 18; Swift language mode 5 (`swiftLanguageModes: [.v5]`
  in each `Package.swift`, matching the app's `SWIFT_VERSION = 5.0`).
- The packages are referenced from the project via `XCLocalSwiftPackageReference`
  (`Packages/Design`, `Packages/Onboarding`, `Packages/Splash`,
  `Packages/Profile`) and linked to the `Levela` target.
- The Xcode project uses file-system-synchronized groups: files under `Levela/`
  are picked up automatically — no need to edit `project.pbxproj` to add sources
  there. Adding a *new package* does require editing the project.

## Design system (`Design` package)

All theme code is in `Packages/Design/Sources/Design/`:

| File | Contents |
| --- | --- |
| `Color.swift` | `Color` extensions: the icon-derived primitive scale from `THEME_COLORS.md` (`blue500`, `green500`, `orange500`, `lightBlue*`, `pink*`, `gray*`, `navy*`, `ink100`). |
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
`lightBlue*`, `pink*`, `gray*`, `navy*`, `ink100`). `LevelaColors` in `Theme.swift` maps
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
`welcome` → `actions`) and reports completion through `onFinished` when the guest
button is tapped (the app then shows the onboarding flow). The Login /
Register buttons are defined but hidden while accounts are deferred
(offline-first), gated by `SplashTokens.showAuthActions`; the guest entry is a
primary `Continue as a guest` button (`SplashTokens.showGuestButton`), with the
old text link defined but hidden (`SplashTokens.showGuestLink`). The buttons carry
stable accessibility identifiers (`SplashAccessibility`) for the UI tests. See
[`../assets/splash/README.md`](../assets/splash/README.md).

## Onboarding

The post-guest onboarding flow lives in the `Onboarding` package and is defined
once, for both platforms, by the shared contract in `../assets/onboarding/`:

```sh
./scripts/verify_onboarding_parity.sh --strict     # require both platforms
```

`OnboardingView` shows the welcome step (title, subtitle, hero illustration), the
goal step (single-select goal cards — a status dot plus title and subtitle — where
Next stays disabled until a goal is chosen), the gender step (a single-screen
snapping carousel of colour-coded icon-only gender cards — pink female, blue
male, orange neutral — where Continue stays disabled until a gender is chosen,
plus a **Prefer to skip this** pill), the age step (a vertical snapping wheel
picker — the centred age in a solid blue card, neighbours scaled and faded —
Next always enabled), the weight and height steps (progress segments, unit
toggle, a draggable snapping ruler picker on a tinted value card, back + Next
buttons) and the activity step (single-select activity-level cards, Next disabled
until a level is chosen). Tapping Next on the last step asks the view model to
`complete()`,
which persists the profile through its injected save function; once saved,
`onFinished` is called and the app moves on. The
welcome illustration is bundled from
`Sources/Onboarding/Resources/Assets.xcassets/WelcomeIllustration.imageset`
(generated from `assets/onboarding/welcome-illustration.png`). Canonical values
are stored in kg / cm; switching units converts them. It is shown from
`LevelaRootView` after the splash guest entry. See
[`../assets/onboarding/README.md`](../assets/onboarding/README.md).

Tests: `Packages/Onboarding/Tests/OnboardingTests/` holds `OnboardingViewModelTests`
(state/conversions) and `OnboardingViewTests` — in-process view tests that drive the
real views (step gating, unit toggles, completion wiring) through
[ViewInspector](https://github.com/nalexn/ViewInspector), a test-only package
dependency. They run in the package's **unit** test bundle: ViewInspector inspects
the live SwiftUI view tree, which only works same-process, so a UI-testing bundle
cannot use it. Each test seeds a step via the internal
`OnboardingView(step:save:onFinished:)` initializer and asserts against
`OnboardingTokens`, never hardcoded copy. The view model is injected (a plain
`let`, owned by the app), not held in `@State`, so ViewInspector's headless
`inspect()` reads it without SwiftUI's "Accessing State ... without being
installed" runtime warning. They mirror the Android `OnboardingViewTest`,
including tapping an age-wheel row to select it (the row carries the tap
gesture; the test walks up from its label because it is not a `Button`). Run
them from `Packages/Onboarding`:

```sh
xcodebuild test -scheme Onboarding -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

The same sources are mirrored to `OnboardingTests/` at the app level and wired into
the `Levela` scheme (like `SplashTests` / `ProfileTests`), so
`xcodebuild test -scheme Levela` also runs them hosted in the app. The mirror is a
copy — keep both in sync.

The flow is also covered end-to-end by `LevelaUITests/OnboardingUITests.swift`, a
real XCUITest **UI-testing** bundle: it launches the app, enters through the splash
guest button, walks all seven steps and asserts the gating, the unit conversions
(`70 kg → 154 lb`, `170 cm → 5'7"`) and the final Next. It also covers the
gesture paths: swiping the age wheel selects the centred age and clamps at the
contract bounds (`13`…`100`), while swiping the gender carousel only scroll-snaps
without selecting — a tap is still required. It drives the app by
accessibility identifier — `splash.guest` and the `onboarding.*` handles from
`OnboardingAccessibility` / `SplashAccessibility` — not by visible copy. A UI-test
bundle runs out of process and cannot import the feature modules, so those
identifier literals are repeated in the test; keep them in sync. Run it with:

```sh
xcodebuild test -scheme Levela -only-testing:LevelaUITests/OnboardingUITests \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

## Profile (`Profile` package)

The offline-first store, layered like Android's `:profile` so SwiftData types
never leave the module. `Profile` holds a `UserProfileEntity` `@Model` (carrying
the sync envelope), a `UserProfileDao` that owns the raw `ModelContext`
operations, a `UserProfileRepository` (protocol) + `UserProfileRepositoryImpl`
that map between the entity and the public domain `UserProfile` struct, and
`ProfileData` — which builds the `ModelContainer` and hands out repositories. The
app builds a `ProfileData` inside its `AppContainer` (`Levela/AppContainer.swift`)
and binds the save function in `Levela/AppModule.swift`; the onboarding view
model persists through that injected save function on completion, which calls
`CompleteOnboardingUseCase.invoke(_:)` — it maps the flow's values
(`OnboardingProfile.toUserProfile()`, defined in `Levela/ProfileMapping.swift`)
onto a `UserProfile` and saves it as a guest-owned, pending row.

The schema is **sync-ready now, synced later**: every row carries a
client-generated `id` (UUID), a nullable `accountUserId`, a `syncState` (a
`SyncState` enum, backed by `syncStateRaw` so `#Predicate` can match it), an
`updatedAt` timestamp and a `deleted` tombstone. Onboarding rows are written
guest-owned (`accountUserId = nil`, `.pending`) with no network. When accounts
land, registering re-parents the row
(`UserProfileRepository.attachToAccount(id:accountUserId:)`) rather than copying
it, and the same UUID upserts on the backend.

Tests: `xcodebuild test -scheme Profile -destination 'platform=iOS Simulator,name=iPhone 18 Pro'`
from `Packages/Profile` (in-memory `ModelContainer`; `UserProfileDaoTests`,
`UserProfileRepositoryTests`, `UserProfileMappingTests`).

Related docs: [`../android/AGENTS.md`](../android/AGENTS.md) (Android counterpart),
[`../README.md`](../README.md) (project overview).

## Conventions

- SwiftUI only; no storyboards. `#Preview` accompanies UI code.
- Commits are platform-separated: the tracked `pre-commit` hook
  (`scripts/install-hooks.sh`) rejects a commit that stages changes under both
  `android/` and `ios/`. Keep iOS and Android changes in separate commits.
- **Commit convention**: enforce platform-scoped subject in commit messages
  (`feat(android)` / `fix(android)` / `feat(ios)` / `fix(ios)` etc.);
  the `commit-msg` hook validates this and the `pre-commit` hook enforces
  the platform split.
- Cross-module symbols must be `public` (Swift packages do not expose internals).
- Feature view models are `@Observable @MainActor` — the iOS counterpart to
  Android's `@HiltViewModel` + `ViewModel`. They are built by the app's
  `AppContainer` and injected through initializers (e.g. `OnboardingView` takes
  its view model through `init(viewModel:)`). Avoiding `@State` keeps
  ViewInspector's headless `inspect()` from emitting SwiftUI's "Accessing State
  ... without being installed" runtime warning.

## Dependency injection

DI is a hand-rolled composition root that mirrors Android's Hilt graph — there is
no third-party container (Swift has no compile-time DI codegen like Hilt's KSP).
The mapping is deliberate, so the two platforms read the same way:

| Android (Hilt) | iOS |
| --- | --- |
| `@HiltAndroidApp` generated graph | `AppContainer` (built once after `ProfileData.open()`) |
| `@Module @InstallIn(SingletonComponent)` + `@Provides` | `AppModule.swift` static bindings |
| `ProfileDataModule` (`:profile`) | the `Profile` package (`ProfileData.open()`) |
| `@Inject constructor` | plain `init`s, wired by the container |
| `@Singleton` | the container's `let`s (built eagerly once) |
| `@HiltViewModel` + `hiltViewModel()` | `@Observable @MainActor` view model built by the container |
| injected `suspend (OnboardingProfile) -> Unit` | injected `@MainActor (OnboardingProfile) -> Void` save function |

`AppContainer` holds `ProfileData`, the repository, `CompleteOnboardingUseCase`,
`HasActiveProfileUseCase`, the onboarding save function, `RootViewModel` and
`OnboardingViewModel`.
`LevelaRootView` receives the view models from the container and only navigates;
`RootViewModel` owns the launch-time "has profile?" check (the counterpart of
Android's `RootViewModel` + `stateIn`), and the onboarding view model owns
persistence through its injected save function (the counterpart of Android's
`@HiltViewModel` receiving the save function from `AppModule`). Features never
build storage themselves, and the entity/DAO stay inside `Profile`.

App-level navigation lives in `LevelaRootView`. Features expose a route type
(e.g. `OnboardingRoute`) so the app never reaches into feature internals.

## Layering: ViewModel → UseCase → Repository

Every path from the UI to persistence flows one direction: **ViewModel → UseCase
→ Repository → data source** (SwiftData / network). A view model never depends
on a repository (or any persistence/network type) directly — not even for a
trivial read. Use cases are the only consumers of repositories.

- **App-level view models** (e.g. `RootViewModel`) inject a use case directly
  (`HasActiveProfileUseCase`).
- **Feature-package view models** (e.g. `OnboardingViewModel`) inject a plain
  closure (`@MainActor (OnboardingProfile) -> Void`), which the app backs with a
  use case, so the feature never sees `Profile`.
- Bind every new use case in `Levela/AppModule.swift`, build it in
  `AppContainer`, and mirror the change on Android (see
  [`../android/AGENTS.md`](../android/AGENTS.md), Layering section).

Both app-level use cases and `RootViewModel` are unit-tested in
`LevelaTests/CompleteOnboardingUseCaseTests`, `HasActiveProfileUseCaseTests` and
`RootViewModelTests`, using a shared in-memory `FakeUserProfileRepository`
(`LevelaTests/FakeUserProfileRepository.swift`). They mirror the Android tests in
`android/app/src/test/.../domain/usecase/` and `.../presentation/`.

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
