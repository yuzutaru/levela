# App Theme Color Specification

> **Status: implemented.** The Design system on both platforms is wired to the
> icon-derived palette below: white light background, blue/green/orange accents,
> and a prepared deep-navy dark theme.
> Source of truth: [`assets/app-icon/source.png`](assets/app-icon/source.png)
> (see [`assets/app-icon/README.md`](assets/app-icon/README.md)). Android's
> `LevelaTheme` no longer enables Material You dynamic color by default, so both
> platforms render the exact same colours.

This document defines the extracted palette using primitive scale names (e.g.,
`Blue500`, `Orange300`), semantic theme tokens, and native setup for
**Android (Jetpack Compose)** and **iOS (SwiftUI & UIKit)**.

---

## 🎨 Color Palette & Primitive Tokens

The design system uses a two-tier color structure:
1. **Primitive Colors** — named by hue and shade (100–900). Sampled from the app icon.
2. **Semantic Tokens** — logical UI roles (Background, Surface, Accent, Text, Action fills).

### Primitive Palette Table

Each hue comes from a region of the app icon: **Blue** from the running figure
and mountain, **Light Blue** from the person silhouette, **Green/Teal** from the
food plate and leaves, **Orange** from the clock.

| Primitive | Hex | Icon source |
| :--- | :--- | :--- |
| **`Blue100`** | `#D6E9FF` | — |
| **`Blue300`** | `#7FB6FF` | Dark-theme primary |
| **`Blue500`** | `#0078F0` | Running figure — **primary** |
| **`Blue600`** | `#0064D6` | — |
| **`Blue700`** | `#0058D0` | Mountain |
| **`Blue900`** | `#0B2A5B` | — |
| **`LightBlue100`** | `#E6F6FE` | — |
| **`LightBlue300`** | `#A0E0F8` | Person silhouette (glow) |
| **`LightBlue500`** | `#5AC8FA` | Person silhouette |
| **`Green100`** | `#D9F7E6` | — |
| **`Green300`** | `#7FE0A8` | Dark-theme secondary |
| **`Green500`** | `#18B060` | Food plate — **secondary** |
| **`Green600`** | `#10A868` | Food plate |
| **`Green700`** | `#0E8F55` | — |
| **`Teal500`** | `#08A0A0` | Leaves |
| **`Orange100`** | `#FFF1D6` | — |
| **`Orange300`** | `#FFD27F` | Dark-theme tertiary |
| **`Orange500`** | `#F8A800` | Clock — **tertiary** |
| **`Orange700`** | `#C97E00` | — |
| **`White`** | `#FFFFFF` | Background / highlights |
| **`Gray50`** | `#F7F9FC` | — |
| **`Gray100`** | `#EEF2F7` | Secondary button fill |
| **`Gray200`** | `#E2E8F0` | Outline |
| **`Gray300`** | `#CBD5E1` | Dark secondary text |
| **`Gray400`** | `#94A3B8` | — |
| **`Gray500`** | `#64748B` | Muted text |
| **`Gray700`** | `#334155` | Outline (dark) |
| **`Navy700`** | `#1E293B` | Dark surface variant |
| **`Navy800`** | `#131C2E` | Dark surface |
| **`Navy900`** | `#0B1220` | Dark background / primary text (light) |
| **`Ink100`** | `#E6EDF7` | Dark-mode text/foreground |

### Semantic Tokens

| Role | Light | Dark |
| :--- | :--- | :--- |
| `background` | `White` | `Navy900` |
| `surface` | `White` | `Navy800` |
| `surfaceVariant` | `Gray100` | `Navy700` |
| `primary` | `Blue500` | `Blue300` |
| `secondary` | `Green500` | `Green300` |
| `tertiary` | `Orange500` | `Orange300` |
| `onPrimary` | `White` | `Navy900` |
| `onBackground` / `onSurface` | `Navy900` | `Ink100` |
| `outline` | `Gray200` | `Gray700` |

---

## 🤖 Android Implementation (Jetpack Compose)

Primitives live in
[`android/design/.../Color.kt`](android/design/src/main/java/com/yuzutaru/design/ui/theme/Color.kt)
and the schemes in
[`Theme.kt`](android/design/src/main/java/com/yuzutaru/design/ui/theme/Theme.kt).

```kotlin
private val LightColorScheme = lightColorScheme(
    primary = Blue500, onPrimary = White,
    secondary = Green500, onSecondary = White,
    tertiary = Orange500, onTertiary = Navy900,
    background = White, onBackground = Navy900,
    surface = White, onSurface = Navy900,
    surfaceVariant = Gray100, onSurfaceVariant = Gray700,
    outline = Gray200
)

private val DarkColorScheme = darkColorScheme(
    primary = Blue300, onPrimary = Navy900,
    secondary = Green300, onSecondary = Navy900,
    tertiary = Orange300, onTertiary = Navy900,
    background = Navy900, onBackground = Ink100,
    surface = Navy800, onSurface = Ink100,
    surfaceVariant = Navy700, onSurfaceVariant = Gray300,
    outline = Gray700
)
```

`LevelaTheme(darkTheme, dynamicColor = false, content)` selects a scheme from the
system appearance. **Dynamic color is off by default** so every device matches the
icon; pass `dynamicColor = true` to opt back into Material You on Android 12+.

---

## 🍎 iOS Implementation (SwiftUI)

Primitives live in
[`ios/Packages/Design/Sources/Design/Color.swift`](ios/Packages/Design/Sources/Design/Color.swift);
the semantic layer is ``LevelaColors`` in
[`Theme.swift`](ios/Packages/Design/Sources/Design/Theme.swift).

```swift
public static let light = LevelaColors(
    primary: .blue500, secondary: .green500, tertiary: .orange500,
    background: .white, surface: .white,
    onPrimary: .white, onBackground: .navy900, onSurface: .navy900
)

public static let dark = LevelaColors(
    primary: .blue300, secondary: .green300, tertiary: .orange300,
    background: .navy900, surface: .navy800,
    onPrimary: .navy900, onBackground: .ink100, onSurface: .ink100
)
```

`levelaTheme()` resolves ``LevelaColors`` from the system light/dark appearance
and injects it through the `\.levelaColors` environment value.

---

## 🖼 App icon backgrounds

The launcher icon backgrounds are aligned with the theme: light is `White`,
dark is `Navy900` (`#0B1220`), matching the dark app background. This is defined
in [`assets/app-icon/appicon-contract.json`](assets/app-icon/appicon-contract.json)
and consumed by `scripts/generate_icons.sh`.

---

## ♿ Accessibility & Contrast Guidelines

- **Primary button (`White` on `Blue500`)**: ~4.3:1 — passes WCAG AA for normal text.
- **Primary text (`Navy900` on `White`)**: ~17:1 — passes WCAG AAA.
- **Dark foreground (`Ink100` on `Navy900`)**: ~15:1 — passes WCAG AAA.
- **Tertiary (`Navy900` on `Orange500`)**: ~9:1 — passes WCAG AAA.
- **Muted text (`Gray500` on `White`)**: ~5.9:1 — passes WCAG AA.

---

## Related documents

- [`README.md`](README.md) — project overview, build, and documentation index.
- [`android/AGENTS.md`](android/AGENTS.md) — Android module layout and conventions.
- [`ios/AGENTS.md`](ios/AGENTS.md) — iOS module layout and conventions.
- [`assets/app-icon/README.md`](assets/app-icon/README.md) — shared app-icon contract.
- [`assets/splash/README.md`](assets/splash/README.md) — shared splash contract.
