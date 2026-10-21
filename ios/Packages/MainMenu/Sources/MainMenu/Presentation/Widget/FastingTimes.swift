//
//  FastingTimes.swift
//  Nutrition
//

import Design
import SwiftUI

/// The fast's start and end times, each with a small edit affordance. The values
/// are read-only for now — the mock does not wire an editor.
public struct FastingTimes: View {
    public let summary: FastingSummary

    public init(summary: FastingSummary = FastingSummary()) {
        self.summary = summary
    }

    public var body: some View {
        HStack(alignment: .top) {
            TimeColumn(label: "START", value: summary.startLabel, alignment: .leading)
            Spacer(minLength: 12)
            TimeColumn(label: "END", value: summary.endLabel, alignment: .trailing)
        }
    }
}

private struct TimeColumn: View {
    let label: String
    let value: String
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(label)
                .font(LevelaTypography.labelSmall)
                .foregroundStyle(Color.gray400)

            HStack(spacing: 6) {
                Text(value)
                    .font(LevelaTypography.titleMedium)
                    .foregroundStyle(Color.navy900)
                    .lineLimit(1)

                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.green500)
                    .frame(width: 28, height: 28)
                    .background(Color.green100)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    FastingTimes()
        .padding(24)
        .levelaTheme()
}
