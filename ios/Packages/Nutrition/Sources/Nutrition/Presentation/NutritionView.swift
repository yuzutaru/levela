//
//  NutritionView.swift
//  Nutrition
//

import Design
import Summary
import SwiftUI

/// The Nutrition destination: a large top-left heading, the shared summary card
/// row (the same nutrition, steps and active-minutes cards as Today) and, below
/// it, the fasting view — the phase banner, the fasting ring, the start/end
/// times and the end-fasting action.
///
/// The screen scrolls: the fasting view sits below the fold of the summary
/// cards. The splash-style background is drawn by the app shell behind the
/// content.
///
/// Mirrors the Android `NutritionScreen`.
@MainActor
public struct NutritionView: View {
    private static let horizontalPadding: CGFloat = 24
    private static let topPadding: CGFloat = 8
    private static let cardSpacing: CGFloat = 24
    private static let bottomPadding: CGFloat = 24
    private static let cardMinHeightFraction: CGFloat = 0.30

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Self.cardSpacing) {
                    Text(NutritionTokens.title)
                        .font(LevelaTypography.displaySmall)
                        .foregroundStyle(Color.navy900)
                        .accessibilityIdentifier(NutritionTokens.screenTag)

                    SummaryCards(minHeight: proxy.size.height * Self.cardMinHeightFraction)

                    FastingSection()
                }
                .padding(.horizontal, Self.horizontalPadding)
                .padding(.top, Self.topPadding)
                .padding(.bottom, Self.bottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct FastingSection: View {
    var body: some View {
        VStack(spacing: 16) {
            PhaseBanner()
            FastingRing()
            FastingTimes()
            EndFastingButton()
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.white, .lightBlue100],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        RadialGradient(
            colors: [.lightBlue300.opacity(0.55), .clear],
            center: UnitPoint(x: 0.5, y: -0.08),
            startRadius: 0,
            endRadius: 460
        )
        .ignoresSafeArea()

        NutritionView()
    }
    .levelaTheme()
}
