import Design
import SwiftUI

/// The Levela post-guest onboarding flow (welcome, weight, height).
///
/// Shown after the user taps **Continue as a guest** on the splash. Three steps:
/// a welcome intro, then weight and height — the latter pair each using a
/// draggable ruler picker and a unit toggle. The last step reports completion
/// through `onFinished`. Mirrors the Android `OnboardingView`.
@MainActor
public struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    /// 1 when moving forward through the steps, -1 when going back; drives the
    /// slide direction of the step transition.
    @State private var direction: Int = 1
    private let onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        VStack(spacing: 0) {
            StepProgress(current: viewModel.stepIndex, count: viewModel.stepCount)
                .padding(.top, 20)

            ZStack {
                Group {
                    if viewModel.step == .welcome {
                        welcomeStep
                    } else {
                        valueStep
                    }
                }
                // A new id per step so the transition fires even between weight
                // and height, which share the same `valueStep` view.
                .id(viewModel.step)
                .transition(stepTransition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingTokens.background)
    }

    /// Push forward (next): the new step enters from the right, the old one
    /// leaves to the left. Going back mirrors it: in from the left, out to the
    /// right.
    private var stepTransition: AnyTransition {
        direction > 0
            ? .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
            : .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
    }

    /// Advances a step, sliding forward. `direction` is committed before the
    /// animated step change so the transition reads the correct direction.
    private func goNext() {
        direction = 1
        withAnimation(.easeInOut(duration: 0.3)) { viewModel.next() }
    }

    /// Returns a step, sliding back (previous step in from the left, current one
    /// out to the right). `direction` is committed before the animated change.
    private func goBack() {
        direction = -1
        withAnimation(.easeInOut(duration: 0.3)) { viewModel.back() }
    }

    /// The intro step: headline + subtitle + hero illustration + a primary "Let's start" button.
    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.welcomeTitle)
                .font(LevelaTypography.headlineLarge.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 48)

            Text(OnboardingTokens.welcomeSubtitle)
                .font(LevelaTypography.bodyLarge)
                .foregroundStyle(OnboardingTokens.subtitle)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Image("WelcomeIllustration", bundle: .module)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: CGFloat(OnboardingTokens.welcomeIllustrationCorner),
                        style: .continuous
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 24)

            NextButton(label: OnboardingTokens.start, showChevrons: false) {
                goNext()
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    /// A weight or height step: title + unit toggle + value card + back / Next.
    private var valueStep: some View {
        VStack(spacing: 0) {
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
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.next) {
                    if viewModel.isLastStep {
                        onFinished()
                    } else {
                        goNext()
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    private var title: String {
        switch viewModel.step {
        case .welcome: OnboardingTokens.welcomeTitle
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
        default:
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
                displayText: "\(viewModel.weightDisplay)",
                unit: viewModel.weightUnit,
                scale: Self.weightScale(viewModel.weightUnit),
                background: OnboardingTokens.cardWeight,
                accent: OnboardingTokens.cardWeightAccent,
                onValueChange: viewModel.setWeightDisplay
            )
        default:
            ValueCard(
                value: viewModel.heightDisplay,
                displayText: viewModel.heightDisplayText,
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
        case "cm": Scale(start: OnboardingTokens.heightCmMin, end: OnboardingTokens.heightCmMax, step: OnboardingTokens.heightCmStep)
        default: Scale(
            start: OnboardingTokens.heightInMin,
            end: OnboardingTokens.heightInMax,
            step: OnboardingTokens.heightInStep,
            // A label on every foot boundary (total inches), e.g. 60 → 5'0".
            majorEvery: 12,
            label: OnboardingViewModel.formatFtIn
        )
        }
    }
}

/// The tick scale for a value card, in the currently displayed unit.
struct Scale {
    let start: Int
    let end: Int
    let step: Int
    var majorEvery: Int = 10
    var label: (Int) -> String = { "\($0)" }
}

private struct ValueCard: View {
    let value: Int
    let displayText: String
    let unit: String
    let scale: Scale
    let background: Color
    let accent: Color
    let onValueChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(displayText)
                .font(LevelaTypography.displayMedium.bold())
                .foregroundStyle(OnboardingTokens.value)

            RulerPicker(
                value: value,
                rangeStart: scale.start,
                rangeEnd: scale.end,
                step: scale.step,
                majorEvery: scale.majorEvery,
                labelFormatter: scale.label,
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
    var showChevrons: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(label)
                    .font(LevelaTypography.labelLarge)

                if showChevrons {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
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
