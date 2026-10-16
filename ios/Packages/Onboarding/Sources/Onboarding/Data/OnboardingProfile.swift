import Foundation

/// The values collected by the onboarding flow, handed to the host app when the
/// user taps Next on the final step.
///
/// Canonical units are always kg / cm; the selected display unit is carried
/// alongside so the preference can be restored. Mirrors the Android
/// `OnboardingProfile`.
public struct OnboardingProfile: Hashable, Sendable {
    public let goal: String?
    public let ageYears: Int
    public let sex: String?
    public let weightKg: Double
    public let heightCm: Double
    public let activityLevel: String?
    public let weightUnit: String
    public let heightUnit: String

    public init(
        goal: String?,
        ageYears: Int,
        sex: String?,
        weightKg: Double,
        heightCm: Double,
        activityLevel: String?,
        weightUnit: String,
        heightUnit: String
    ) {
        self.goal = goal
        self.ageYears = ageYears
        self.sex = sex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.activityLevel = activityLevel
        self.weightUnit = weightUnit
        self.heightUnit = heightUnit
    }
}
