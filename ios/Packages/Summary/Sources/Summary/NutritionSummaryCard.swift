//
//  NutritionSummaryCard.swift
//  Summary
//

import Design
import SwiftUI

/// Mock nutrition summary for the Today card. Shaped like the future model so
/// only the data source has to change when real tracking lands.
public struct NutritionSummary {
    public let dayLabel: String
    public let consumedCalories: String
    public let dailyCalories: String
    public let percentComplete: Int
    public let deltaPercent: Int
    public let macros: [MacroSummary]

    public init(
        dayLabel: String = "Day 8",
        consumedCalories: String = "1,320",
        dailyCalories: String = "2,300",
        percentComplete: Int = 64,
        deltaPercent: Int = 3,
        macros: [MacroSummary] = [
            MacroSummary(label: "Carbs", consumed: 112, daily: 240, color: .orange500),
            MacroSummary(label: "Proteins", consumed: 48, daily: 140, color: .pink500),
            MacroSummary(label: "Fats", consumed: 32, daily: 110, color: .teal500),
        ]
    ) {
        self.dayLabel = dayLabel
        self.consumedCalories = consumedCalories
        self.dailyCalories = dailyCalories
        self.percentComplete = percentComplete
        self.deltaPercent = deltaPercent
        self.macros = macros
    }
}

public struct MacroSummary {
    public let label: String
    public let consumed: Int
    public let daily: Int
    public let color: Color

    public init(label: String, consumed: Int, daily: Int, color: Color) {
        self.label = label
        self.consumed = consumed
        self.daily = daily
        self.color = color
    }
}

/// How the card arranges its content.
public enum NutritionSummaryLayout {
    /// The original short stack, for the Today destination's half-width card.
    case stacked

    /// The wide row — ring on the left, per-macro detail on the right.
    case wide
}

/// The nutrition summary card.
///
/// `layout` picks the arrangement: `.stacked` (the default) keeps the original
/// short stack for the Today destination's half-width card; `.wide` is the
/// reference design for the Nutrition destination's full-width card — a calorie
/// header, then the ring on the left with the per-macro detail (vertical colour
/// bar + consumed / daily weight) on the right. Both layouts share the calorie
/// header (flame icon + values).
public struct NutritionSummaryCard: View {
    public let summary: NutritionSummary
    private let layout: NutritionSummaryLayout

    public init(
        summary: NutritionSummary,
        layout: NutritionSummaryLayout = .stacked
    ) {
        self.summary = summary
        self.layout = layout
    }

    public var body: some View {
        switch layout {
        case .stacked: stacked
        case .wide: wide
        }
    }

    /// The original short stack (Today's half-width card): header, the wide
    /// centred ring, then the per-macro rows below.
    private var stacked: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            NutritionRing(summary: summary)
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

    /// The wide row (Nutrition's full-width card, the reference design): a
    /// calorie header, then the ring on the left and the per-macro detail on
    /// the right.
    private var wide: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            HStack(spacing: 16) {
                NutritionRing(summary: summary, diameter: 156)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(summary.macros, id: \.label) { macro in
                        MacroDetail(macro: macro)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

            calorieText
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private var calorieText: some View {
        HStack(spacing: 4) {
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
}

// MARK: - Macro row (stacked layout)

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

// MARK: - Macro detail (wide layout)

private struct MacroDetail: View {
    let macro: MacroSummary

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(macro.color)
                .frame(width: 3, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(macro.label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(macro.consumed)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.navy900)
                        .lineLimit(1)
                    Text(" / \(macro.daily)g")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.gray500)
                        .lineLimit(1)
                }
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

        NutritionSummaryCard(summary: NutritionSummary())
            .frame(width: 393 * 0.50)
            .frame(minHeight: 852 * 0.30, alignment: .topLeading)
            .summaryCard()
    }
    .levelaTheme()
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

        NutritionSummaryCard(
            summary: NutritionSummary(
                consumedCalories: "1.320",
                dailyCalories: "2300"
            ),
            layout: .wide
        )
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .summaryCard()
    }
    .levelaTheme()
}
