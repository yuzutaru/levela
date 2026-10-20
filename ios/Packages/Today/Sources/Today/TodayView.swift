//
//  TodayView.swift
//  Today
//

import Design
import SwiftUI

/// The Today destination: a large top-left heading over a half-width nutrition
/// summary card. The card grows with its content but never drops below 30% of
/// the available height, and the right half of the screen stays empty.
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
    private static let cardCorner: CGFloat = 28
    private static let cardWidthFraction: CGFloat = 0.50
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

                NutritionSummaryCard(summary: summary)
                    .frame(width: proxy.size.width * Self.cardWidthFraction)
                    .frame(minHeight: proxy.size.height * Self.cardMinHeightFraction, alignment: .topLeading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: Self.cardCorner, style: .continuous))
                    .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
