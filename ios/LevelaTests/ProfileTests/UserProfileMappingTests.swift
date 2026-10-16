import XCTest
@testable import Profile

final class UserProfileMappingTests: XCTestCase {

    func testNewRowsArePendingAndNotDeleted() {
        let entity = sampleProfile().toEntity(syncState: .pending)

        XCTAssertEqual(entity.syncState, .pending)
        XCTAssertFalse(entity.deleted)
    }

    func testRoundTripsThroughTheEntity() {
        let profile = sampleProfile()

        let entity = profile.toEntity(syncState: .synced)

        XCTAssertEqual(entity.toDomain(), profile)
    }

    func testAGuestProfileHasNoAccount() {
        let profile = sampleProfile()

        XCTAssertNil(profile.accountUserId)
        XCTAssertNil(profile.toEntity(syncState: .pending).accountUserId)
    }

    private func sampleProfile() -> UserProfile {
        UserProfile(
            id: "8a1b-uuid",
            accountUserId: nil,
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
}
