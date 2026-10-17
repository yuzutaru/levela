package com.yuzutaru.levela

import com.yuzutaru.levela.domain.usecase.CompleteOnboardingUseCase
import com.yuzutaru.levela.domain.usecase.HasActiveProfileUseCase
import com.yuzutaru.onboarding.data.OnboardingProfile
import com.yuzutaru.profile.data.repository.UserProfileRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Hilt bindings for the app-level graph.
 *
 * The old hand-rolled `AppContainer` is replaced by these providers: features
 * receive dependencies through constructor injection rather than a container.
 */
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideCompleteOnboardingUseCase(
        repository: UserProfileRepository,
    ): CompleteOnboardingUseCase = CompleteOnboardingUseCase(repository)

    /**
     * Resolves whether an active profile exists for the launch-time check. Keeps
     * the repository out of `RootViewModel` and mirrors the iOS
     * `HasActiveProfileUseCase`.
     */
    @Provides
    @Singleton
    fun provideHasActiveProfileUseCase(
        repository: UserProfileRepository,
    ): HasActiveProfileUseCase = HasActiveProfileUseCase(repository)

    /**
     * Persists the onboarding result; the `:app`-side implementation of the
     * save function, injected into the `:onboarding` view model as a plain
     * `suspend (OnboardingProfile) -> Unit` so the feature module never sees
     * persistence types.
     *
     * Both the `@Provides` and the injection site carry `@JvmSuppressWildcards`
     * so the Java generic signatures of the functional type match exactly.
     */
    @Provides
    @Singleton
    fun provideOnboardingSave(
        useCase: CompleteOnboardingUseCase,
    ): @JvmSuppressWildcards suspend (OnboardingProfile) -> Unit = useCase::invoke
}
