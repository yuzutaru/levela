import Onboarding
import Profile

/// The app's dependency graph — the composition root.
///
/// The iOS counterpart of Android's Hilt `SingletonComponent`: everything is
/// built once, eagerly, when the store opens, from the bindings in
/// `AppModule` (the counterpart of `@Module @InstallIn(SingletonComponent)`)
/// and the data layer handed out by `ProfileData` (whose counterpart of
/// `ProfileDataModule` lives inside the `Profile` package). Consumers receive
/// dependencies through constructor injection rather than constructing them
/// inline.
@MainActor
final class AppContainer {
    private let profileData: ProfileData

    /// The profile repository, provided by the `Profile` data layer.
    let userProfileRepository: UserProfileRepository

    /// The onboarding completion use case.
    let completeOnboardingUseCase: CompleteOnboardingUseCase

    /// The app-side save function injected into the onboarding view model
    /// (the counterpart of Android's `suspend (OnboardingProfile) -> Unit`).
    let onboardingSave: @MainActor (OnboardingProfile) -> Void

    /// Owns the launch-time "has profile?" state.
    let rootViewModel: RootViewModel

    /// Owns the onboarding flow, wired to persist through `onboardingSave`.
    let onboardingViewModel: OnboardingViewModel

    /// Creates a container from an already-opened ProfileData.
    /// Use this with `ProfileData.open()` for async, crash-safe startup.
    init(profileData: ProfileData) {
        let repository = profileData.userProfileRepository
        let useCase = AppModule.completeOnboardingUseCase(repository: repository)
        let save = AppModule.onboardingSave(useCase: useCase)

        self.profileData = profileData
        self.userProfileRepository = repository
        self.completeOnboardingUseCase = useCase
        self.onboardingSave = save
        self.rootViewModel = RootViewModel(repository: repository)
        self.onboardingViewModel = OnboardingViewModel(save: save)
    }
}
