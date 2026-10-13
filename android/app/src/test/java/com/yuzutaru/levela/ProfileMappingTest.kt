package com.yuzutaru.levela

import com.yuzutaru.onboarding.OnboardingProfile
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ProfileMappingTest {

    @Test
    fun mapsOnboardingIntoAGuestOwnedCompletedProfile() {
        val onboarding = OnboardingProfile(
            goal = "Gain muscle",
            ageYears = 42,
            sex = "Female",
            weightKg = 80.0,
            heightCm = 180.0,
            activityLevel = "Very active",
            weightUnit = "kg",
            heightUnit = "cm",
        )

        val profile = onboarding.toUserProfile(now = 1_000L)

        assertEquals("Gain muscle", profile.goal)
        assertEquals(42, profile.ageYears)
        assertEquals("Female", profile.sex)
        assertEquals(80.0, profile.weightKg, 0.0)
        assertEquals(180.0, profile.heightCm, 0.0)
        assertEquals("Very active", profile.activityLevel)
        assertNull(profile.accountUserId)
        assertTrue(profile.onboardingCompleted)
        assertEquals(1_000L, profile.createdAt)
        assertEquals(1_000L, profile.updatedAt)
    }

    @Test
    fun givesEachProfileAClientGeneratedId() {
        val onboarding = OnboardingProfile(
            goal = null,
            ageYears = 30,
            sex = null,
            weightKg = 70.0,
            heightCm = 170.0,
            activityLevel = null,
            weightUnit = "kg",
            heightUnit = "cm",
        )

        val first = onboarding.toUserProfile()
        val second = onboarding.toUserProfile()

        assertTrue(first.id.isNotBlank())
        assertTrue(first.id != second.id)
    }
}
