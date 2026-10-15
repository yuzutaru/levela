import Design
import SwiftUI

/// A two-option pill toggle (e.g. `lb` / `kg`). The selected option is filled
/// with the primary (navy) colour; the track uses the surface-variant grey.
public struct UnitToggle: View {
    private let units: [String]
    private let selected: String
    private let onSelect: (String) -> Void

    public init(units: [String], selected: String, onSelect: @escaping (String) -> Void) {
        self.units = units
        self.selected = selected
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(units, id: \.self) { unit in
                let isSelected = unit == selected
                // A Button (not a tap gesture) so the option is reachable by
                // VoiceOver and by the UI tests.
                Button {
                    onSelect(unit)
                } label: {
                    Text(unit)
                        .font(LevelaTypography.labelMedium)
                        .foregroundStyle(
                            isSelected ? OnboardingTokens.toggleSelectedText : OnboardingTokens.toggleUnselectedText
                        )
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            isSelected ? OnboardingTokens.toggleSelectedBackground : Color.clear,
                            in: Capsule()
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(OnboardingTokens.toggleTrack, in: Capsule())
    }
}
