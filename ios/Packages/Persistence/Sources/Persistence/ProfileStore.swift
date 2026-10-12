import Foundation
import SwiftData

/// Reads and writes the local user profile through SwiftData.
///
/// `pendingChanges()` and `attachToAccount(id:accountUserId:)` exist for the sync
/// engine that ships with accounts; they are unused while the app is guest-only
/// but keep the schema sync-ready. Mirrors the Android `UserProfileRepository`.
@MainActor
public final class ProfileStore {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    /// Persists a new profile as a pending local change (written offline).
    public func save(_ profile: UserProfile) throws {
        context.insert(profile)
        try context.save()
    }

    /// The active (non-deleted) profile, newest first.
    public func activeProfile() throws -> UserProfile? {
        var descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.deleted == false },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    /// Every row that still needs to be pushed to the backend.
    public func pendingChanges() throws -> [UserProfile] {
        try context.fetch(
            FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.syncStateRaw != "synced" }
            )
        )
    }

    /// Re-parents a guest profile onto an account after registration/login.
    /// The row keeps its UUID; only the owner changes, and it is queued for push.
    public func attachToAccount(id: String, accountUserId: String) throws {
        guard let profile = try profile(id: id) else { return }
        profile.accountUserId = accountUserId
        profile.syncState = .pending
        profile.updatedAt = .now
        try context.save()
    }

    private func profile(id: String) throws -> UserProfile? {
        try context.fetch(
            FetchDescriptor<UserProfile>(predicate: #Predicate { $0.id == id })
        ).first
    }
}
