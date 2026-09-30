import SwiftUI

/// Levela's type scale.
///
/// Mirrors Android `design/src/main/java/com/yuzutaru/design/ui/theme/Type.kt`:
/// headings (display/headline/title) use Poppins, body text and labels use Inter.
/// Plus Jakarta Sans and Urbanist are also available via ``LevelaFontFamily`` for
/// ad-hoc use and are intentionally not wired into this scale.
public enum LevelaTypography {
    // Display — Poppins Bold.
    public static let displayLarge = LevelaFontFamily.poppins.font(.bold, size: 57, relativeTo: .largeTitle)
    public static let displayMedium = LevelaFontFamily.poppins.font(.bold, size: 45, relativeTo: .largeTitle)
    public static let displaySmall = LevelaFontFamily.poppins.font(.bold, size: 36, relativeTo: .largeTitle)

    // Headline — Poppins SemiBold.
    public static let headlineLarge = LevelaFontFamily.poppins.font(.semibold, size: 32, relativeTo: .title)
    public static let headlineMedium = LevelaFontFamily.poppins.font(.semibold, size: 28, relativeTo: .title)
    public static let headlineSmall = LevelaFontFamily.poppins.font(.semibold, size: 24, relativeTo: .title2)

    // Title — Poppins.
    public static let titleLarge = LevelaFontFamily.poppins.font(.semibold, size: 22, relativeTo: .title2)
    public static let titleMedium = LevelaFontFamily.poppins.font(.medium, size: 16, relativeTo: .title3)
    public static let titleSmall = LevelaFontFamily.poppins.font(.medium, size: 14, relativeTo: .headline)

    // Body — Inter Regular.
    public static let bodyLarge = LevelaFontFamily.inter.font(.regular, size: 16, relativeTo: .body)
    public static let bodyMedium = LevelaFontFamily.inter.font(.regular, size: 14, relativeTo: .body)
    public static let bodySmall = LevelaFontFamily.inter.font(.regular, size: 12, relativeTo: .caption)

    // Label — Inter Medium.
    public static let labelLarge = LevelaFontFamily.inter.font(.medium, size: 14, relativeTo: .subheadline)
    public static let labelMedium = LevelaFontFamily.inter.font(.medium, size: 12, relativeTo: .caption)
    public static let labelSmall = LevelaFontFamily.inter.font(.medium, size: 11, relativeTo: .caption2)
}
