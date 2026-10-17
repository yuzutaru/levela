import Profile

/// Resolves whether an active profile exists.
///
/// The app-side use case for the launch-time check: it keeps the repository out
/// of `RootViewModel`, mirroring the Android `HasActiveProfileUseCase`.
@MainActor
final class HasActiveProfileUseCase {
    private let repository: UserProfileRepository

    init(repository: UserProfileRepository) {
        self.repository = repository
    }

    /// `true` when a profile already exists, `false` before onboarding completes.
    func invoke() -> Bool {
        (try? repository.activeProfile()) != nil
    }
}
