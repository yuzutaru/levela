import Design
import SwiftUI

/// The Levela post-guest onboarding flow (welcome, goal, gender, age, weight,
/// height, activity).
///
/// Shown after the user taps **Continue as a guest** on the splash. Seven steps:
/// a welcome intro, a single-select goal step, a gender carousel, an age ruler
/// step, then weight and height — the latter pair each using a draggable ruler
/// picker and a unit toggle — and finally a single-select activity-level step.
/// Tapping Next on the last step asks the view model to `complete()`, which
/// persists the collected profile through its injected save function; once
/// saved, `onFinished` is called. Mirrors the Android `OnboardingView`.
@MainActor
public struct OnboardingView: View {
    private let viewModel: OnboardingViewModel
    private let onFinished: () -> Void

    /// Creates the flow with an injected view model. The app owns the view
    /// model (the container builds it and the root view holds it as a plain
    /// `let`) so it survives re-renders.
    public init(viewModel: OnboardingViewModel,
                onFinished: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onFinished = onFinished
    }

    /// Owns a fresh view model starting at the welcome step.
    public init(onFinished: @escaping () -> Void = {}) {
        self.init(viewModel: OnboardingViewModel(), onFinished: onFinished)
    }

    /// Opens the view on a specific step. Internal: for previews/tests.
    init(step: OnboardingStep,
         save: @escaping @MainActor (OnboardingProfile) -> Void = { _ in },
         onFinished: @escaping () -> Void = {}) {
        self.init(viewModel: OnboardingViewModel(step: step, save: save), onFinished: onFinished)
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
                    } else if viewModel.step == .gender {
                        genderStep
                    } else if viewModel.step == .age {
                        ageStep
                    } else if viewModel.step == .activity {
                        activityStep
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

    /// Asks the view model to persist the collected profile (its injected save
    /// function) and reports completion once saved. The save is synchronous on
    /// iOS, so — unlike Android, whose `suspend` save needs a
    /// `LaunchedEffect(isComplete)` — the completion can be reported inline.
    private func complete() {
        viewModel.complete()
        if viewModel.isComplete { onFinished() }
    }

    /// Push forward (next): the new step enters from the right, the old one
    /// leaves to the left. Going back mirrors it: in from the left, out to the
    /// right.
    private var stepTransition: AnyTransition {
        viewModel.direction > 0
            ? .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
            : .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
    }

    /// Advances a step, sliding forward. The forward transition direction is
    /// committed by `viewModel.next()` before the animated step change.
    private func goNext() {
        withAnimation(.easeInOut(duration: 0.3)) { viewModel.next() }
    }

    /// Returns a step, sliding back (previous step in from the left, current one
    /// out to the right). The backward transition direction is committed by
    /// `viewModel.back()` before the animated step change.
    private func goBack() {
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
                    ForEach(OnboardingTokens.goals.indices, id: \.self) { index in
                        let goal = OnboardingTokens.goals[index]
                        OptionCard(
                            id: OnboardingAccessibility.goalCard(index),
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

    /// The gender step: title + subtitle + a single-screen carousel of three
    /// toggleable gender cards + a "prefer to skip this" pill + back /
    /// Continue. Continue stays disabled until a gender is chosen; tapping the
    /// selected card again clears the choice, and skipping advances with the
    /// value left unset.
    private var genderStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.genderTitle)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 28)

            Text(OnboardingTokens.genderSubtitle)
                .font(LevelaTypography.bodyLarge)
                .foregroundStyle(OnboardingTokens.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            GenderCarousel(
                options: OnboardingTokens.genderOptions,
                selectedSex: viewModel.sex,
                toggleSex: viewModel.toggleSex
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 16)

            SkipButton(label: OnboardingTokens.skip) {
                withAnimation(.easeInOut(duration: 0.3)) { viewModel.skipSex() }
            }
            .padding(.bottom, 12)

            HStack(spacing: 12) {
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.continueLabel, enabled: viewModel.hasSex) {
                    goNext()
                }
            }
            .padding(.bottom, 24)
        }
    }

    /// The age step: title + the age ruler card + back / Next. The age always has
    /// a default, so Next is always enabled.
    private var ageStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.ageTitle)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            AgeCard(age: viewModel.age, onAgeChange: viewModel.setAge)
                .padding(.top, 32)

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.next) {
                    goNext()
                }
            }
            .padding(.bottom, 24)
        }
    }

    /// The activity step: title + a scrollable list of single-select
    /// activity-level cards + back / Next. Next stays disabled until a level is
    /// chosen.
    private var activityStep: some View {
        VStack(spacing: 0) {
            Text(OnboardingTokens.activityTitle)
                .font(LevelaTypography.headlineMedium.bold())
                .foregroundStyle(OnboardingTokens.title)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(OnboardingTokens.activityLevels.indices, id: \.self) { index in
                        let level = OnboardingTokens.activityLevels[index]
                        OptionCard(
                            id: OnboardingAccessibility.activityCard(index),
                            title: level.title,
                            subtitle: level.subtitle,
                            isSelected: viewModel.activityLevel == level.title
                        ) {
                            viewModel.selectActivity(level.title)
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 4)
            }

            Spacer(minLength: 16)

            HStack(spacing: 12) {
                BackButton(action: goBack)
                NextButton(label: OnboardingTokens.next, enabled: viewModel.hasActivity) {
                    if viewModel.isLastStep {
                        complete()
                    } else {
                        goNext()
                    }
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
                        complete()
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
        case .gender: OnboardingTokens.genderTitle
        case .age: OnboardingTokens.ageTitle
        case .weight: OnboardingTokens.weightTitle
        case .height: OnboardingTokens.heightTitle
        case .activity: OnboardingTokens.activityTitle
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

/// The gender carousel: a swipeable, snapping row with the selected card
/// centred and the neighbouring cards peeking at the edges. Tapping a card
/// toggles it and scrolls it to the centre.
private struct GenderCarousel: View {
    let options: [GenderOption]
    let selectedSex: String?
    let toggleSex: (String) -> Void

    @State private var scrolledID: Int?

    init(options: [GenderOption],
         selectedSex: String?,
         toggleSex: @escaping (String) -> Void) {
        self.options = options
        self.selectedSex = selectedSex
        self.toggleSex = toggleSex
        let initial = options.firstIndex(where: { $0.value == selectedSex }) ?? (options.count / 2)
        _scrolledID = State(initialValue: initial)
    }

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(
                proxy.size.width * OnboardingTokens.genderCardWidthFraction,
                proxy.size.height * OnboardingTokens.genderCardAspectRatio
            )
            let cardHeight = cardWidth / OnboardingTokens.genderCardAspectRatio
            let horizontalMargin = max(0, (proxy.size.width - cardWidth) / 2)

            ScrollView(.horizontal) {
                LazyHStack(spacing: CGFloat(OnboardingTokens.genderCardSpacing)) {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]
                        GenderCard(
                            id: OnboardingAccessibility.genderCard(index),
                            option: option,
                            isSelected: option.value == selectedSex
                        ) {
                            toggleSex(option.value)
                            withAnimation(.easeInOut(duration: 0.25)) {
                                scrolledID = index
                            }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, horizontalMargin, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .scrollIndicators(.hidden)
        }
    }
}

/// A single gender card: symbol + label + selection check, with a large symbol.
private struct GenderCard: View {
    let id: String
    let option: GenderOption
    let isSelected: Bool
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(OnboardingTokens.genderCardCorner), style: .continuous)
    }

    private var background: Color {
        isSelected ? option.selected : option.surface
    }

    private var border: Color {
        isSelected ? option.selected : OnboardingTokens.genderCardInactiveBorder
    }

    private var content: Color {
        isSelected ? option.onSelected : OnboardingTokens.genderCardInactiveText
    }

    private var icon: Color {
        isSelected ? option.onSelected : option.accent
    }

    private var iconBackground: Color {
        isSelected ? option.onSelected.opacity(0.20) : option.accent.opacity(0.14)
    }

    private var symbolBackground: Color {
        isSelected ? option.onSelected.opacity(0.16) : option.accent.opacity(0.10)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(iconBackground)
                            .frame(width: 36, height: 36)

                        GenderSymbol(symbol: option.symbol, color: icon)
                            .frame(width: 20, height: 20)
                    }

                    Text(option.label)
                        .font(LevelaTypography.titleMedium.bold())
                        .foregroundStyle(content)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    GenderCheck(isSelected: isSelected, mark: option.accent)
                }

                GeometryReader { proxy in
                    let side = min(proxy.size.width, proxy.size.height)
                    ZStack {
                        Circle()
                            .fill(symbolBackground)
                            .frame(width: side * 0.82, height: side * 0.82)

                        GenderSymbol(symbol: option.symbol, color: icon)
                            .frame(width: side * 0.46, height: side * 0.46)

                        GenderSparkles(color: icon.opacity(0.75))
                            .frame(width: side, height: side)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(background, in: shape)
            .overlay(shape.stroke(border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// The card's selection indicator: a check when selected, an empty box otherwise.
private struct GenderCheck: View {
    let isSelected: Bool
    let mark: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isSelected ? OnboardingTokens.genderCheckActive : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(
                        isSelected
                            ? OnboardingTokens.genderCheckActive
                            : OnboardingTokens.genderCheckInactiveBorder,
                        lineWidth: 1
                    )
            )
            .frame(width: 26, height: 26)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(mark)
                }
            }
            .accessibilityHidden(true)
    }
}

/// A large gender symbol drawn with strokes, so both platforms stay consistent.
private struct GenderSymbol: View {
    let symbol: String
    let color: Color

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let radius = min(w, h) * 0.21
            let lineWidth = min(w, h) * 0.075
            let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

            func stroke(_ path: Path) {
                context.stroke(path, with: .color(color), style: style)
            }

            func line(_ start: CGPoint, _ end: CGPoint) {
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                stroke(path)
            }

            switch symbol {
            case "female":
                let cx = w * 0.5
                let cy = h * 0.36
                stroke(Path(ellipseIn: CGRect(
                    x: cx - radius,
                    y: cy - radius,
                    width: radius * 2,
                    height: radius * 2
                )))
                line(CGPoint(x: cx, y: cy + radius), CGPoint(x: cx, y: h * 0.92))
                line(CGPoint(x: w * 0.28, y: h * 0.78), CGPoint(x: w * 0.72, y: h * 0.78))

            case "male":
                let cx = w * 0.40
                let cy = h * 0.62
                stroke(Path(ellipseIn: CGRect(
                    x: cx - radius,
                    y: cy - radius,
                    width: radius * 2,
                    height: radius * 2
                )))
                let start = CGPoint(
                    x: cx + radius * 0.7071,
                    y: cy - radius * 0.7071
                )
                let end = CGPoint(x: w * 0.86, y: h * 0.14)
                line(start, end)
                line(end, CGPoint(x: w * 0.62, y: h * 0.14))
                line(end, CGPoint(x: w * 0.86, y: h * 0.40))

            default:
                let cx = w * 0.46
                let cy = h * 0.58
                stroke(Path(ellipseIn: CGRect(
                    x: cx - radius,
                    y: cy - radius,
                    width: radius * 2,
                    height: radius * 2
                )))
                let start = CGPoint(
                    x: cx + radius * 0.7071,
                    y: cy - radius * 0.7071
                )
                let end = CGPoint(x: w * 0.88, y: h * 0.10)
                line(start, end)
                line(end, CGPoint(x: w * 0.66, y: h * 0.10))
                line(end, CGPoint(x: w * 0.88, y: h * 0.34))
                line(CGPoint(x: cx, y: cy + radius), CGPoint(x: cx, y: h * 0.95))
                line(CGPoint(x: w * 0.26, y: h * 0.82), CGPoint(x: w * 0.66, y: h * 0.82))
            }
        }
    }
}

/// Small decorative dots around the central symbol, matching the reference cards.
private struct GenderSparkles: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let radius = min(size.width, size.height) * 0.018
            let dots = [
                CGPoint(x: size.width * 0.16, y: size.height * 0.22),
                CGPoint(x: size.width * 0.84, y: size.height * 0.32),
                CGPoint(x: size.width * 0.72, y: size.height * 0.78)
            ]
            for (index, point) in dots.enumerated() {
                let scale = index == 0 ? 1.0 : 0.7
                let rect = CGRect(
                    x: point.x - radius * scale,
                    y: point.y - radius * scale,
                    width: radius * 2 * scale,
                    height: radius * 2 * scale
                )
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }
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
                .accessibilityIdentifier(OnboardingAccessibility.value)

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
                .accessibilityIdentifier(OnboardingAccessibility.value)

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

/// Accessibility identifiers for the flow's controls. The back button carries no
/// text, so it needs a stable handle (for VoiceOver and for the UI tests);
/// mirrors the Android `BackButtonTag` / `NextButtonTag`. Internal: the app and
/// the tests, never the flow's public API.
///
/// The XCUITest UI tests (the app's `LevelaUITests`) repeat these strings — a UI
/// test bundle runs out of process and cannot import this module — so keep the
/// two in sync. The single-select cards are addressed by their position in the
/// contract's list, not by copy.
enum OnboardingAccessibility {
    static let back = "onboarding.back"
    static let next = "onboarding.next"
    static let skip = "onboarding.skip"
    /// The big value on the age / weight / height cards.
    static let value = "onboarding.value"

    static func goalCard(_ index: Int) -> String { "onboarding.goal.\(index)" }
    static func genderCard(_ index: Int) -> String { "onboarding.gender.\(index)" }
    static func activityCard(_ index: Int) -> String { "onboarding.activity.\(index)" }
    /// A unit-toggle option, keyed by its label (e.g. `lb`, `ft/in`).
    static func unit(_ unit: String) -> String { "onboarding.unit.\(unit)" }
}

/// The secondary "prefer to skip this" pill on the gender step.
private struct SkipButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(label)
                    .font(LevelaTypography.labelLarge)
                    .foregroundStyle(OnboardingTokens.skipText)

                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(OnboardingTokens.skipText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(OnboardingTokens.skipBackground, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(OnboardingAccessibility.skip)
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
        .accessibilityLabel(OnboardingTokens.back)
        .accessibilityIdentifier(OnboardingAccessibility.back)
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
        .accessibilityIdentifier(OnboardingAccessibility.next)
    }
}

/// A single-select option card: a status dot on the left, then a title and an
/// optional subtitle. Shared by the goal, profile and activity steps. `id` is
/// the card's accessibility identifier (its own, since the merged title/subtitle
/// label is not a stable handle).
private struct OptionCard: View {
    let id: String
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
        .accessibilityIdentifier(id)
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

#Preview("Gender") {
    OnboardingView(step: .gender)
        .levelaTheme()
}

#Preview("Age") {
    OnboardingView(step: .age)
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

#Preview("Activity") {
    OnboardingView(step: .activity)
        .levelaTheme()
}
