# Levela

Cross-platform app: Android (Kotlin + Jetpack Compose) and iOS (SwiftUI).

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
commit that stages changes under both `android/` and `ios/`. Enable it once per
clone:

```sh
./scripts/install-hooks.sh
```

## Project layout

- `android/` — Android application (Kotlin, Jetpack Compose). Modules: `:app`, `:design`, `:onboarding`, `:splash`.
- `ios/` — iOS application (SwiftUI). Modules: `Levela` app + local packages `Design`, `Onboarding`, `Splash`.
- `assets/app-icon/` — master app icon + the contract that drives both platforms' icons.
- `assets/splash/`, `assets/onboarding/` — shared flow contracts mirrored by both platforms.
- `scripts/` — repo tooling, including `generate_icons.sh` and the parity verifiers.
- `THEME_COLORS.md` — the icon-derived app color palette (light + dark).
- `android/AGENTS.md`, `ios/AGENTS.md` — per-platform agent guides.

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
| [`android/AGENTS.md`](android/AGENTS.md) | Android module layout, design system, conventions. |
| [`ios/AGENTS.md`](ios/AGENTS.md) | iOS module layout, design system, conventions. |
| [`THEME_COLORS.md`](THEME_COLORS.md) | Icon-derived app color palette (light + dark). |
| [`assets/app-icon/README.md`](assets/app-icon/README.md) | App-icon contract, generator, and outputs. |
