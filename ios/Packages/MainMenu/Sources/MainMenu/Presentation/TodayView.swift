//
//  TodayView.swift
//  MainMenu
//

import Design
import Summary
import SwiftUI

/// The Today destination: a large top-left heading over the shared summary card
/// row (nutrition summary, steps and active minutes).
///
/// The splash-style background is drawn by the app shell behind the content,
/// so this view only paints content.
///
/// Mirrors the Android `TodayScreen`.
@MainActor
public struct TodayView: View {
    private static let horizontalPadding: CGFloat = 24
    private static let topPadding: CGFloat = 8
    private static let cardSpacing: CGFloat = 24
    private static let cardMinHeightFraction: CGFloat = 0.30

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: Self.cardSpacing) {
                Text(TodayTokens.title)
                    .font(LevelaTypography.displaySmall)
                    .foregroundStyle(Color.navy900)
                    .accessibilityIdentifier(TodayTokens.screenTag)

                SummaryCards(minHeight: proxy.size.height * Self.cardMinHeightFraction)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.top, Self.topPadding)
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

        TodayView()
    }
    .levelaTheme()
}
