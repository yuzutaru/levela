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

## App icon

The Android and iOS launcher icons are generated from a single master image so the
two platforms can't mismatch. See [`assets/app-icon/README.md`](assets/app-icon/README.md).

```sh
./scripts/generate_icons.sh
```
