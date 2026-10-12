package com.yuzutaru.onboarding

/**
 * The values collected by the onboarding flow, handed to the host app when the
 * user taps Next on the final step.
 *
 * Canonical units are always kg / cm; the selected display unit is carried
 * alongside so the preference can be restored. Mirrors the iOS `OnboardingProfile`.
 */
data class OnboardingProfile(
    val goal: String?,
    val ageYears: Int,
    val sex: String?,
    val weightKg: Double,
    val heightCm: Double,
    val activityLevel: String?,
    val weightUnit: String,
    val heightUnit: String,
)
