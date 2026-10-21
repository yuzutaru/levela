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
