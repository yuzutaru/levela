package com.yuzutaru.onboarding

/**
 * The port the onboarding flow uses to persist the collected profile.
 *
 * `:onboarding` does not depend on the persistence feature, so it declares this
 * contract and the host app supplies the implementation (mapping to its own
 * storage). The iOS `Onboarding` package is persistence-agnostic in the same
 * way: the app performs the save.
 */
fun interface CompleteOnboardingUseCase {
    suspend operator fun invoke(profile: OnboardingProfile)
}
