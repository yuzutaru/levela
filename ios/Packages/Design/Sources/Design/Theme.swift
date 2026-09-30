import SwiftUI

/// The resolved color roles for a given appearance.
///
/// Mirrors the light/dark schemes in Android
/// `design/src/main/java/com/yuzutaru/design/ui/theme/Theme.kt`.
///
/// Unlike Android, iOS has no Material You dynamic color, so the theme is driven
/// purely by the system light/dark appearance.
public struct LevelaColors: Sendable {
    public let primary: Color
    public let secondary: Color
    public let tertiary: Color
    public let background: Color
    public let surface: Color
    public let onPrimary: Color
    public let onBackground: Color
    public let onSurface: Color

    public static let light = LevelaColors(
        primary: .purple40,
        secondary: .purpleGrey40,
        tertiary: .pink40,
        background: Color(red: 0xFF / 255, green: 0xFB / 255, blue: 0xFE / 255),
        surface: Color(red: 0xFF / 255, green: 0xFB / 255, blue: 0xFE / 255),
        onPrimary: .white,
        onBackground: Color(red: 0x1C / 255, green: 0x1B / 255, blue: 0x1F / 255),
        onSurface: Color(red: 0x1C / 255, green: 0x1B / 255, blue: 0x1F / 255)
    )

    public static let dark = LevelaColors(
        primary: .purple80,
        secondary: .purpleGrey80,
        tertiary: .pink80,
        background: Color(red: 0x1C / 255, green: 0x1B / 255, blue: 0x1F / 255),
        surface: Color(red: 0x1C / 255, green: 0x1B / 255, blue: 0x1F / 255),
        onPrimary: Color(red: 0x38 / 255, green: 0x1E / 255, blue: 0x72 / 255),
        onBackground: Color(red: 0xE6 / 255, green: 0xE1 / 255, blue: 0xE6 / 255),
        onSurface: Color(red: 0xE6 / 255, green: 0xE1 / 255, blue: 0xE6 / 255)
    )
}

private struct LevelaColorsKey: EnvironmentKey {
    static let defaultValue = LevelaColors.light
}

public extension EnvironmentValues {
    /// The active Levela color roles. Set by ``SwiftUI/View/levelaTheme()``.
    var levelaColors: LevelaColors {
        get { self[LevelaColorsKey.self] }
        set { self[LevelaColorsKey.self] = newValue }
    }
}

/// Applies Levela's color roles for the current light/dark appearance.
public struct LevelaTheme: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public func body(content: Content) -> some View {
        content.environment(\.levelaColors, colorScheme == .dark ? .dark : .light)
    }
}

public extension View {
    /// Applies Levela theming. Compose this at the app root, above `NavigationStack`.
    func levelaTheme() -> some View {
        modifier(LevelaTheme())
    }
}
