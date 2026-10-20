//
//  TodayView.swift
//  Levela
//

import Design
import Splash
import SwiftUI

/// Mock nutrition summary for the Today card. Shaped like the future model so
/// only the data source has to change when real tracking lands.
private struct NutritionSummary {
    let dayLabel = "Day 8"
    let consumedCalories = "1,320"
    let dailyCalories = "2,300"
    let percentComplete = 64
    let deltaPercent = 3
    let macros: [MacroSummary] = [
        MacroSummary(label: "Carbs", consumed: 112, daily: 240, color: .orange500),
        MacroSummary(label: "Proteins", consumed: 48, daily: 140, color: .pink500),
        MacroSummary(label: "Fats", consumed: 32, daily: 110, color: .teal500),
    ]
}

private struct MacroSummary {
    let label: String
    let consumed: Int
    let daily: Int
    let color: Color
}

/// The Today destination: a large top-left heading over a half-width nutrition
/// summary card. The card grows with its content but never drops below 30% of
/// the available height, and the right half of the screen stays empty.
///
/// The splash-style background lives in `MainMenuView`, so this view only
/// paints content.
struct TodayView: View {
    private static let title = "Overview"
    private static let horizontalPadding: CGFloat = 24
    private static let topPadding: CGFloat = 8
    private static let cardSpacing: CGFloat = 24
    private static let cardCorner: CGFloat = 28
    private static let cardWidthFraction: CGFloat = 0.50
    private static let cardMinHeightFraction: CGFloat = 0.30

    private let summary = NutritionSummary()

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: Self.cardSpacing) {
                Text(Self.title)
                    .font(LevelaTypography.displaySmall)
                    .foregroundStyle(SplashTokens.title)
                    .accessibilityIdentifier(MainMenuAccessibility.today)

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

// MARK: - Nutrition summary card

private struct NutritionSummaryCard: View {
    private static let ringDiameter: CGFloat = 92
    private static let ringStroke: CGFloat = 9

    let summary: NutritionSummary

    private var arcs: [RingArc] {
        let total = max(summary.macros.reduce(0) { $0 + $1.consumed }, 1)
        var start: CGFloat = 0
        var result: [RingArc] = []
        for macro in summary.macros {
            let end = start + CGFloat(macro.consumed) / CGFloat(total)
            result.append(RingArc(start: start, end: end, color: macro.color))
            start = end
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ring
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(summary.macros, id: \.label) { macro in
                    MacroRow(macro: macro)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.orange500)
            Text(summary.consumedCalories)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.navy900)
            Text("/ \(summary.dailyCalories) kcal")
                .font(.system(size: 11))
                .foregroundStyle(Color.gray500)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    /// One arc per macro, sized by that macro's share of the total grams
    /// consumed, so the three arcs close the circle.
    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.gray200, lineWidth: Self.ringStroke)

            ForEach(Array(arcs.enumerated()), id: \.offset) { _, arc in
                Circle()
                    .trim(from: arc.start, to: arc.end)
                    .stroke(arc.color, style: StrokeStyle(lineWidth: Self.ringStroke, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 1) {
                Text(summary.dayLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray500)
                Text("\(summary.percentComplete)%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.navy900)
                Text("+\(summary.deltaPercent)%")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.green500)
            }
        }
        .frame(width: Self.ringDiameter, height: Self.ringDiameter)
    }
}

private struct RingArc {
    let start: CGFloat
    let end: CGFloat
    let color: Color
}

// MARK: - Macro row

private struct MacroRow: View {
    let macro: MacroSummary

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(macro.color)
                .frame(width: 16, height: 3)

            Text(macro.label)
                .font(.system(size: 11))
                .foregroundStyle(Color.gray500)
                .padding(.leading, 6)

            Spacer(minLength: 8)

            Text("\(macro.consumed) / \(macro.daily)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.navy900)
            Text(" g")
                .font(.system(size: 10))
                .foregroundStyle(Color.gray400)
        }
        .lineLimit(1)
    }
}

#Preview {
    ZStack {
        MainMenuBackground()
        TodayView()
    }
    .levelaTheme()
}
