//
//  SummaryCards.swift
//  Summary
//

import SwiftUI

/// The dashboard's summary row: the nutrition summary card on the left half and,
/// on the right half, the step summary card over the active minutes card.
///
/// The row takes the height of the nutrition card (`fixedSize` keeps the
/// flexible right column from stretching the row), so each card fills half of
/// the nutrition card's height. Shared by the Today and Nutrition destinations.
public struct SummaryCards: View {
    private static let cardGap: CGFloat = 12

    private let minHeight: CGFloat

    public init(minHeight: CGFloat) {
        self.minHeight = minHeight
    }

    public var body: some View {
        HStack(alignment: .top, spacing: Self.cardGap) {
            NutritionSummaryCard(summary: NutritionSummary())
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .summaryCard()

            VStack(spacing: Self.cardGap) {
                StepsCard(summary: StepsSummary())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .summaryCard()
                ActiveMinutesCard(summary: ActiveMinutesSummary())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .summaryCard()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
