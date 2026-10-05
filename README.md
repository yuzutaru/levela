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

## Project layout

- `android/` — Android application (Kotlin, Jetpack Compose). Modules: `:app`, `:design`.
- `ios/` — iOS application (SwiftUI). Modules: `Levela` app + local packages `Design`, `Onboarding`.
- `assets/app-icon/` — master app icon + the contract that drives both platforms' icons.
- `scripts/` — repo tooling, including `generate_icons.sh`.
- `THEME_COLORS.md` — proposed app color palette (not yet wired into code).
- `android/AGENTS.md`, `ios/AGENTS.md` — per-platform agent guides.

## App icon

The Android and iOS launcher icons are generated from a single master image so the
two platforms can't mismatch. See [`assets/app-icon/README.md`](assets/app-icon/README.md).

```sh
./scripts/generate_icons.sh
```

## Theme

The Design system on both platforms currently uses the Material template palette
(`Purple80`/`Pink40`). The target dark purple/yellow palette is specified in
[`THEME_COLORS.md`](THEME_COLORS.md) (**proposed**, not yet wired into code).

## Documentation

| Document | Purpose |
| --- | --- |
| [`README.md`](README.md) | Project overview, build, and layout. |
| [`android/AGENTS.md`](android/AGENTS.md) | Android module layout, design system, conventions. |
| [`ios/AGENTS.md`](ios/AGENTS.md) | iOS module layout, design system, conventions. |
| [`THEME_COLORS.md`](THEME_COLORS.md) | Target app color palette (proposed). |
| [`assets/app-icon/README.md`](assets/app-icon/README.md) | App-icon contract, generator, and outputs. |
