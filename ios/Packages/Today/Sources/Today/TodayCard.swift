//
//  TodayCard.swift
//  Today
//

import SwiftUI

/// The shared card chrome for the Today dashboard: a white surface, the rounded
/// corner and the soft shadow.
///
/// Mirrors the Android `todayCard()` modifier.
struct TodayCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
    }
}

extension View {
    /// Applies the shared Today card chrome.
    func todayCard(cornerRadius: CGFloat = 28) -> some View {
        modifier(TodayCardModifier(cornerRadius: cornerRadius))
    }
}

/// An empty card, used for the placeholder card under the step summary on the
/// right of the Today dashboard. It carries the shared card chrome and no
/// content yet.
struct TodayPlaceholderCard: View {
    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .todayCard()
    }
}
