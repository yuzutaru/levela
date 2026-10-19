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
    public let surfaceVariant: Color
    public let onPrimary: Color
    public let onSecondary: Color
    public let onTertiary: Color
    public let onBackground: Color
    public let onSurface: Color
    public let onSurfaceVariant: Color
    public let outline: Color

    /// White background, icon accents (see THEME_COLORS.md).
    public static let light = LevelaColors(
        primary: .blue500,
        secondary: .green500,
        tertiary: .orange500,
        background: .white,
        surface: .white,
        surfaceVariant: .gray100,
        onPrimary: .white,
        onSecondary: .white,
        onTertiary: .navy900,
        onBackground: .navy900,
        onSurface: .navy900,
        onSurfaceVariant: .gray700,
        outline: .gray200
    )

    /// Prepared dark theme: deep-navy surfaces with lightened accents.
    public static let dark = LevelaColors(
        primary: .blue300,
        secondary: .green300,
        tertiary: .orange300,
        background: .navy900,
        surface: .navy800,
        surfaceVariant: .navy700,
        onPrimary: .navy900,
        onSecondary: .navy900,
        onTertiary: .navy900,
        onBackground: .ink100,
        onSurface: .ink100,
        onSurfaceVariant: .gray300,
        outline: .gray700
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
