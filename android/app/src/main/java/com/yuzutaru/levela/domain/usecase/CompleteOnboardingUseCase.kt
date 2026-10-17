package com.yuzutaru.levela.domain.usecase

import com.yuzutaru.levela.domain.model.toUserProfile
import com.yuzutaru.onboarding.data.OnboardingProfile
import com.yuzutaru.profile.data.repository.UserProfileRepository

/**
 * Completes onboarding by persisting the collected profile.
 *
 * The `:app`-side use case: it maps the feature's [OnboardingProfile] onto a
 * `UserProfile` and saves it as a guest-owned, pending row. The view model
 * receives it as a `suspend (OnboardingProfile) -> Unit` save function, which
 * keeps `:onboarding` free of persistence types and keeps the repository out of
 * the Activity.
 */
class CompleteOnboardingUseCase(
    private val repository: UserProfileRepository,
) {
    suspend operator fun invoke(profile: OnboardingProfile) {
        repository.save(profile.toUserProfile())
    }
}
