package com.yuzutaru.onboarding.presentation.model

/**
 * The steps of the post-guest onboarding flow.
 *
 * Mirrors the iOS `OnboardingStep`. The step names must match `flow.steps` in
 * `assets/onboarding/onboarding-contract.json`
 * (enforced by `scripts/verify_onboarding_parity.sh`).
 */
enum class OnboardingStep {
    Welcome,
    Goal,
    Gender,
    Age,
    Weight,
    Height,
    Activity,
}
