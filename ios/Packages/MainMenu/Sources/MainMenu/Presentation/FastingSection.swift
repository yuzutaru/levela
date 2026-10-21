//
//  FastingSection.swift
//  MainMenu
//

import Design
import Summary
import SwiftUI

/// The fasting view: the phase banner, the fasting ring, the start/end times and
/// the end-fasting action.
///
/// Lives below the summary cards on the Today screen, inside the same white card
/// chrome the summary row uses (`summaryCard()`); the shared splash-style
/// background is drawn by the app shell behind the content.
///
/// Mirrors the Android `FastingSection`.
public struct FastingSection: View {
    private static let cardPadding: CGFloat = 20
    private static let sectionSpacing: CGFloat = 16

    public init() {}

    public var body: some View {
        VStack(spacing: Self.sectionSpacing) {
            PhaseBanner()
            FastingRing()
            FastingTimes()
            EndFastingButton()
        }
        .padding(Self.cardPadding)
        .frame(maxWidth: .infinity)
        .summaryCard()
    }
}

#Preview {
    ZStack {
        Color.lightBlue100
            .ignoresSafeArea()

        FastingSection()
            .padding(24)
    }
    .levelaTheme()
}
