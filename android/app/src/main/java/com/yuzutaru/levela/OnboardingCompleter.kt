package com.yuzutaru.levela

import com.yuzutaru.onboarding.domain.CompleteOnboardingUseCase
import com.yuzutaru.onboarding.data.OnboardingProfile
import com.yuzutaru.profile.data.repository.UserProfileRepository

/**
 * Completes onboarding by persisting the collected profile.
 *
 * The `:app`-side adapter for [CompleteOnboardingUseCase]: it maps the feature's
 * [OnboardingProfile] onto a `UserProfile` and saves it as a guest-owned, pending
 * row. This keeps `:onboarding` free of persistence types and keeps the
 * repository out of the Activity.
 */
class OnboardingCompleter(
    private val repository: UserProfileRepository,
) : CompleteOnboardingUseCase {
    override suspend fun invoke(profile: OnboardingProfile) {
        repository.save(profile.toUserProfile())
    }
}
