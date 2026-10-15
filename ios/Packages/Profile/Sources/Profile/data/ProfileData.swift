import Foundation
import SwiftData

/// Builds the profile feature's data layer and exposes its repositories.
///
/// SwiftData types stay inside `Profile`; consumers (e.g. the app) only see
/// repositories and domain models. Mirrors the Android `ProfileData`.
@MainActor
public final class ProfileData {
    public let userProfileRepository: UserProfileRepository

    /// Builds the persistent, on-disk store.
    public init() throws {
        let container = try ModelContainer(for: UserProfileEntity.self)
        userProfileRepository = ProfileData.makeRepository(for: container)
    }

    /// An in-memory store, for previews and tests.
    public static func inMemory() throws -> ProfileData {
        let container = try ModelContainer(
            for: UserProfileEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ProfileData(container: container)
    }

    private init(container: ModelContainer) {
        userProfileRepository = ProfileData.makeRepository(for: container)
    }

    private static func makeRepository(for container: ModelContainer) -> UserProfileRepository {
        UserProfileRepositoryImpl(dao: UserProfileDao(context: ModelContext(container)))
    }
}
