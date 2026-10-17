import Foundation
import Observation

/// Drives the post-guest onboarding flow.
///
/// `@Observable` + `@MainActor` is the iOS counterpart to the Android
/// `@HiltViewModel` + `ViewModel`; the app owns it and injects it into
/// `OnboardingView` (rather than the view holding it in `@State`, which
/// ViewInspector cannot read cleanly). The canonical value is always stored in
/// kg / cm; the UI shows the selected unit and conversions are applied on
/// read/write so switching units preserves the measurement.
///
/// The view model owns completion: `complete()` hands the collected profile to
/// the injected save function and flips `isComplete` once it is saved. The host
/// app supplies that function (mirroring Android's injected
/// `suspend (OnboardingProfile) -> Unit`), so this module never sees
/// persistence types.
@Observable
@MainActor
public final class OnboardingViewModel {
    public private(set) var step: OnboardingStep = OnboardingTokens.steps.first ?? .weight
    /// 1 when moving forward through the steps, -1 when going back; drives the
    /// slide direction of the step transition.
    public private(set) var direction: Int = 1
    public private(set) var weightUnit: String = OnboardingTokens.defaultWeightUnit
    public private(set) var heightUnit: String = OnboardingTokens.defaultHeightUnit

    private var weightKg: Int = OnboardingTokens.weightKgDefault
    private var heightCm: Int = OnboardingTokens.heightCmDefault

    /// The chosen goal card title, or nil until one is selected.
    public private(set) var goal: String?

    public var hasGoal: Bool { goal != nil }

    /// The chosen age in years; starts at the contracted default.
    public private(set) var age: Int = OnboardingTokens.ageDefault

    /// The chosen gender option, or nil until one is selected.
    public private(set) var sex: String?

    public var hasSex: Bool { sex != nil }

    /// The chosen activity level (card title), or nil until one is selected.
    public private(set) var activityLevel: String?

    public var hasActivity: Bool { activityLevel != nil }

    /// True once the collected profile has been saved through the save function.
    public private(set) var isComplete: Bool = false

    /// Persists the collected profile; injected by the host app so this module
    /// stays free of persistence types (Android injects
    /// `suspend (OnboardingProfile) -> Unit` the same way). The default is a
    /// no-op, for previews and tests.
    private let save: @MainActor (OnboardingProfile) -> Void

    /// Creates a view model with the injected save function.
    public init(save: @escaping @MainActor (OnboardingProfile) -> Void = { _ in }) {
        self.save = save
    }

    /// Creates a view model positioned at `step`. Internal: for previews/tests.
    init(step: OnboardingStep, save: @escaping @MainActor (OnboardingProfile) -> Void = { _ in }) {
        self.step = step
        self.save = save
    }

    public var stepIndex: Int { OnboardingTokens.steps.firstIndex(of: step) ?? 0 }
    public var stepCount: Int { OnboardingTokens.steps.count }
    public var isFirstStep: Bool { stepIndex == 0 }
    public var isLastStep: Bool { stepIndex == stepCount - 1 }

    /// The weight in the currently selected unit.
    public var weightDisplay: Int { weightUnit == "kg" ? weightKg : Self.kgToLb(weightKg) }

    /// The height value shown on the ruler: cm, or total inches when imperial.
    public var heightDisplay: Int { heightUnit == "cm" ? heightCm : Self.cmToIn(heightCm) }

    /// The height formatted for the value card: `170` for cm, `5'7"` for ft/in.
    public var heightDisplayText: String {
        heightUnit == "cm" ? "\(heightCm)" : Self.formatFtIn(Self.cmToIn(heightCm))
    }

    /// Advances to the next step, staying on the last step. Commits the forward
    /// transition direction before the step change so the slide reads correctly.
    public func next() {
        direction = 1
        let index = stepIndex
        if index < stepCount - 1 { step = OnboardingTokens.steps[index + 1] }
    }

    /// Goes back a step, staying on the first step. Commits the backward
    /// transition direction before the step change so the slide reads correctly.
    public func back() {
        direction = -1
        let index = stepIndex
        if index > 0 { step = OnboardingTokens.steps[index - 1] }
    }

    /// Selects `lb` or `kg`; ignores unknown units.
    public func selectWeightUnit(_ unit: String) {
        if OnboardingTokens.weightUnits.contains(unit) { weightUnit = unit }
    }

    /// Selects a goal card by title; ignores unknown titles.
    public func selectGoal(_ goal: String) {
        if OnboardingTokens.goals.contains(where: { $0.title == goal }) { self.goal = goal }
    }

    /// Selects a gender option; ignores unknown values.
    public func selectSex(_ option: String) {
        if OnboardingTokens.sexOptions.contains(option) { sex = option }
    }

    /// Advances past the gender step with no selection, so the profile is saved
    /// without a sex value.
    public func skipSex() {
        sex = nil
        next()
    }

    /// Selects an activity-level card by title; ignores unknown titles.
    public func selectActivity(_ level: String) {
        if OnboardingTokens.activityLevels.contains(where: { $0.title == level }) { activityLevel = level }
    }

    /// Sets the age in years.
    public func setAge(_ value: Int) {
        age = value
    }

    /// Selects `ft/in` or `cm`; ignores unknown units.
    public func selectHeightUnit(_ unit: String) {
        if OnboardingTokens.heightUnits.contains(unit) { heightUnit = unit }
    }

    /// Sets the weight from the value shown in the current unit.
    public func setWeightDisplay(_ value: Int) {
        weightKg = weightUnit == "kg" ? value : Self.lbToKg(value)
    }

    /// Sets the height from the value shown in the current unit.
    public func setHeightDisplay(_ value: Int) {
        heightCm = heightUnit == "cm" ? value : Self.inToCm(value)
    }

    /// Persists the collected profile through the injected save function, then
    /// flips `isComplete`. Re-entrant calls are ignored, so a double tap saves
    /// once. Mirrors the Android `complete()`.
    public func complete() {
        if isComplete { return }
        save(makeProfile())
        isComplete = true
    }

    /// The collected values, ready for the host app to persist.
    public func makeProfile() -> OnboardingProfile {
        OnboardingProfile(
            goal: goal,
            ageYears: age,
            sex: sex,
            weightKg: Double(weightKg),
            heightCm: Double(heightCm),
            activityLevel: activityLevel,
            weightUnit: weightUnit,
            heightUnit: heightUnit
        )
    }

    static func kgToLb(_ kg: Int) -> Int { Int((Double(kg) * 2.20462).rounded()) }
    static func lbToKg(_ lb: Int) -> Int { Int((Double(lb) / 2.20462).rounded()) }
    static func cmToIn(_ cm: Int) -> Int { Int((Double(cm) / 2.54).rounded()) }
    static func inToCm(_ inches: Int) -> Int { Int((Double(inches) * 2.54).rounded()) }

    /// Formats a total-inches height as feet'inches", e.g. 67 → `5'7"`.
    static func formatFtIn(_ inches: Int) -> String { "\(inches / 12)'\(inches % 12)\"" }
}
