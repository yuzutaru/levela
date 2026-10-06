import SwiftUI

// Levela brand palette.
// Mirrors Android `design/src/main/java/com/yuzutaru/design/ui/theme/Color.kt`.
public extension Color {
    static let purple80 = Color(red: 0xD0 / 255, green: 0xBC / 255, blue: 0xFF / 255)
    static let purpleGrey80 = Color(red: 0xCC / 255, green: 0xC2 / 255, blue: 0xDC / 255)
    static let pink80 = Color(red: 0xEF / 255, green: 0xB8 / 255, blue: 0xC8 / 255)

    static let purple40 = Color(red: 0x66 / 255, green: 0x50 / 255, blue: 0xA4 / 255)
    static let purpleGrey40 = Color(red: 0x62 / 255, green: 0x5B / 255, blue: 0x71 / 255)
    static let pink40 = Color(red: 0x7D / 255, green: 0x52 / 255, blue: 0x60 / 255)

    // Primitive palette scale (see THEME_COLORS.md). Mirrors Android Color.kt.
    static let purple950 = Color(hex: 0x282237)
    static let purple900 = Color(hex: 0x2C263A)
    static let purple800 = Color(hex: 0x483B52)
    static let purple700 = Color(hex: 0x494357)

    static let yellow100 = Color(hex: 0xEBF59F)
    static let lavender200 = Color(hex: 0xC5BFCF)
    static let gray200 = Color(hex: 0xDDDCDF)
    static let mint100 = Color(hex: 0xDEE9E9)
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
