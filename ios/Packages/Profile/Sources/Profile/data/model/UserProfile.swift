import Foundation

/// The user's profile as the rest of the app sees it.
///
/// A plain model, decoupled from the SwiftData entity so the UI never depends on
/// persistence types. Canonical units are kg / cm. `id`, `accountUserId` and the
/// timestamps are the sync envelope (see `UserProfileEntity`). Mirrors the
/// Android `UserProfile`.
public struct UserProfile: Hashable, Sendable {
    public let id: String
    public let accountUserId: String?
    public let goal: String?
    public let ageYears: Int
    public let sex: String?
    public let weightKg: Double
    public let heightCm: Double
    public let activityLevel: String?
    public let weightUnit: String
    public let heightUnit: String
    public let onboardingCompleted: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        accountUserId: String?,
        goal: String?,
        ageYears: Int,
        sex: String?,
        weightKg: Double,
        heightCm: Double,
        activityLevel: String?,
        weightUnit: String,
        heightUnit: String,
        onboardingCompleted: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountUserId = accountUserId
        self.goal = goal
        self.ageYears = ageYears
        self.sex = sex
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.activityLevel = activityLevel
        self.weightUnit = weightUnit
        self.heightUnit = heightUnit
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
