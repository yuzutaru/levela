import SwiftData
import XCTest
@testable import Profile

@MainActor
final class UserProfileRepositoryTests: XCTestCase {

    private func makeRepository() throws -> UserProfileRepository {
        try ProfileData.inMemory().userProfileRepository
    }

    private func sampleProfile(id: String = "8a1b-uuid") -> UserProfile {
        UserProfile(
            id: id,
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

    func testActiveProfileIsNilWhenNothingIsStored() throws {
        let repository = try makeRepository()

        XCTAssertNil(try repository.activeProfile())
    }

    func testSaveMapsTheStoredRowToTheDomainModel() throws {
        let repository = try makeRepository()
        let profile = sampleProfile()

        try repository.save(profile)

        XCTAssertEqual(try repository.activeProfile(), profile)
    }

    func testAttachToAccountReparentsTheRowForTheNewOwner() throws {
        let repository = try makeRepository()
        let profile = sampleProfile()
        try repository.save(profile)

        try repository.attachToAccount(id: profile.id, accountUserId: "account-1")

        let active = try repository.activeProfile()
        XCTAssertEqual(active?.id, profile.id)
        XCTAssertEqual(active?.accountUserId, "account-1")
    }
}
