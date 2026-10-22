//
//  TodayView.swift
//  MainMenu
//

import Design
import Summary
import SwiftUI

/// The Today destination: a large top-left heading over the shared summary card
/// row (nutrition summary, steps and active minutes) and, below it, the fasting
/// tracker card — the phase banner, the fasting ring, the start/end times and
/// the end-fasting action, inside the same card chrome as the summary row.
///
/// The screen scrolls: the fasting view sits below the fold of the summary
/// cards. The splash-style background is drawn by the app shell behind the
/// content, so this view only paints content.
///
/// Mirrors the Android `TodayScreen`.
@MainActor
public struct TodayView: View {
    private static let cardMinHeightFraction: CGFloat = 0.30

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: MenuPageLayout.contentSpacing) {
                    MenuPageTitle(
                        text: TodayTokens.title,
                        screenTag: TodayTokens.screenTag
                    )

                    SummaryCards(minHeight: proxy.size.height * Self.cardMinHeightFraction)

                    FastingSection()
                }
                .padding(.horizontal, MenuPageLayout.horizontalPadding)
                .padding(.top, MenuPageLayout.topPadding)
                .padding(.bottom, MenuPageLayout.bottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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

        TodayView()
    }
    .levelaTheme()
}
