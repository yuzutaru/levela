import Profile

/// Holds the app's long-lived singletons.
///
/// A small hand-rolled container stands in for a DI framework: features receive
/// their dependencies from here rather than constructing them inline. Mirrors the
/// Android `AppContainer`.
@MainActor
final class AppContainer {
    let userProfileRepository: UserProfileRepository
    let completeOnboardingUseCase: CompleteOnboardingUseCase

    init(profileData: ProfileData) {
        userProfileRepository = profileData.userProfileRepository
        completeOnboardingUseCase = CompleteOnboardingUseCase(repository: userProfileRepository)
    }

    convenience init() throws {
        try self.init(profileData: ProfileData())
    }
}
