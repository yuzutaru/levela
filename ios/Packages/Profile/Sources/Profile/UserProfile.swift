import Foundation
import SwiftData

/// The locally persisted user profile — the first rows captured by the offline
/// onboarding flow.
///
/// The first four stored properties are the **sync envelope**: they exist now so
/// that an account can be attached and rows pushed later without a schema
/// migration. Mirrors the Android `UserProfileEntity`.
@Model
public final class UserProfile {
    /// Client-generated UUID; also the row's identity on the backend, so a
    /// re-pushed profile upserts rather than duplicates.
    @Attribute(.unique) public var id: String

    /// Server-issued user id, `nil` until the guest registers or logs in.
    public var accountUserId: String?

    public var goal: String?
    public var ageYears: Int
    public var sex: String?
    public var weightKg: Double
    public var heightCm: Double
    public var activityLevel: String?
    public var weightUnit: String
    public var heightUnit: String
    public var onboardingCompleted: Bool
    public var createdAt: Date
    public var updatedAt: Date

    /// Backing store for `syncState`; `#Predicate` can only match stored properties.
    public var syncStateRaw: String

    /// Soft-delete tombstone, so a deletion can be propagated later.
    public var deleted: Bool

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
        updatedAt: Date,
        syncState: SyncState,
        deleted: Bool
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
        self.syncStateRaw = syncState.rawValue
        self.deleted = deleted
    }

    /// Whether the row still needs pushing to the backend.
    public var syncState: SyncState {
        get { SyncState(rawValue: syncStateRaw) ?? .pending }
        set { syncStateRaw = newValue.rawValue }
    }
}
