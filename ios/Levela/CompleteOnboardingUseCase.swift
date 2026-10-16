import Onboarding
import Profile

/// Completes onboarding by persisting the collected profile.
///
/// The app-side use case: it maps the feature's `OnboardingProfile` onto a
/// `UserProfile` and saves it as a guest-owned, pending row. The repository
/// stays out of the view, and `Onboarding` stays free of persistence types.
/// Mirrors the Android `CompleteOnboardingUseCase`.
@MainActor
final class CompleteOnboardingUseCase {
    private let repository: UserProfileRepository

    init(repository: UserProfileRepository) {
        self.repository = repository
    }

    func invoke(_ profile: OnboardingProfile) throws {
        try repository.save(profile.toUserProfile())
    }
}
