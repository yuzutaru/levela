package com.yuzutaru.levela.domain.usecase

import com.yuzutaru.levela.FakeUserProfileRepository
import com.yuzutaru.onboarding.data.OnboardingProfile
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CompleteOnboardingUseCaseTest {

    @Test
    fun invokeMapsAndSavesAGuestOwnedCompletedProfile() = runTest {
        val repository = FakeUserProfileRepository()
        val useCase = CompleteOnboardingUseCase(repository)

        useCase(onboarding())

        val saved = repository.saved.single()
        assertEquals("Gain muscle", saved.goal)
        assertEquals(42, saved.ageYears)
        assertEquals("Female", saved.sex)
        assertEquals(80.0, saved.weightKg, 0.0)
        assertEquals(180.0, saved.heightCm, 0.0)
        assertEquals("Very active", saved.activityLevel)
        assertEquals("kg", saved.weightUnit)
        assertEquals("cm", saved.heightUnit)
        assertNull(saved.accountUserId)
        assertTrue(saved.onboardingCompleted)
        assertTrue(saved.id.isNotBlank())
    }

    private fun onboarding() = OnboardingProfile(
        goal = "Gain muscle",
        ageYears = 42,
        sex = "Female",
        weightKg = 80.0,
        heightCm = 180.0,
        activityLevel = "Very active",
        weightUnit = "kg",
        heightUnit = "cm",
    )
}
