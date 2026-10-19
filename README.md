# Levela

Native mobile app: Android (Kotlin + Jetpack Compose) and iOS (SwiftUI). Both
platforms mirror each other module for module, and each shared flow is defined
once by a contract under `assets/`. The app is **offline-first**: a guest's
profile is persisted locally before any account exists.

## App flow

1. **Splash** — the launch welcome screen. The login/register buttons are
   defined but hidden while accounts are deferred; the guest entry is a primary
   **Continue as a guest** button.
2. **Onboarding** — seven guest steps (welcome, goal, gender, age, weight,
   height, activity). The final Next persists a guest-owned profile locally.
3. **Main menu** — a placeholder home screen, reached after onboarding. A
   returning user (one whose profile was already saved) skips onboarding and
   lands here straight after the splash.

## Requirements

- **Android:** Android Studio, JDK 11+, Android SDK (API 37)
- **iOS:** Xcode 27+, iOS 18 SDK

## Build

### Android

```sh
cd android
./gradlew assembleDebug
```

### iOS

```sh
cd ios
xcodebuild -scheme Levela -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Or open `ios/Levela.xcodeproj` in Xcode and run.

## Git hooks

Commits are kept platform-separated: the tracked `pre-commit` hook rejects any
commit that stages changes under both `android/` and `ios/`, and the
`commit-msg` hook requires the commit subject to carry the matching platform
scope — `feat(android): …` for `android/` changes, `feat(ios): …` for `ios/`
changes. Any Conventional Commit type works (`fix(ios): …`, `chore(android): …`,
…); only the scope is enforced. Enable the hooks once per clone:

```sh
./scripts/install-hooks.sh
```

## Project layout

- `android/` — Android application (Kotlin, Jetpack Compose). Modules: `:app`, `:profile`, `:design`, `:onboarding`, `:splash`.
- `ios/` — iOS application (SwiftUI). Modules: `Levela` app + local packages `Design`, `Onboarding`, `Splash`, `Profile`.
- `assets/app-icon/` — master app icon + the contract that drives both platforms' icons.
- `assets/splash/`, `assets/onboarding/` — shared flow contracts mirrored by both platforms.
- `scripts/` — repo tooling, including `generate_icons.sh`, the parity verifiers, and the git hooks (`scripts/hooks/`).
- `AGENTS.md` — root agent guide: commit convention, platform separation, hooks.
- `android/AGENTS.md`, `ios/AGENTS.md` — per-platform agent guides.
- `THEME_COLORS.md` — the icon-derived app color palette (light + dark).
- `SYNC_API.md` — the offline-first sync API contract (not implemented yet).

Tests live beside the code: `android/app/src/test/`, `android/app/src/androidTest/`
and `ios/LevelaTests/`, `ios/LevelaUITests/` at app level, plus each feature
module's own `src/test` / `Tests` directory. See the two AGENTS guides for the
full inventory.

## App icon

The Android and iOS launcher icons are generated from a single master image so the
two platforms can't mismatch. See [`assets/app-icon/README.md`](assets/app-icon/README.md).

```sh
./scripts/generate_icons.sh
```

## Theme

The Design system on both platforms uses the icon-derived palette: a **white
light background** with blue/green/orange accents (sampled from the app icon),
plus a prepared **deep-navy dark theme**. See
[`THEME_COLORS.md`](THEME_COLORS.md). Android's dynamic color is off by default
so both platforms match exactly.

## Documentation

| Document | Purpose |
| --- | --- |
| [`README.md`](README.md) | Project overview, build, and layout. |
| [`AGENTS.md`](AGENTS.md) | Root agent guide: commit convention, platform split, hooks. |
| [`android/AGENTS.md`](android/AGENTS.md) | Android module layout, design system, conventions. |
| [`ios/AGENTS.md`](ios/AGENTS.md) | iOS module layout, design system, conventions. |
| [`THEME_COLORS.md`](THEME_COLORS.md) | Icon-derived app color palette (light + dark). |
| [`SYNC_API.md`](SYNC_API.md) | Offline-first sync API contract (login later → sync on register). |
| [`assets/app-icon/README.md`](assets/app-icon/README.md) | App-icon contract, generator, and outputs. |
| [`assets/splash/README.md`](assets/splash/README.md) | Shared splash flow contract and parity verifier. |
| [`assets/onboarding/README.md`](assets/onboarding/README.md) | Shared onboarding flow contract and parity verifier. |
