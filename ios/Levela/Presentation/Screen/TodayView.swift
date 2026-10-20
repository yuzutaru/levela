//
//  TodayView.swift
//  Levela
//

import Design
import Splash
import SwiftUI

/// The Today destination: a large top-left heading over one empty card.
///
/// The card is intentionally blank — it is the shell for the workout summary
/// that lands later. The menu's splash-style background lives in
/// `MainMenuView`, so this view only paints content.
struct TodayView: View {
    private static let title = "Overview"
    private static let horizontalPadding: CGFloat = 24
    private static let topPadding: CGFloat = 8
    private static let cardSpacing: CGFloat = 24
    private static let cardCorner: CGFloat = 28
    private static let cardWidthFraction: CGFloat = 0.50
    private static let cardHeightFraction: CGFloat = 0.30

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: Self.cardSpacing) {
                Text(Self.title)
                    .font(LevelaTypography.displaySmall)
                    .foregroundStyle(SplashTokens.title)
                    .accessibilityIdentifier(MainMenuAccessibility.today)

                RoundedRectangle(cornerRadius: Self.cardCorner, style: .continuous)
                    .fill(.white)
                    .frame(
                        width: proxy.size.width * Self.cardWidthFraction,
                        height: proxy.size.height * Self.cardHeightFraction
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)

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
        MainMenuBackground()
        TodayView()
    }
    .levelaTheme()
}
