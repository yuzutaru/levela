import Onboarding
import Profile
import XCTest
@testable import Levela

final class ProfileMappingTests: XCTestCase {

    func testMapsOnboardingIntoAGuestOwnedCompletedProfile() {
        let onboarding = OnboardingProfile(
            goal: "Gain muscle",
            ageYears: 42,
            sex: "Female",
            weightKg: 80,
            heightCm: 180,
            activityLevel: "Very active",
            weightUnit: "kg",
            heightUnit: "cm"
        )
        let now = Date(timeIntervalSince1970: 1_000)

        let profile = onboarding.toUserProfile(now: now)

        XCTAssertEqual(profile.goal, "Gain muscle")
        XCTAssertEqual(profile.ageYears, 42)
        XCTAssertEqual(profile.sex, "Female")
        XCTAssertEqual(profile.weightKg, 80)
        XCTAssertEqual(profile.heightCm, 180)
        XCTAssertEqual(profile.activityLevel, "Very active")
        XCTAssertNil(profile.accountUserId)
        XCTAssertTrue(profile.onboardingCompleted)
        XCTAssertEqual(profile.createdAt, now)
        XCTAssertEqual(profile.updatedAt, now)
    }

    func testGivesEachProfileAClientGeneratedId() {
        let onboarding = OnboardingProfile(
            goal: nil,
            ageYears: 30,
            sex: nil,
            weightKg: 70,
            heightCm: 170,
            activityLevel: nil,
            weightUnit: "kg",
            heightUnit: "cm"
        )

        let first = onboarding.toUserProfile()
        let second = onboarding.toUserProfile()

        XCTAssertFalse(first.id.isEmpty)
        XCTAssertNotEqual(first.id, second.id)
    }
}
