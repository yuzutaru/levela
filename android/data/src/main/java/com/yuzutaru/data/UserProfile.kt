package com.yuzutaru.data

/**
 * The user's profile as the rest of the app sees it.
 *
 * A plain model, decoupled from the Room entity so the UI never depends on
 * persistence types. Canonical units are kg / cm. `id`, `accountUserId` and the
 * timestamps are the sync envelope (see `UserProfileEntity`).
 */
data class UserProfile(
    val id: String,
    val accountUserId: String?,
    val goal: String?,
    val ageYears: Int,
    val sex: String?,
    val weightKg: Double,
    val heightCm: Double,
    val activityLevel: String?,
    val weightUnit: String,
    val heightUnit: String,
    val onboardingCompleted: Boolean,
    val createdAt: Long,
    val updatedAt: Long,
)
