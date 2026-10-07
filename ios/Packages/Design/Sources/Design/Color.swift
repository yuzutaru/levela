import SwiftUI

// Icon-derived palette (see THEME_COLORS.md).
// Sampled from assets/app-icon/source.png. Mirrors Android Color.kt.
public extension Color {
    // Blue — primary (running figure / mountain).
    static let blue100 = Color(hex: 0xD6E9FF)
    static let blue300 = Color(hex: 0x7FB6FF)
    static let blue500 = Color(hex: 0x0078F0)
    static let blue600 = Color(hex: 0x0064D6)
    static let blue700 = Color(hex: 0x0058D0)
    static let blue900 = Color(hex: 0x0B2A5B)

    // Light blue — soft accent (person silhouette).
    static let lightBlue100 = Color(hex: 0xE6F6FE)
    static let lightBlue300 = Color(hex: 0xA0E0F8)
    static let lightBlue500 = Color(hex: 0x5AC8FA)

    // Green — secondary (food / leaves).
    static let green100 = Color(hex: 0xD9F7E6)
    static let green300 = Color(hex: 0x7FE0A8)
    static let green500 = Color(hex: 0x18B060)
    static let green600 = Color(hex: 0x10A868)
    static let green700 = Color(hex: 0x0E8F55)

    // Teal — leaf.
    static let teal500 = Color(hex: 0x08A0A0)

    // Orange — tertiary (clock).
    static let orange100 = Color(hex: 0xFFF1D6)
    static let orange300 = Color(hex: 0xFFD27F)
    static let orange500 = Color(hex: 0xF8A800)
    static let orange700 = Color(hex: 0xC97E00)

    // Neutrals.
    static let gray50 = Color(hex: 0xF7F9FC)
    static let gray100 = Color(hex: 0xEEF2F7)
    static let gray200 = Color(hex: 0xE2E8F0)
    static let gray300 = Color(hex: 0xCBD5E1)
    static let gray400 = Color(hex: 0x94A3B8)
    static let gray500 = Color(hex: 0x64748B)
    static let gray700 = Color(hex: 0x334155)
    static let navy700 = Color(hex: 0x1E293B)
    static let navy800 = Color(hex: 0x131C2E)
    static let navy900 = Color(hex: 0x0B1220)

    // Dark-mode text/foreground.
    static let ink100 = Color(hex: 0xE6EDF7)
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
