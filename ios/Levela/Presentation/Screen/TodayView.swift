//
//  TodayView.swift
//  Levela
//

import Design
import Splash
import SwiftUI

/// The Today destination: a large top-left heading over a half-width nutrition
/// summary card that is content-driven (min 30% height, grows with content).
struct TodayView: View {
    private static let title = "Overview"
    private static let horizontalPadding: CGFloat = 24
    private static let topPadding: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 24) {
                Text(Self.title)
                    .font(LevelaTypography.displaySmall)
                    .foregroundStyle(SplashTokens.title)
                    .accessibilityIdentifier(MainMenuAccessibility.today)

                NutritionSummaryCard(proxySize: proxy.size)

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
    private static let cardCorner: CGFloat = 28
    private static let horizontalPadding: CGFloat = 16
    private static let rowHeight: CGFloat = 22
    private static let rowSpacing: CGFloat = 6
    private static let ringDiameter: CGFloat = 92
    private static let ringStroke: CGFloat = 9
    private static let centerFontSize: CGFloat = 24
    private static let deltaFontSize: CGFloat = 10
    private static let labelFontSize: CGFloat = 10
    private static let valueFontSize: CGFloat = 11

    // Mock data for Day 8
    private static let consumedCalories = 1_320
    private static let dailyCalories = 2_300
    private static let percentComplete = 64
    private static let delta = 3
    private static let carbsConsumed = 112
    private static let carbsDaily = 240
    private static let proteinsConsumed = 48
    private static let proteinsDaily = 140
    private static let fatsConsumed = 32
    private static let fatsDaily = 110

    private var proxySize: CGSize

    init(proxySize: CGSize) {
        self.proxySize = proxySize
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NutritionSummaryCard.rowSpacing) {
            // Header: flame + calories
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.navy900)
                Text("\(NutritionSummaryCard.consumedCalories.formatted()) / \(NutritionSummaryCard.dailyCalories.formatted())")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.navy900)
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray500)
            }

            // Ring
            ZStack {
                // Track
                Circle()
                    .stroke(Color.gray200, lineWidth: NutritionSummaryCard.ringStroke)
                    .frame(width: NutritionSummaryCard.ringDiameter, height: NutritionSummaryCard.ringDiameter)

                // Arcs — normalized by grams consumed
                // Carbs: 112/240 ≈ 58%; Proteins: 48/140 ≈ 25%; Fats: 32/110 ≈ 17%
                // We draw three arcs that sum to 360°: start from -90° (12 o'clock)
                Circle()
                    .trim(from: 0, to: 0.58)
                    .stroke(Color.orange500, style: StrokeStyle(lineWidth: NutritionSummaryCard.ringStroke, lineCap: .round))
                    .frame(width: NutritionSummaryCard.ringDiameter, height: NutritionSummaryCard.ringDiameter)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0.58, to: 0.58 + 0.25)
                    .stroke(Color.pink500, style: StrokeStyle(lineWidth: NutritionSummaryCard.ringStroke, lineCap: .round))
                    .frame(width: NutritionSummaryCard.ringDiameter, height: NutritionSummaryCard.ringDiameter)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: 0.58 + 0.25, to: 1.0)
                    .stroke(Color.teal500, style: StrokeStyle(lineWidth: NutritionSummaryCard.ringStroke, lineCap: .round))
                    .frame(width: NutritionSummaryCard.ringDiameter, height: NutritionSummaryCard.ringDiameter)
                    .rotationEffect(.degrees(-90))

                // Center: day + percent + delta
                VStack(alignment: .center, spacing: 2) {
                    Text("Day 8")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(.gray100)
                    Text("\(NutritionSummaryCard.percentComplete)%")
                        .font(.system(size: NutritionSummaryCard.centerFontSize, weight: .bold))
                        .foregroundStyle(.navy900)
                    HStack(spacing: 2) {
                        Text("+\(NutritionSummaryCard.delta)%")
                            .font(.system(size: NutritionSummaryCard.deltaFontSize, weight: .regular))
                            .foregroundStyle(.green500)
                        Text("vs yesterday")
                            .font(.system(size: 9))
                            .foregroundStyle(.gray400)
                    }
                }
            }

            // Macro rows
            HStack(spacing: 16) {
                MacroRow(
                    title: "Carbs",
                    consumed: NutritionSummaryCard.carbsConsumed,
                    daily: NutritionSummaryCard.carbsDaily,
                    barColor: .orange500,
                    valueColor: .navy900,
                    unit: "g"
                )
                MacroRow(
                    title: "Proteins",
                    consumed: NutritionSummaryCard.proteinsConsumed,
                    daily: NutritionSummaryCard.proteinsDaily,
                    barColor: .pink500,
                    valueColor: .navy900,
                    unit: "g"
                )
                MacroRow(
                    title: "Fats",
                    consumed: NutritionSummaryCard.fatsConsumed,
                    daily: NutritionSummaryCard.fatsDaily,
                    barColor: .teal500,
                    valueColor: .navy900,
                    unit: "g"
                )
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, NutritionSummaryCard.horizontalPadding)
    }
}

// MARK: - Macro row

private struct MacroRow: View {
    let title: String
    let consumed: Int
    let daily: Int
    let barColor: Color
    let valueColor: Color
    let unit: String

    private var consumedPercent: Double {
        guard daily > 0 else { return 0 }
        return Double(consumed) / Double(daily)
    }

    private var consumedValue: Int { consumed }
    private var dailyValue: Int { daily }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: 16, height: 3)
                Text(title)
                    .font(.system(size: NutritionSummaryCard.labelFontSize))
                    .foregroundStyle(.gray500)
            }
            HStack(spacing: 2) {
                Text("\(consumedValue.formatted()) / \(dailyValue.formatted())")
                    .font(.system(size: NutritionSummaryCard.valueFontSize, weight: .semibold))
                    .foregroundStyle(valueColor)
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundStyle(.gray400)
            }
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