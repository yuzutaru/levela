import Foundation

/// Reads and writes the local profile, mapping between the domain model and the
/// SwiftData entity. Mirrors the Android `UserProfileRepository`.
@MainActor
public protocol UserProfileRepository {
    /// The active profile. `nil` before onboarding completes.
    func activeProfile() throws -> UserProfile?

    /// Persists a profile as a pending local change (written offline).
    func save(_ profile: UserProfile) throws

    /// Re-parents a guest profile onto an account after registration/login.
    /// The row keeps its UUID; only the owner changes, and it is queued for push.
    func attachToAccount(id: String, accountUserId: String) throws
}
