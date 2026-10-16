import Foundation

/// SwiftData-backed `UserProfileRepository`. Maps between the domain model and
/// the entity. Mirrors the Android `UserProfileRepositoryImpl`.
@MainActor
final class UserProfileRepositoryImpl: UserProfileRepository {
    private let dao: UserProfileDao

    init(dao: UserProfileDao) {
        self.dao = dao
    }

    func activeProfile() throws -> UserProfile? {
        try dao.activeProfile()?.toDomain()
    }

    func save(_ profile: UserProfile) throws {
        try dao.upsert(profile.toEntity(syncState: .pending))
    }

    func attachToAccount(id: String, accountUserId: String) throws {
        try dao.markSynced(id: id, state: .pending, accountUserId: accountUserId)
    }
}

extension UserProfileEntity {
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            accountUserId: accountUserId,
            goal: goal,
            ageYears: ageYears,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: activityLevel,
            weightUnit: weightUnit,
            heightUnit: heightUnit,
            onboardingCompleted: onboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension UserProfile {
    func toEntity(syncState: SyncState) -> UserProfileEntity {
        UserProfileEntity(
            id: id,
            accountUserId: accountUserId,
            goal: goal,
            ageYears: ageYears,
            sex: sex,
            weightKg: weightKg,
            heightCm: heightCm,
            activityLevel: activityLevel,
            weightUnit: weightUnit,
            heightUnit: heightUnit,
            onboardingCompleted: onboardingCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            deleted: false
        )
    }
}
