//
//  StepsCard.swift
//  Today
//

import Design
import SwiftUI

/// Mock step summary for the Today card.
///
/// Shaped like the future model, so only the data source has to change when
/// real step tracking lands.
struct StepsSummary {
    let label = "Steps"
    let total = "82,641"
    let distanceKm = 23
}

/// The step summary: the label, the day's step count and the distance it
/// corresponds to. The card fills the space it is given, so the three lines
/// spread out instead of crowding the top of the card.
struct StepsCard: View {
    let summary: StepsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(summary.label)
                .font(LevelaTypography.labelMedium)
                .foregroundStyle(Color.gray500)
                .lineLimit(1)

            Spacer(minLength: 4)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(summary.total)
                    .font(LevelaFontFamily.poppins.font(.semibold, size: 26, relativeTo: .title2))
                    .foregroundStyle(Color.navy900)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(" steps")
                    .font(LevelaTypography.labelSmall)
                    .foregroundStyle(Color.gray400)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text("≈ \(summary.distanceKm) km walked")
                .font(LevelaTypography.labelSmall)
                .foregroundStyle(Color.gray400)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

        StepsCard(summary: StepsSummary())
            .frame(width: 166, height: 122)
            .todayCard()
    }
    .levelaTheme()
}
