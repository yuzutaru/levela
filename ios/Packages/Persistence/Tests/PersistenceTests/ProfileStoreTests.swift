import SwiftData
import XCTest
@testable import Persistence

@MainActor
final class ProfileStoreTests: XCTestCase {

    private func makeStore() throws -> ProfileStore {
        let container = try ModelContainer(
            for: UserProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ProfileStore(context: ModelContext(container))
    }

    private func makeProfile(id: String = UUID().uuidString) -> UserProfile {
        let now = Date()
        return UserProfile(
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
            createdAt: now,
            updatedAt: now,
            syncState: .pending,
            deleted: false
        )
    }

    func testSavesAndReadsTheActiveProfile() throws {
        let store = try makeStore()
        let profile = makeProfile()
        try store.save(profile)

        let active = try store.activeProfile()
        XCTAssertEqual(active?.id, profile.id)
        XCTAssertEqual(active?.weightKg, 70.5)
    }

    func testNewlySavedRowsArePending() throws {
        let store = try makeStore()
        try store.save(makeProfile())

        let pending = try store.pendingChanges()
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.syncState, .pending)
    }

    func testAttachToAccountReparentsWithoutChangingID() throws {
        let store = try makeStore()
        let profile = makeProfile()
        try store.save(profile)

        try store.attachToAccount(id: profile.id, accountUserId: "acct-1")

        let active = try store.activeProfile()
        XCTAssertEqual(active?.id, profile.id)
        XCTAssertEqual(active?.accountUserId, "acct-1")
        XCTAssertEqual(active?.syncState, .pending)
    }
}
