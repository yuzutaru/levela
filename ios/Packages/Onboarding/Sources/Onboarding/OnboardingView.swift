import Design
import SwiftUI

/// The Levela post-guest onboarding flow (welcome, goal, profile, weight, height).
///
/// Shown after the user taps **Continue as a guest** on the splash. Five steps:
/// a welcome intro, a single-select goal step, a profile step (age + biological
/// sex), then weight and height — the latter pair each using a draggable ruler
/// picker and a unit toggle. The last step reports completion through
/// `onFinished`. Mirrors the Android `OnboardingView`.
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

    /// Opens the view on a specific step. Internal: for previews/tests.
    init(step: OnboardingStep, onFinished: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: OnboardingViewModel(step: step))
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
                    } else if viewModel.step == .goal {
                        goalStep
                    } else if viewModel.step == .profile {
                        profileStep
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

    /// The goal step: title + a scrollable list of single-select goal cards +
    /// back / Next. Next stays disabled until a goal is chosen.
    private var goalStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.goalTitle)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(OnboardingTokens.goals, id: \.title) { goal in
                        OptionCard(
                            title: goal.title,
                            subtitle: goal.subtitle,
                            isSelected: viewModel.goal == goal.title
                        ) {
                            viewModel.selectGoal(goal.title)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 4)
            }

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.next, enabled: viewModel.hasGoal) {
                    goNext()
                }
            }
            .padding(.bottom, 24)
        }
    }

    /// The profile step: title + an age ruler card + a list of single-select
    /// biological-sex cards + back / Next. Next stays disabled until a sex option
    /// is chosen (the age always has a default).
    private var profileStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.profileTitle)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text(OnboardingTokens.ageTitle)
                .font(LevelaTypography.titleMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)

            AgeCard(age: viewModel.age, onAgeChange: viewModel.setAge)
                .padding(.top, 12)

            Text(OnboardingTokens.sexTitle)
                .font(LevelaTypography.titleMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(OnboardingTokens.sexOptions, id: \.self) { option in
                        OptionCard(
                            title: option,
                            subtitle: nil,
                            isSelected: viewModel.sex == option
                        ) {
                            viewModel.selectSex(option)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 4)
            }

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.next, enabled: viewModel.hasSex) {
                    goNext()
                }
            }
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
        case .goal: OnboardingTokens.goalTitle
        case .profile: OnboardingTokens.profileTitle
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

/// The age ruler card: the value + a single `years` scale + a unit label.
private struct AgeCard: View {
    let age: Int
    let onAgeChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("\(age)")
                .font(LevelaTypography.displayMedium.bold())
                .foregroundStyle(OnboardingTokens.value)

            RulerPicker(
                value: age,
                rangeStart: OnboardingTokens.ageMin,
                rangeEnd: OnboardingTokens.ageMax,
                step: OnboardingTokens.ageStep,
                accentColor: OnboardingTokens.cardWeightAccent,
                onValueChange: onAgeChange
            )
            .padding(.top, 6)

            Text(OnboardingTokens.ageUnit)
                .font(LevelaTypography.labelMedium)
                .foregroundStyle(OnboardingTokens.rulerLabel)
                .padding(.top, 2)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(OnboardingTokens.cardWeight, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
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
    var enabled: Bool = true
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
            .foregroundStyle(enabled ? OnboardingTokens.nextText : OnboardingTokens.nextDisabledText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                enabled ? OnboardingTokens.nextBackground : OnboardingTokens.nextDisabledBackground,
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

/// A single-select option card: a status dot on the left, then a title and an
/// optional subtitle. Shared by the goal and profile steps.
private struct OptionCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(OnboardingTokens.goalCardCorner), style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                OptionDot(isSelected: isSelected)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LevelaTypography.titleMedium.bold())
                        .foregroundStyle(OnboardingTokens.title)

                    if let subtitle {
                        Text(subtitle)
                            .font(LevelaTypography.bodyMedium)
                            .foregroundStyle(OnboardingTokens.subtitle)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? OnboardingTokens.goalCardActive : OnboardingTokens.goalCardInactive,
                in: shape
            )
            .overlay(
                shape.stroke(
                    isSelected
                        ? OnboardingTokens.goalCardActiveBorder
                        : OnboardingTokens.goalCardInactiveBorder,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}

/// The option card's status dot: filled when selected, a ring when not.
private struct OptionDot: View {
    let isSelected: Bool

    var body: some View {
        Group {
            if isSelected {
                Circle().fill(OnboardingTokens.goalDotActive)
            } else {
                Circle().stroke(OnboardingTokens.goalDotInactive, lineWidth: 1.5)
            }
        }
        .frame(width: 14, height: 14)
    }
}

#Preview("Welcome") {
    OnboardingView()
        .levelaTheme()
}

#Preview("Goal") {
    OnboardingView(step: .goal)
        .levelaTheme()
}

#Preview("Profile") {
    OnboardingView(step: .profile)
        .levelaTheme()
}

#Preview("Weight") {
    OnboardingView(step: .weight)
        .levelaTheme()
}

#Preview("Height") {
    OnboardingView(step: .height)
        .levelaTheme()
}
