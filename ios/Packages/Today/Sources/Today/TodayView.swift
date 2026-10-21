//
//  TodayView.swift
//  Today
//

import Design
import SwiftUI

/// The Today destination: a large top-left heading over a row of cards. The
/// nutrition summary card takes the left half; the right half holds two
/// placeholder cards stacked vertically, each taking half of the nutrition
/// card's height. The row grows with the nutrition card's content but never
/// drops below 30% of the available height.
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
    private static let cardGap: CGFloat = 12
    private static let cardCorner: CGFloat = 28
    private static let cardMinHeightFraction: CGFloat = 0.30

    private let summary = NutritionSummary()

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: Self.cardSpacing) {
                Text(TodayTokens.title)
                    .font(LevelaTypography.displaySmall)
                    .foregroundStyle(Color.navy900)
                    .accessibilityIdentifier(TodayTokens.screenTag)

                cardRow(minHeight: proxy.size.height * Self.cardMinHeightFraction)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.top, Self.topPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// The nutrition summary card on the left half and the two stacked
    /// placeholder cards on the right half.
    ///
    /// The row takes the height of the nutrition card (`fixedSize` keeps the
    /// flexible right column from stretching the row to the whole screen), so
    /// each placeholder card fills half of the nutrition card's height.
    private func cardRow(minHeight: CGFloat) -> some View {
        HStack(alignment: .top, spacing: Self.cardGap) {
            NutritionSummaryCard(summary: summary)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .todayCard(cornerRadius: Self.cardCorner)

            VStack(spacing: Self.cardGap) {
                TodayPlaceholderCard()
                TodayPlaceholderCard()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .fixedSize(horizontal: false, vertical: true)
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
