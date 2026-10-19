import Onboarding
import Profile
import XCTest
@testable import Levela

@MainActor
final class CompleteOnboardingUseCaseTests: XCTestCase {

    func testInvokeMapsAndSavesAGuestOwnedCompletedProfile() throws {
        let repository = FakeUserProfileRepository()
        let useCase = CompleteOnboardingUseCase(repository: repository)

        try useCase.invoke(sampleOnboarding())

        XCTAssertEqual(repository.saved.count, 1)
        let saved = try XCTUnwrap(repository.saved.first)
        XCTAssertEqual(saved.goal, "Gain muscle")
        XCTAssertEqual(saved.ageYears, 42)
        XCTAssertEqual(saved.sex, "Female")
        XCTAssertEqual(saved.weightKg, 80)
        XCTAssertEqual(saved.heightCm, 180)
        XCTAssertEqual(saved.activityLevel, "Very active")
        XCTAssertEqual(saved.weightUnit, "kg")
        XCTAssertEqual(saved.heightUnit, "cm")
        XCTAssertNil(saved.accountUserId)
        XCTAssertTrue(saved.onboardingCompleted)
        XCTAssertFalse(saved.id.isEmpty)
    }

    private func sampleOnboarding() -> OnboardingProfile {
        OnboardingProfile(
            goal: "Gain muscle",
            ageYears: 42,
            sex: "Female",
            weightKg: 80,
            heightCm: 180,
            activityLevel: "Very active",
            weightUnit: "kg",
            heightUnit: "cm"
        )
    }
}
