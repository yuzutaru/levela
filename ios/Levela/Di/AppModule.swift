import Onboarding
import Profile

/// App-level DI bindings — the iOS counterpart of Android's `AppModule.kt`
/// (`@Module @InstallIn(SingletonComponent)`).
///
/// Each `static func` is a `@Provides` function: it takes the dependencies it
/// needs as parameters and returns one graph object. `AppContainer` calls them
/// once, at composition time — the counterpart of the singleton scope.
@MainActor
enum AppModule {

    /// The app-side use case that persists a completed onboarding flow
    /// (`@Provides @Singleton fun provideCompleteOnboardingUseCase`).
    static func completeOnboardingUseCase(
        repository: UserProfileRepository
    ) -> CompleteOnboardingUseCase {
        CompleteOnboardingUseCase(repository: repository)
    }

    /// The app-side use case for the launch-time "has profile?" check
    /// (`@Provides @Singleton fun provideHasActiveProfileUseCase`).
    static func hasActiveProfileUseCase(
        repository: UserProfileRepository
    ) -> HasActiveProfileUseCase {
        HasActiveProfileUseCase(repository: repository)
    }

    /// Persists the onboarding result; the app-side implementation of the save
    /// function, injected into the onboarding view model as a plain
    /// `@MainActor (OnboardingProfile) -> Void` closure so the feature package
    /// never sees persistence types (Android injects
    /// `suspend (OnboardingProfile) -> Unit` the same way).
    ///
    /// Persistence failures are swallowed, as before: the flow is offline-first
    /// and a failed local write leaves the guest-owned row unwritten rather
    /// than blocking the UI.
    static func onboardingSave(
        useCase: CompleteOnboardingUseCase
    ) -> @MainActor (OnboardingProfile) -> Void {
        { profile in try? useCase.invoke(profile) }
    }
}
