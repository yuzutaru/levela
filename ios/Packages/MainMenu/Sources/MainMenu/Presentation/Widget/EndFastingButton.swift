//
//  EndFastingButton.swift
//  Nutrition
//

import Design
import SwiftUI

/// The full-width "End Fasting" action. Visual-only for now.
public struct EndFastingButton: View {
    public let label: String

    public init(label: String = "End Fasting") {
        self.label = label
    }

    public var body: some View {
        Text(label)
            .font(LevelaTypography.titleMedium)
            .foregroundStyle(Color.gray500)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.gray200)
            .clipShape(Capsule())
    }
}

#Preview {
    EndFastingButton()
        .padding(24)
        .levelaTheme()
}
