//
//  ActiveMinutesCard.swift
//  MainMenu
//

import Design
import SwiftUI

/// Mock active minutes for the Today card.
///
/// Shaped like the future model, so only the data source has to change when
/// real activity tracking lands.
struct ActiveMinutesSummary {
    let label = "Active Minutes"
    let total = "558"
    let averagePerDay = 80
}

/// The active minutes summary: the label, the day's active minutes and the
/// daily average they are measured against. The card fills the space it is
/// given, so the three lines spread out instead of crowding the top of the
/// card.
struct ActiveMinutesCard: View {
    let summary: ActiveMinutesSummary

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

                Text(" min")
                    .font(LevelaTypography.labelSmall)
                    .foregroundStyle(Color.gray400)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text("Avg: \(summary.averagePerDay) min/day")
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

        ActiveMinutesCard(summary: ActiveMinutesSummary())
            .frame(width: 166, height: 122)
            .todayCard()
    }
    .levelaTheme()
}
