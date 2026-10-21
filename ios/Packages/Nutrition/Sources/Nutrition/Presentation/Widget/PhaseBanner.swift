//
//  PhaseBanner.swift
//  Nutrition
//

import Design
import SwiftUI

/// The phase notification shown above the fasting ring: a soft info banner that
/// announces the body's current fasting phase.
public struct PhaseBanner: View {
    public let summary: FastingSummary

    public init(summary: FastingSummary = FastingSummary()) {
        self.summary = summary
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundStyle(Color.blue500)

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.phaseTitle)
                    .font(LevelaTypography.titleMedium)
                    .foregroundStyle(Color.navy900)
                Text(summary.phaseSubtitle)
                    .font(LevelaTypography.bodySmall)
                    .foregroundStyle(Color.gray500)
            }

            Spacer(minLength: 8)

            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.gray400)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lightBlue100)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.lightBlue300, lineWidth: 1)
        )
    }
}

#Preview {
    PhaseBanner()
        .padding(24)
        .levelaTheme()
}
