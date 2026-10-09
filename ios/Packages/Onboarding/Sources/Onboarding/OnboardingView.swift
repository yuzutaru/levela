import Design
import SwiftUI

/// The Levela post-guest onboarding flow (weight, height).
///
/// Shown after the user taps **Continue as a guest** on the splash. Two steps,
/// each with a draggable ruler picker and a unit toggle; the last step reports
/// completion through `onFinished`. Mirrors the Android `OnboardingView`.
@MainActor
public struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    private let onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        VStack(spacing: 0) {
            StepProgress(current: viewModel.stepIndex, count: viewModel.stepCount)
                .padding(.top, 20)

            Text(title)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            unitToggle
                .padding(.top, 20)

            valueCard
                .padding(.top, 28)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                BackButton(action: viewModel.back)
                NextButton(label: OnboardingTokens.next) {
                    if viewModel.isLastStep {
                        onFinished()
                    } else {
                        viewModel.next()
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingTokens.background)
    }

    private var title: String {
        switch viewModel.step {
        case .weight: OnboardingTokens.weightTitle
        case .height: OnboardingTokens.heightTitle
        }
    }

    @ViewBuilder
    private var unitToggle: some View {
        switch viewModel.step {
        case .weight:
            UnitToggle(
                units: OnboardingTokens.weightUnits,
                selected: viewModel.weightUnit,
                onSelect: viewModel.selectWeightUnit
            )
        case .height:
            UnitToggle(
                units: OnboardingTokens.heightUnits,
                selected: viewModel.heightUnit,
                onSelect: viewModel.selectHeightUnit
            )
        }
    }

    @ViewBuilder
    private var valueCard: some View {
        switch viewModel.step {
        case .weight:
            ValueCard(
                value: viewModel.weightDisplay,
                unit: viewModel.weightUnit,
                scale: Self.weightScale(viewModel.weightUnit),
                background: OnboardingTokens.cardWeight,
                accent: OnboardingTokens.cardWeightAccent,
                onValueChange: viewModel.setWeightDisplay
            )
        case .height:
            ValueCard(
                value: viewModel.heightDisplay,
                unit: viewModel.heightUnit,
                scale: Self.heightScale(viewModel.heightUnit),
                background: OnboardingTokens.cardHeight,
                accent: OnboardingTokens.cardHeightAccent,
                onValueChange: viewModel.setHeightDisplay
            )
        }
    }

    /// The tick scale for the weight card, in the currently displayed unit.
    static func weightScale(_ unit: String) -> Scale {
        switch unit {
        case "lb": Scale(start: OnboardingTokens.weightLbMin, end: OnboardingTokens.weightLbMax, step: OnboardingTokens.weightLbStep)
        default: Scale(start: OnboardingTokens.weightKgMin, end: OnboardingTokens.weightKgMax, step: OnboardingTokens.weightKgStep)
        }
    }

    /// The tick scale for the height card, in the currently displayed unit.
    static func heightScale(_ unit: String) -> Scale {
        switch unit {
        case "inches": Scale(start: OnboardingTokens.heightInMin, end: OnboardingTokens.heightInMax, step: OnboardingTokens.heightInStep)
        default: Scale(start: OnboardingTokens.heightCmMin, end: OnboardingTokens.heightCmMax, step: OnboardingTokens.heightCmStep)
        }
    }
}

/// The tick scale for a value card, in the currently displayed unit.
struct Scale {
    let start: Int
    let end: Int
    let step: Int
}

private struct ValueCard: View {
    let value: Int
    let unit: String
    let scale: Scale
    let background: Color
    let accent: Color
    let onValueChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("\(value)")
                .font(LevelaTypography.displayMedium.bold())
                .foregroundStyle(OnboardingTokens.value)

            RulerPicker(
                value: value,
                rangeStart: scale.start,
                rangeEnd: scale.end,
                step: scale.step,
                accentColor: accent,
                onValueChange: onValueChange
            )
            .padding(.top, 6)

            Text(unit)
                .font(LevelaTypography.labelMedium)
                .foregroundStyle(OnboardingTokens.rulerLabel)
                .padding(.top, 2)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(background, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        // Reset the ruler scroll when the unit (and therefore the scale) changes.
        .id(unit)
    }
}

private struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(OnboardingTokens.title)
                .frame(width: 56, height: 56)
                .background(OnboardingTokens.background, in: Circle())
                .overlay(Circle().stroke(Color.gray200, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct NextButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(label)
                    .font(LevelaTypography.labelLarge)

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
            }
            .foregroundStyle(OnboardingTokens.nextText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(OnboardingTokens.nextBackground, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
        .levelaTheme()
}
