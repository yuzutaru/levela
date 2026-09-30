# Levela

Cross-platform app: Android (Kotlin + Jetpack Compose) and iOS (SwiftUI + SwiftData).

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

- `android/` — Android application (Kotlin, Jetpack Compose)
- `ios/` — iOS application (SwiftUI, SwiftData)
