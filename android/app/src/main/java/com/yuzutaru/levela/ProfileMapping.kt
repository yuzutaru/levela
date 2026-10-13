package com.yuzutaru.levela

import com.yuzutaru.profile.data.model.UserProfile
import com.yuzutaru.onboarding.data.OnboardingProfile
import java.util.UUID

/**
 * Turns the values collected by onboarding into a profile ready to persist.
 *
 * The row is guest-owned (`accountUserId = null`) and gets a client-generated
 * UUID: the same id the backend will later upsert, so registering can re-parent
 * this row instead of copying it.
 */
fun OnboardingProfile.toUserProfile(now: Long = System.currentTimeMillis()): UserProfile = UserProfile(
    id = UUID.randomUUID().toString(),
    accountUserId = null,
    goal = goal,
    ageYears = ageYears,
    sex = sex,
    weightKg = weightKg,
    heightCm = heightCm,
    activityLevel = activityLevel,
    weightUnit = weightUnit,
    heightUnit = heightUnit,
    onboardingCompleted = true,
    createdAt = now,
    updatedAt = now,
)
