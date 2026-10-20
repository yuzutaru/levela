//
//  NutritionSummaryCard.swift
//  Today
//

import Design
import SwiftUI

/// Mock nutrition summary for the Today card. Shaped like the future model so
/// only the data source has to change when real tracking lands.
struct NutritionSummary {
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

struct MacroSummary {
    let label: String
    let consumed: Int
    let daily: Int
    let color: Color
}

struct NutritionSummaryCard: View {
    let summary: NutritionSummary

    var body: some View {
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
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
    }
    .levelaTheme()
}
