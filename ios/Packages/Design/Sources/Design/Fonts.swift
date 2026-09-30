import CoreText
import SwiftUI

/// Font families bundled with the design system.
/// Mirrors the families defined in Android `design/.../Font.kt`.
public enum LevelaFontFamily: Sendable {
    /// Used for headings (display/headline/title).
    case poppins
    /// Used for body text and labels.
    case inter
    /// Available for ad-hoc use.
    case plusJakartaSans
    /// Available for ad-hoc use.
    case urbanist

    /// The PostScript family prefix for each bundled typeface.
    ///
    /// Note: the bundled Inter files ship as the 24pt optical size, so their
    /// PostScript names are `Inter24pt-*` rather than `Inter-*`.
    fileprivate var postScriptPrefix: String {
        switch self {
        case .poppins: "Poppins"
        case .inter: "Inter24pt"
        case .plusJakartaSans: "PlusJakartaSans"
        case .urbanist: "Urbanist"
        }
    }

    /// Returns a `Font` for this family at the given weight and size,
    /// scaling with Dynamic Type relative to `style`.
    public func font(
        _ weight: LevelaFontWeight,
        size: CGFloat,
        relativeTo style: Font.TextStyle = .body
    ) -> Font {
        Font.custom("\(postScriptPrefix)-\(weight.postScriptSuffix)", size: size, relativeTo: style)
    }
}

/// The four weights bundled for every family.
public enum LevelaFontWeight: Sendable {
    case regular
    case medium
    case semibold
    case bold

    fileprivate var postScriptSuffix: String {
        switch self {
        case .regular: "Regular"
        case .medium: "Medium"
        case .semibold: "SemiBold"
        case .bold: "Bold"
        }
    }
}

/// Registers the fonts bundled inside this package.
///
/// Fonts that live in a Swift package resource bundle cannot be discovered through
/// the app's `UIAppFonts` Info.plist key, so they are registered with CoreText at
/// launch instead. Call ``registerAll()`` once, early in the app lifecycle.
public enum LevelaFonts {
    private static let fileNames = [
        "poppins_regular", "poppins_medium", "poppins_semibold", "poppins_bold",
        "inter_regular", "inter_medium", "inter_semibold", "inter_bold",
        "plus_jakarta_sans_regular", "plus_jakarta_sans_medium",
        "plus_jakarta_sans_semibold", "plus_jakarta_sans_bold",
        "urbanist_regular", "urbanist_medium", "urbanist_semibold", "urbanist_bold",
    ]

    private static var didRegister = false

    /// Registers every bundled font with CoreText. Safe to call more than once.
    public static func registerAll() {
        guard !didRegister else { return }
        didRegister = true

        for name in fileNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
