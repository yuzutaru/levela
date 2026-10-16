import SwiftData
import XCTest
@testable import Profile

@MainActor
final class UserProfileDaoTests: XCTestCase {

    private func makeDao() throws -> UserProfileDao {
        let container = try ModelContainer(
            for: UserProfileEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return UserProfileDao(context: ModelContext(container))
    }

    private func entity(
        id: String,
        goal: String? = "Lose fat",
        updatedAt: Date = Date(timeIntervalSince1970: 1_000),
        syncState: SyncState = .pending,
        deleted: Bool = false
    ) -> UserProfileEntity {
        UserProfileEntity(
            id: id,
            accountUserId: nil,
            goal: goal,
            ageYears: 30,
            sex: "Female",
            weightKg: 70.5,
            heightCm: 170,
            activityLevel: "Moderately active",
            weightUnit: "kg",
            heightUnit: "cm",
            onboardingCompleted: true,
            createdAt: Date(timeIntervalSince1970: 1_000),
            updatedAt: updatedAt,
            syncState: syncState,
            deleted: deleted
        )
    }

    func testUpsertInsertsThenUpdatesByPrimaryKey() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "p1", goal: "Lose fat", updatedAt: Date(timeIntervalSince1970: 1_000)))
        XCTAssertEqual(try dao.activeProfile()?.goal, "Lose fat")

        try dao.upsert(entity(id: "p1", goal: "Gain muscle", updatedAt: Date(timeIntervalSince1970: 2_000)))

        XCTAssertEqual(try dao.activeProfile()?.goal, "Gain muscle")
        XCTAssertEqual(try dao.pendingChanges().count, 1)
    }

    func testActiveProfileIsNilWhenEmpty() throws {
        let dao = try makeDao()

        XCTAssertNil(try dao.activeProfile())
    }

    func testActiveProfileReturnsTheNewestNonDeletedRow() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "old", updatedAt: Date(timeIntervalSince1970: 1_000)))
        try dao.upsert(entity(id: "new", updatedAt: Date(timeIntervalSince1970: 2_000)))

        XCTAssertEqual(try dao.activeProfile()?.id, "new")
    }

    func testActiveProfileIgnoresDeletedRows() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "kept", updatedAt: Date(timeIntervalSince1970: 1_000)))
        try dao.upsert(entity(id: "deleted", updatedAt: Date(timeIntervalSince1970: 2_000), deleted: true))

        XCTAssertEqual(try dao.activeProfile()?.id, "kept")
    }

    func testPendingChangesExcludesSyncedRows() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "pending", syncState: .pending))
        try dao.upsert(entity(id: "failed", syncState: .failed))
        try dao.upsert(entity(id: "synced", syncState: .synced))

        let ids = Set(try dao.pendingChanges().map(\.id))

        XCTAssertEqual(ids, ["pending", "failed"])
    }

    func testMarkSyncedUpdatesStateAndAccount() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "p1", syncState: .pending))

        try dao.markSynced(id: "p1", state: .synced, accountUserId: "account-1")

        let stored = try dao.activeProfile()
        XCTAssertEqual(stored?.syncState, .synced)
        XCTAssertEqual(stored?.accountUserId, "account-1")
        XCTAssertTrue(try dao.pendingChanges().isEmpty)
    }

    func testSyncStateRoundTripsThroughTheStoredRawValue() throws {
        let dao = try makeDao()
        try dao.upsert(entity(id: "p1", syncState: .pending))
        XCTAssertEqual(try dao.activeProfile()?.syncState, .pending)

        try dao.upsert(entity(id: "p1", syncState: .synced))
        XCTAssertEqual(try dao.activeProfile()?.syncState, .synced)

        try dao.upsert(entity(id: "p1", syncState: .failed))
        XCTAssertEqual(try dao.activeProfile()?.syncState, .failed)
    }
}
