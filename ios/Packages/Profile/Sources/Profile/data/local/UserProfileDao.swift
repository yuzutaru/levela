import Foundation
import SwiftData

/// Reads and writes for the local user profile.
///
/// The SwiftData counterpart of the Android `UserProfileDao`: it owns the raw
/// `ModelContext` operations so the repository above it only maps and delegates.
/// `pendingChanges()` and `markSynced(...)` exist for the sync engine that ships
/// with accounts; they are unused while the app is guest-only but keep the
/// schema sync-ready.
@MainActor
final class UserProfileDao {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// The active (non-deleted) profile, newest first.
    func activeProfile() throws -> UserProfileEntity? {
        var descriptor = FetchDescriptor<UserProfileEntity>(
            predicate: #Predicate { $0.deleted == false },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    /// Every row that still needs to be pushed to the backend.
    func pendingChanges() throws -> [UserProfileEntity] {
        let synced = SyncState.synced.rawValue
        return try context.fetch(
            FetchDescriptor<UserProfileEntity>(
                predicate: #Predicate { $0.syncStateRaw != synced }
            )
        )
    }

    /// Inserts a row, or updates the existing one with the same primary key.
    func upsert(_ profile: UserProfileEntity) throws {
        context.insert(profile)
        try context.save()
    }

    /// Marks a row as pushed, optionally attaching the account it now belongs to.
    func markSynced(id: String, state: SyncState, accountUserId: String?) throws {
        guard let profile = try profile(id: id) else { return }
        profile.syncState = state
        profile.accountUserId = accountUserId
        try context.save()
    }

    private func profile(id: String) throws -> UserProfileEntity? {
        try context.fetch(
            FetchDescriptor<UserProfileEntity>(predicate: #Predicate { $0.id == id })
        ).first
    }
}
