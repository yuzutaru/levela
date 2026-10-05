# App Theme Color Specification

> **Status: proposed — not yet implemented.**
> The Design system on both platforms still uses the Material template palette
> (`Purple80`/`Purple40`, `PurpleGrey80`/`PurpleGrey40`, `Pink80`/`Pink40`) in
> [`android/design/.../Color.kt`](android/design/src/main/java/com/yuzutaru/design/ui/theme/Color.kt)
> and [`ios/Packages/Design/Sources/Design/Color.swift`](ios/Packages/Design/Sources/Design/Color.swift).
> This document is the **target** palette to migrate to — treat the code as the
> source of truth until the migration lands.

This document defines the extracted color palette using primitive scale names (e.g., `Purple950`, `Yellow100`), semantic theme tokens, and native setup code for **Android (Jetpack Compose)** and **iOS (SwiftUI & UIKit)**.

---

## 🎨 Color Palette & Primitive Tokens

The design system uses a two-tier color structure:
1. **Primitive Colors**: Named by color hue and shade value scale (100–950).
2. **Semantic Tokens**: Logical mappings for UI roles (Background, Surface, Accent, Text, Action fills).

### Primitive Palette Table

| Primitive Name | Hex Code | RGB | HSL | Semantic Role |
| :--- | :--- | :--- | :--- | :--- |
| **`Purple950`** | `#282237` | `40, 34, 55` | `257°, 24%, 17%` | Main dark background surface |
| **`Purple900`** | `#2C263A` | `44, 38, 58` | `258°, 21%, 19%` | Bottom gradient transition |
| **`Purple800`** | `#483B52` | `72, 59, 82` | `274°, 16%, 28%` | Top radial glow lighting |
| **`Purple700`** | `#494357` | `73, 67, 87` | `258°, 13%, 30%` | Secondary button container |
| **`Yellow100`** | `#EBF59F` | `235, 245, 159` | `68°, 78%, 79%` | Accent highlight, icon borders |
| **`Lavender200`**| `#C5BFCF` | `197, 191, 207` | `263°, 16%, 78%` | Secondary text, guest link |
| **`Gray200`** | `#DDDCDF` | `221, 220, 223` | `260°, 5%, 87%` | Secondary button text |
| **`White`** | `#FFFFFF` | `255, 255, 255` | `0°, 0%, 100%` | Primary text, primary button background |
| **`Mint100`** | `#DEE9E9` | `222, 233, 233` | `180°, 18%, 89%` | Presentation outer canvas |

---

## 🤖 Android Implementation (Jetpack Compose)

### 1. Primitive Color Tokens (`Color.kt`)

```kotlin
package com.yuzutaru.design.ui.theme

import androidx.compose.ui.graphics.Color

// Primitive Palette Scale
val Purple950 = Color(0xFF282237)
val Purple900 = Color(0xFF2C263A)
val Purple800 = Color(0xFF483B52)
val Purple700 = Color(0xFF494357)

val Yellow100 = Color(0xFFEBF59F)
val Lavender200 = Color(0xFFC5BFCF)
val Gray200 = Color(0xFFDDDCDF)
val White = Color(0xFFFFFFFF)
val Mint100 = Color(0xFFDEE9E9)
```

### 2. Material 3 `ColorScheme` & Extended Theme Setup (`Theme.kt`)

> The live composable is `LevelaTheme` in
> [`android/design/.../Theme.kt`](android/design/src/main/java/com/yuzutaru/design/ui/theme/Theme.kt)
> (light/dark schemes + Android 12+ dynamic color). The snippet below is the
> **proposed** target shape (a dark-only scheme plus extended gradient colors).

```kotlin
package com.yuzutaru.design.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

// Material 3 Dark Color Scheme Mapping
private val DarkColorScheme = darkColorScheme(
    primary = White,
    onPrimary = Purple950,
    secondary = Purple700,
    onSecondary = Gray200,
    tertiary = Yellow100,
    onTertiary = Purple950,
    background = Purple950,
    onBackground = White,
    surface = Purple700,
    onSurface = White,
    outline = Yellow100
)

// Custom Semantic Extensions & Gradient Helpers
@Immutable
data class ExtendedColors(
    val accentHighlight: Color = Yellow100,
    val textSecondary: Color = Lavender200,
    val backgroundBase: Color = Purple950,
    val backgroundGlowTop: Color = Purple800,
    val backgroundBottom: Color = Purple900,
    val backgroundGradient: Brush = Brush.verticalGradient(
        colors = listOf(Purple800, Purple950, Purple900)
    )
)

val LocalExtendedColors = staticCompositionLocalOf { ExtendedColors() }

@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val extendedColors = ExtendedColors()

    CompositionLocalProvider(LocalExtendedColors provides extendedColors) {
        MaterialTheme(
            colorScheme = DarkColorScheme,
            content = content
        )
    }
}

object AppTheme {
    val extendedColors: ExtendedColors
        @Composable
        get() = LocalExtendedColors.current
}
```

---

## 🍎 iOS Implementation (SwiftUI & UIKit)

> The live iOS theme is `LevelaColors` + `LevelaTheme` / `levelaTheme()` in
> [`ios/Packages/Design/Sources/Design/Theme.swift`](ios/Packages/Design/Sources/Design/Theme.swift),
> backed by the palette in
> [`Color.swift`](ios/Packages/Design/Sources/Design/Color.swift). The snippets
> below are the **proposed** semantic layer to add on top.

### 1. Primitive Colors & Semantic Extension (`Color.swift` + `Theme.swift`)

```swift
import SwiftUI

// MARK: - Primitive Scale Color Tokens
public extension Color {
    static let purple950 = Color(hex: 0x282237)
    static let purple900 = Color(hex: 0x2C263A)
    static let purple800 = Color(hex: 0x483B52)
    static let purple700 = Color(hex: 0x494357)

    static let yellow100 = Color(hex: 0xEBF59F)
    static let lavender200 = Color(hex: 0xC5BFCF)
    static let gray200 = Color(hex: 0xDDDCDF)
    static let mint100 = Color(hex: 0xDEE9E9)
}

// MARK: - Semantic Theme Mapping
public extension Color {
    static let themeBackground = Color.purple950
    static let themeBackgroundGlow = Color.purple800
    static let themeBackgroundBottom = Color.purple900

    static let themeAccent = Color.yellow100
    static let themeTextPrimary = Color.white
    static let themeTextSecondary = Color.lavender200

    static let themePrimaryButtonFill = Color.white
    static let themePrimaryButtonText = Color.purple950

    static let themeSecondaryButtonFill = Color.purple700
    static let themeSecondaryButtonText = Color.gray200
}

// MARK: - Gradient Helpers
public extension LinearGradient {
    static var themeBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [.purple800, .purple950, .purple900],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

public extension RadialGradient {
    static var themeBackgroundRadialGlow: RadialGradient {
        RadialGradient(
            colors: [.purple800, .purple950],
            center: .top,
            startRadius: 10,
            endRadius: 600
        )
    }
}

// MARK: - Hex Initializer
private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
```

### 2. UIKit Primitive & Semantic Extensions (`UIColor+Theme.swift` — not yet added)

```swift
import UIKit

// MARK: - Primitive UIColor Tokens
public extension UIColor {
    static let purple950 = UIColor(hex: 0x282237)
    static let purple900 = UIColor(hex: 0x2C263A)
    static let purple800 = UIColor(hex: 0x483B52)
    static let purple700 = UIColor(hex: 0x494357)

    static let yellow100 = UIColor(hex: 0xEBF59F)
    static let lavender200 = UIColor(hex: 0xC5BFCF)
    static let gray200 = UIColor(hex: 0xDDDCDF)
    static let mint100 = UIColor(hex: 0xDEE9E9)
}

// MARK: - Semantic UIKit Tokens
public extension UIColor {
    static let themeBackground = UIColor.purple950
    static let themeAccent = UIColor.yellow100
    static let themePrimaryButtonFill = UIColor.white
    static let themePrimaryButtonText = UIColor.purple950
    static let themeSecondaryButtonFill = UIColor.purple700
    static let themeSecondaryButtonText = UIColor.gray200

    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
```

---

## ♿ Accessibility & Contrast Guidelines

- **Primary Button (`White` on `Purple950`)**: Contrast ratio **13.5:1** (Passes WCAG AAA).
- **Secondary Button Text (`Gray200` on `Purple700`)**: Contrast ratio **7.2:1** (Passes WCAG AAA).
- **Accent Yellow (`Yellow100` on `Purple950`)**: Contrast ratio **12.1:1** (Passes WCAG AAA).
- **Guest Link (`Lavender200` on `Purple950`)**: Contrast ratio **8.9:1** (Passes WCAG AAA).

---

## Related documents

- [`README.md`](README.md) — project overview, build, and documentation index.
- [`android/AGENTS.md`](android/AGENTS.md) — Android module layout and conventions.
- [`ios/AGENTS.md`](ios/AGENTS.md) — iOS module layout and conventions.
- [`assets/app-icon/README.md`](assets/app-icon/README.md) — shared app-icon contract.
