//
//  MenuPage.swift
//  MainMenu
//

import Design
import SwiftUI

/// The shared page chrome of the main-menu destinations: the page padding and
/// the large top-left heading.
///
/// Every destination titles itself the same way, so the heading treatment lives
/// here instead of being repeated per screen.
public enum MenuPageLayout {
    /// The page's horizontal padding.
    public static let horizontalPadding: CGFloat = 24

    /// The page's top padding, below the status bar.
    public static let topPadding: CGFloat = 8

    /// The page's bottom padding, above the tab bar.
    public static let bottomPadding: CGFloat = 24

    /// The spacing between the page title and the content below it.
    public static let contentSpacing: CGFloat = 24
}

/// The large top-left page title of a main-menu destination.
///
/// - Parameters:
///   - text: The title copy.
///   - screenTag: The stable accessibility identifier for the title.
public struct MenuPageTitle: View {
    /// The title copy.
    public let text: String

    /// The stable accessibility identifier for the title.
    public let screenTag: String

    public init(text: String, screenTag: String) {
        self.text = text
        self.screenTag = screenTag
    }

    public var body: some View {
        Text(text)
            .font(LevelaTypography.displaySmall)
            .foregroundStyle(Color.navy900)
            .accessibilityIdentifier(screenTag)
    }
}
