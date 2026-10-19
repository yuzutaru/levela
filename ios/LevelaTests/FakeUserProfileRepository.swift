import Foundation
import Profile

/// In-memory `UserProfileRepository` for app-level unit tests.
///
/// `stored` feeds `activeProfile()`, while `saved` records every `save` call so
/// use-case tests can assert what was persisted.
@MainActor
final class FakeUserProfileRepository: UserProfileRepository {
    var stored: UserProfile?
    private(set) var saved: [UserProfile] = []
    private(set) var attached: [(id: String, accountUserId: String)] = []

    init(stored: UserProfile? = nil) {
        self.stored = stored
    }

    func activeProfile() throws -> UserProfile? {
        stored
    }

    func save(_ profile: UserProfile) throws {
        saved.append(profile)
        stored = profile
    }

    func attachToAccount(id: String, accountUserId: String) throws {
        attached.append((id: id, accountUserId: accountUserId))
    }
}

/// A completed, guest-owned profile for app-level tests.
func sampleUserProfile(
    id: String = "8a1b-uuid",
    accountUserId: String? = nil
) -> UserProfile {
    UserProfile(
        id: id,
        accountUserId: accountUserId,
        goal: "Lose fat",
        ageYears: 30,
        sex: "Female",
        weightKg: 70.5,
        heightCm: 170,
        activityLevel: "Moderately active",
        weightUnit: "kg",
        heightUnit: "cm",
        onboardingCompleted: true,
        createdAt: Date(timeIntervalSince1970: 1_000),
        updatedAt: Date(timeIntervalSince1970: 2_000)
    )
}
