import Foundation
import Observation

/// Drives the post-guest onboarding flow.
///
/// `@Observable` + `@MainActor` is the iOS counterpart to the Android
/// `OnboardingViewModel`; the owning view holds it with `@State`. The canonical
/// value is always stored in kg / cm; the UI shows the selected unit and
/// conversions are applied on read/write so switching units preserves the
/// measurement.
@Observable
@MainActor
public final class OnboardingViewModel {
    public private(set) var step: OnboardingStep = OnboardingTokens.steps.first ?? .weight
    public private(set) var weightUnit: String = OnboardingTokens.defaultWeightUnit
    public private(set) var heightUnit: String = OnboardingTokens.defaultHeightUnit

    private var weightKg: Int = OnboardingTokens.weightKgDefault
    private var heightCm: Int = OnboardingTokens.heightCmDefault

    public init() {}

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

    /// Advances to the next step, staying on the last step.
    public func next() {
        let index = stepIndex
        if index < stepCount - 1 { step = OnboardingTokens.steps[index + 1] }
    }

    /// Goes back a step, staying on the first step.
    public func back() {
        let index = stepIndex
        if index > 0 { step = OnboardingTokens.steps[index - 1] }
    }

    /// Selects `lb` or `kg`; ignores unknown units.
    public func selectWeightUnit(_ unit: String) {
        if OnboardingTokens.weightUnits.contains(unit) { weightUnit = unit }
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

    static func kgToLb(_ kg: Int) -> Int { Int((Double(kg) * 2.20462).rounded()) }
    static func lbToKg(_ lb: Int) -> Int { Int((Double(lb) / 2.20462).rounded()) }
    static func cmToIn(_ cm: Int) -> Int { Int((Double(cm) / 2.54).rounded()) }
    static func inToCm(_ inches: Int) -> Int { Int((Double(inches) * 2.54).rounded()) }

    /// Formats a total-inches height as feet'inches", e.g. 67 → `5'7"`.
    static func formatFtIn(_ inches: Int) -> String { "\(inches / 12)'\(inches % 12)\"" }
}
