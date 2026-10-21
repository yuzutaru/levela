//
//  SummaryCard.swift
//  Summary
//

import SwiftUI

/// The shared card chrome for the dashboard summary cards: a white surface, the
/// rounded corner and the soft shadow.
///
/// Mirrors the Android `summaryCard()` modifier. Shared by the Today and
/// Nutrition destinations.
public struct SummaryCardModifier: ViewModifier {
    public let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
    }
}

public extension View {
    /// Applies the shared summary card chrome.
    func summaryCard(cornerRadius: CGFloat = 28) -> some View {
        modifier(SummaryCardModifier(cornerRadius: cornerRadius))
    }
}
