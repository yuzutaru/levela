package com.yuzutaru.onboarding

import com.yuzutaru.onboarding.data.OnboardingProfile
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import com.yuzutaru.onboarding.presentation.OnboardingViewModel
import com.yuzutaru.onboarding.presentation.cmToIn
import com.yuzutaru.onboarding.presentation.formatFtIn
import com.yuzutaru.onboarding.presentation.inToCm
import com.yuzutaru.onboarding.presentation.kgToLb
import com.yuzutaru.onboarding.presentation.lbToKg
import com.yuzutaru.onboarding.presentation.model.OnboardingStep
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class OnboardingViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    @Test
    fun startsOnWelcomeStepWithDefaultUnits() {
        val viewModel = OnboardingViewModel { }

        assertEquals(OnboardingStep.Welcome, viewModel.step)
        assertEquals(OnboardingTokens.defaultWeightUnit, viewModel.weightUnit)
        assertEquals(OnboardingTokens.defaultHeightUnit, viewModel.heightUnit)
        assertEquals(OnboardingTokens.weightKgDefault, viewModel.weightDisplay)
        assertEquals(OnboardingTokens.heightCmDefault, viewModel.heightDisplay)
        assertTrue(viewModel.isFirstStep)
        assertFalse(viewModel.isLastStep)
    }

    @Test
    fun exposesTheFullFlow() {
        val viewModel = OnboardingViewModel { }

        assertEquals(6, viewModel.stepCount)
        assertEquals(0, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Goal, viewModel.step)
        assertEquals(1, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Profile, viewModel.step)
        assertEquals(2, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Weight, viewModel.step)
        assertEquals(3, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Height, viewModel.step)
        assertEquals(4, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Activity, viewModel.step)
        assertEquals(5, viewModel.stepIndex)
        assertTrue(viewModel.isLastStep)

        viewModel.back()
        assertEquals(OnboardingStep.Height, viewModel.step)
    }

    @Test
    fun staysOnBounds() {
        val viewModel = OnboardingViewModel { }

        viewModel.back()
        assertEquals(OnboardingStep.Welcome, viewModel.step)

        viewModel.next()
        viewModel.next()
        viewModel.next()
        viewModel.next()
        viewModel.next()
        assertEquals(OnboardingStep.Activity, viewModel.step)
    }

    @Test
    fun selectsASingleGoal() {
        val viewModel = OnboardingViewModel { }

        assertFalse(viewModel.hasGoal)
        assertNull(viewModel.goal)

        viewModel.selectGoal("Gain muscle")
        assertEquals("Gain muscle", viewModel.goal)
        assertTrue(viewModel.hasGoal)

        // Selecting another goal replaces the previous one (single-select).
        viewModel.selectGoal("Lose fat")
        assertEquals("Lose fat", viewModel.goal)

        // Unknown titles are ignored.
        viewModel.selectGoal("Not a goal")
        assertEquals("Lose fat", viewModel.goal)
    }

    @Test
    fun startsProfileWithDefaultAgeAndNoSex() {
        val viewModel = OnboardingViewModel { }

        assertEquals(OnboardingTokens.ageDefault, viewModel.age)
        assertNull(viewModel.sex)
        assertFalse(viewModel.hasSex)

        viewModel.selectSex("Female")
        assertEquals("Female", viewModel.sex)
        assertTrue(viewModel.hasSex)

        // Selecting another option replaces the previous one (single-select).
        viewModel.selectSex("Prefer not to say")
        assertEquals("Prefer not to say", viewModel.sex)

        // Unknown options are ignored.
        viewModel.selectSex("Not an option")
        assertEquals("Prefer not to say", viewModel.sex)

        viewModel.setAge(42)
        assertEquals(42, viewModel.age)
    }

    @Test
    fun switchingUnitPreservesTheMeasurement() {
        val viewModel = OnboardingViewModel { }

        viewModel.selectWeightUnit("lb")
        assertEquals(154, viewModel.weightDisplay)
        viewModel.selectWeightUnit("kg")
        assertEquals(70, viewModel.weightDisplay)

        viewModel.selectHeightUnit("ft/in")
        assertEquals(67, viewModel.heightDisplay)
        assertEquals("5'7\"", viewModel.heightDisplayText)
        viewModel.selectHeightUnit("cm")
        assertEquals(170, viewModel.heightDisplay)
        assertEquals("170", viewModel.heightDisplayText)
    }

    @Test
    fun formatsImperialHeightAsFeetAndInches() {
        assertEquals("3'11\"", formatFtIn(47))
        assertEquals("5'0\"", formatFtIn(60))
        assertEquals("5'7\"", formatFtIn(67))
        assertEquals("7'3\"", formatFtIn(87))
    }

    @Test
    fun ignoresUnknownUnits() {
        val viewModel = OnboardingViewModel { }

        viewModel.selectWeightUnit("stone")
        assertEquals(OnboardingTokens.defaultWeightUnit, viewModel.weightUnit)

        viewModel.selectHeightUnit("fathoms")
        assertEquals(OnboardingTokens.defaultHeightUnit, viewModel.heightUnit)
    }

    @Test
    fun setValueConvertsFromTheCurrentUnit() {
        val viewModel = OnboardingViewModel { }

        viewModel.selectWeightUnit("lb")
        viewModel.setWeightDisplay(200)
        viewModel.selectWeightUnit("kg")
        assertEquals(lbToKg(200), viewModel.weightDisplay)

        viewModel.selectHeightUnit("ft/in")
        viewModel.setHeightDisplay(60)
        viewModel.selectHeightUnit("cm")
        assertEquals(inToCm(60), viewModel.heightDisplay)
    }

    @Test
    fun conversionsRoundTrip() {
        assertEquals(70, lbToKg(kgToLb(70)))
        assertEquals(170, inToCm(cmToIn(170)))
    }

    @Test
    fun profileCarriesTheCollectedValues() {
        val viewModel = OnboardingViewModel { }
        viewModel.selectGoal("Gain muscle")
        viewModel.setAge(42)
        viewModel.selectSex("Female")
        viewModel.setWeightDisplay(80)
        viewModel.setHeightDisplay(180)
        viewModel.selectActivity("Very active")

        val profile = viewModel.profile()

        assertEquals("Gain muscle", profile.goal)
        assertEquals(42, profile.ageYears)
        assertEquals("Female", profile.sex)
        assertEquals(80.0, profile.weightKg, 0.0)
        assertEquals(180.0, profile.heightCm, 0.0)
        assertEquals("Very active", profile.activityLevel)
        assertEquals(OnboardingTokens.defaultWeightUnit, profile.weightUnit)
        assertEquals(OnboardingTokens.defaultHeightUnit, profile.heightUnit)
    }

    @Test
    fun completeSavesTheCollectedProfileAndMarksComplete() {
        var saved: OnboardingProfile? = null
        val viewModel = OnboardingViewModel { saved = it }
        viewModel.selectGoal("Gain muscle")
        viewModel.setAge(42)
        viewModel.selectSex("Female")
        viewModel.selectActivity("Very active")

        assertFalse(viewModel.isComplete)

        viewModel.complete()

        assertTrue(viewModel.isComplete)
        assertNotNull(saved)
        val profile = requireNotNull(saved)
        assertEquals("Gain muscle", profile.goal)
        assertEquals(42, profile.ageYears)
        assertEquals("Female", profile.sex)
        assertEquals("Very active", profile.activityLevel)
    }

    @Test
    fun completeOnlySavesOnce() {
        var count = 0
        val viewModel = OnboardingViewModel { count++ }
        viewModel.selectGoal("Lose fat")

        viewModel.complete()
        viewModel.complete()

        assertEquals(1, count)
        assertTrue(viewModel.isComplete)
    }
}
