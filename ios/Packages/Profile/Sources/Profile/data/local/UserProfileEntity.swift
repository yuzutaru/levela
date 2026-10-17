import Foundation
import SwiftData

/// The locally persisted user profile — the first rows captured by the offline
/// onboarding flow.
///
/// The first four stored properties are the **sync envelope**: they exist now so
/// that an account can be attached and rows pushed later without a schema
/// migration. Mirrors the Android `UserProfileEntity`; like the Room entity it
/// stays inside the module — the app only ever sees `UserProfile`.
@Model
final class UserProfileEntity {
    /// Client-generated UUID; also the row's identity on the backend, so a
    /// re-pushed profile upserts rather than duplicates.
    @Attribute(.unique) var id: String

    /// Server-issued user id, `nil` until the guest registers or logs in.
    var accountUserId: String?

    var goal: String?
    var ageYears: Int
    var sex: String?
    var weightKg: Double
    var heightCm: Double
    var activityLevel: String?
    var weightUnit: String
    var heightUnit: String
    var onboardingCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    /// Backing store for `syncState`; `#Predicate` can only match stored properties.
    var syncStateRaw: String

    /// Soft-delete tombstone, so a deletion can be propagated later.
    var deleted: Bool

    init(
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
    var syncState: SyncState {
        get { SyncState(rawValue: syncStateRaw) ?? .pending }
        set { syncStateRaw = newValue.rawValue }
    }
}
