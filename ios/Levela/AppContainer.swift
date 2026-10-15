import Profile

/// Holds the app's long-lived singletons.
///
/// A small hand-rolled container stands in for a DI framework: features receive
/// their dependencies from here rather than constructing them inline. Mirrors the
/// Android `AppContainer`.
@MainActor
final class AppContainer {
    private let profileData: ProfileData

    /// The profile repository, built on first access (lazy like Android's `by lazy`).
    lazy var userProfileRepository: UserProfileRepository = profileData.userProfileRepository

    /// The onboarding completion use case, built on first access.
    lazy var completeOnboardingUseCase: CompleteOnboardingUseCase = CompleteOnboardingUseCase(repository: userProfileRepository)

    /// Creates a container from an already-opened ProfileData.
    /// Use this with `ProfileData.open()` for async, crash-safe startup.
    init(profileData: ProfileData) {
        self.profileData = profileData
    }
}
