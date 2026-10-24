//
//  NutritionView.swift
//  MainMenu
//

import Design
import Summary
import SwiftUI

/// The Nutrition destination: a large top-left page title, like the Today
/// destination's "Overview" heading, over the page's content area.
///
/// The content is the full-width nutrition summary card for now — the rest of
/// the nutrition widgets land with the nutrition feature. The splash-style
/// background is drawn by the app shell behind the content, so this view only
/// paints content.
///
/// Mirrors the Android `NutritionScreen`.
@MainActor
public struct NutritionView: View {
    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MenuPageLayout.contentSpacing) {
                MenuPageTitle(
                    text: NutritionTokens.title,
                    screenTag: NutritionTokens.screenTag
                )

                NutritionSummaryCard(
                    summary: NutritionSummary(
                        consumedCalories: "1.320",
                        dailyCalories: "2300"
                    ),
                    layout: .wide
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .summaryCard()
            }
            .padding(.horizontal, MenuPageLayout.horizontalPadding)
            .padding(.top, MenuPageLayout.topPadding)
            .padding(.bottom, MenuPageLayout.bottomPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
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
