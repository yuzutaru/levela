package com.yuzutaru.onboarding

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class OnboardingViewModelTest {

    @Test
    fun startsOnWeightStepWithDefaultUnits() {
        val viewModel = OnboardingViewModel()

        assertEquals(OnboardingStep.Weight, viewModel.step)
        assertEquals(OnboardingTokens.defaultWeightUnit, viewModel.weightUnit)
        assertEquals(OnboardingTokens.defaultHeightUnit, viewModel.heightUnit)
        assertEquals(OnboardingTokens.weightKgDefault, viewModel.weightDisplay)
        assertEquals(OnboardingTokens.heightCmDefault, viewModel.heightDisplay)
        assertTrue(viewModel.isFirstStep)
        assertFalse(viewModel.isLastStep)
    }

    @Test
    fun exposesTwoSteps() {
        val viewModel = OnboardingViewModel()

        assertEquals(2, viewModel.stepCount)
        assertEquals(0, viewModel.stepIndex)

        viewModel.next()
        assertEquals(OnboardingStep.Height, viewModel.step)
        assertEquals(1, viewModel.stepIndex)
        assertTrue(viewModel.isLastStep)

        viewModel.back()
        assertEquals(OnboardingStep.Weight, viewModel.step)
    }

    @Test
    fun staysOnBounds() {
        val viewModel = OnboardingViewModel()

        viewModel.back()
        assertEquals(OnboardingStep.Weight, viewModel.step)

        viewModel.next()
        viewModel.next()
        assertEquals(OnboardingStep.Height, viewModel.step)
    }

    @Test
    fun switchingUnitPreservesTheMeasurement() {
        val viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("lb")
        assertEquals(154, viewModel.weightDisplay)
        viewModel.selectWeightUnit("kg")
        assertEquals(70, viewModel.weightDisplay)

        viewModel.selectHeightUnit("inches")
        assertEquals(67, viewModel.heightDisplay)
        viewModel.selectHeightUnit("cm")
        assertEquals(170, viewModel.heightDisplay)
    }

    @Test
    fun ignoresUnknownUnits() {
        val viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("stone")
        assertEquals(OnboardingTokens.defaultWeightUnit, viewModel.weightUnit)

        viewModel.selectHeightUnit("fathoms")
        assertEquals(OnboardingTokens.defaultHeightUnit, viewModel.heightUnit)
    }

    @Test
    fun setValueConvertsFromTheCurrentUnit() {
        val viewModel = OnboardingViewModel()

        viewModel.selectWeightUnit("lb")
        viewModel.setWeightDisplay(200)
        viewModel.selectWeightUnit("kg")
        assertEquals(lbToKg(200), viewModel.weightDisplay)

        viewModel.selectHeightUnit("inches")
        viewModel.setHeightDisplay(60)
        viewModel.selectHeightUnit("cm")
        assertEquals(inToCm(60), viewModel.heightDisplay)
    }

    @Test
    fun conversionsRoundTrip() {
        assertEquals(70, lbToKg(kgToLb(70)))
        assertEquals(170, inToCm(cmToIn(170)))
    }
}
