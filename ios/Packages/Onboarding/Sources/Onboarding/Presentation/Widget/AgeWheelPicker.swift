import Design
import SwiftUI

/// A vertical, snapping wheel used by the age step.
///
/// The selected age sits in the vertical centre in a solid primary card; the
/// neighbouring ages are progressively smaller and lighter, like a physical
/// wheel. Scrolling reports the age under the centre marker through
/// `onAgeChange`; tapping an age scrolls it to the centre.
public struct AgeWheelPicker: View {
    private let age: Int
    private let range: ClosedRange<Int>
    private let onAgeChange: (Int) -> Void

    /// The age currently under the centre marker. Seeded with `age` so the
    /// wheel opens on the selected value, then kept in step with the binding.
    @State private var selection: Int?

    public init(
        age: Int,
        range: ClosedRange<Int> = OnboardingTokens.ageMin...OnboardingTokens.ageMax,
        onAgeChange: @escaping (Int) -> Void
    ) {
        self.age = age
        self.range = range
        self.onAgeChange = onAgeChange
        _selection = State(initialValue: age)
    }

    private var rowHeight: CGFloat { CGFloat(OnboardingTokens.ageWheelRowHeight) }

    /// The visible height of the wheel: the selected row plus two faded rows
    /// above and below, matching the mockup.
    private var wheelHeight: CGFloat {
        rowHeight * CGFloat(OnboardingTokens.ageWheelVisibleRows)
    }

    /// Half the leftover height, so the first and last ages can still reach the
    /// centre.
    private var contentInset: CGFloat {
        rowHeight * CGFloat(OnboardingTokens.ageWheelVisibleRows - 1) / 2
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(Array(range), id: \.self) { value in
                        AgeWheelRow(
                            value: value,
                            distance: abs(value - age),
                            isSelected: value == age
                        )
                        .frame(height: rowHeight)
                        // The selected card is taller than a row, so it must draw
                        // above the neighbouring rows rather than under them.
                        .zIndex(value == age ? 1 : 0)
                        .id(value)
                        .contentShape(Rectangle())
                        .onTapGesture { select(value, proxy: proxy) }
                        // Only the rows inside the wheel's five-row window are
                        // visible; keep the off-screen ages out of the
                        // accessibility tree.
                        .accessibilityHidden(abs(value - age) > 2)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: wheelHeight)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection, anchor: .center)
            .scrollIndicators(.hidden)
            .contentMargins(.vertical, contentInset, for: .scrollContent)
            .onAppear {
                // `scrollPosition` tracks the wheel but does not move it on the
                // first layout, so centre the starting age explicitly.
                proxy.scrollTo(age, anchor: .center)
            }
            .onChange(of: selection) { _, newValue in
                guard let newValue, newValue != age, range.contains(newValue) else { return }
                onAgeChange(newValue)
            }
            .onChange(of: age) { _, newValue in
                guard selection != newValue else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    selection = newValue
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
            .sensoryFeedback(.selection, trigger: age)
        }
    }

    /// Scrolls a tapped age to the centre; the position change reports the new
    /// value through `onAgeChange`.
    private func select(_ value: Int, proxy: ScrollViewProxy) {
        guard value != age else { return }
        onAgeChange(value)
        withAnimation(.easeOut(duration: 0.2)) {
            selection = value
            proxy.scrollTo(value, anchor: .center)
        }
    }
}

/// One age in the wheel. The selected value is the large primary card; the
/// others shrink and fade with their distance from the centre.
private struct AgeWheelRow: View {
    let value: Int
    let distance: Int
    let isSelected: Bool

    private var font: Font {
        switch distance {
        case 0: LevelaTypography.displayLarge
        case 1: LevelaTypography.displaySmall
        case 2: LevelaTypography.headlineSmall
        default: LevelaTypography.titleSmall
        }
    }

    private var color: Color {
        switch distance {
        case 0: OnboardingTokens.ageWheelSelectedText
        case 1: OnboardingTokens.ageWheelText
        default: OnboardingTokens.ageWheelFadedText
        }
    }

    private var opacity: Double {
        switch distance {
        case 0, 1: 1
        case 2: 0.9
        default: 0.5
        }
    }

    var body: some View {
        ZStack {
            if isSelected {
                // A soft halo behind the solid card, so the selection reads as
                // raised without leaving the palette.
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(OnboardingTokens.ageWheelSelectedBackground.opacity(0.18))
                    .frame(width: 132, height: 124)

                RoundedRectangle(
                    cornerRadius: CGFloat(OnboardingTokens.ageWheelCorner),
                    style: .continuous
                )
                .fill(OnboardingTokens.ageWheelSelectedBackground)
                .frame(width: 120, height: 112)
            }

            Text("\(value)")
                .font(font)
                .foregroundStyle(color)
                .opacity(opacity)
                // Only the centred row answers the flow's value identifier, so
                // the UI tests always read the committed age.
                .accessibilityIdentifier(
                    isSelected
                        ? OnboardingAccessibility.value
                        : OnboardingAccessibility.age(value)
                )
                .accessibilityLabel("\(value)")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeOut(duration: 0.18), value: distance)
    }
}

#Preview("Age wheel") {
    AgeWheelPicker(age: OnboardingTokens.ageDefault) { _ in }
        .levelaTheme()
        .padding()
}
