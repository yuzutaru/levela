package com.yuzutaru.onboarding

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import kotlin.math.roundToInt

/**
 * Drives the post-guest onboarding flow.
 *
 * The platform counterpart of the iOS `OnboardingViewModel`. The canonical value
 * is always stored in kg / cm; the UI shows the selected unit and conversions
 * are applied on read/write so switching units preserves the measurement.
 */
class OnboardingViewModel {
    var step: OnboardingStep by mutableStateOf(OnboardingTokens.steps.first())
        private set

    var weightUnit: String by mutableStateOf(OnboardingTokens.defaultWeightUnit)
        private set

    var heightUnit: String by mutableStateOf(OnboardingTokens.defaultHeightUnit)
        private set

    private var weightKg by mutableIntStateOf(OnboardingTokens.weightKgDefault)
    private var heightCm by mutableIntStateOf(OnboardingTokens.heightCmDefault)

    val stepIndex: Int get() = OnboardingTokens.steps.indexOf(step)
    val stepCount: Int get() = OnboardingTokens.steps.size
    val isFirstStep: Boolean get() = stepIndex == 0
    val isLastStep: Boolean get() = stepIndex == stepCount - 1

    /** The weight in the currently selected unit. */
    val weightDisplay: Int get() = if (weightUnit == "kg") weightKg else kgToLb(weightKg)

    /** The height in the currently selected unit. */
    val heightDisplay: Int get() = if (heightUnit == "cm") heightCm else cmToIn(heightCm)

    /** Advances to the next step, staying on the last step. */
    fun next() {
        val index = stepIndex
        if (index < stepCount - 1) step = OnboardingTokens.steps[index + 1]
    }

    /** Goes back a step, staying on the first step. */
    fun back() {
        val index = stepIndex
        if (index > 0) step = OnboardingTokens.steps[index - 1]
    }

    /** Selects `lb` or `kg`; ignores unknown units. */
    fun selectWeightUnit(unit: String) {
        if (unit in OnboardingTokens.weightUnits) weightUnit = unit
    }

    /** Selects `inches` or `cm`; ignores unknown units. */
    fun selectHeightUnit(unit: String) {
        if (unit in OnboardingTokens.heightUnits) heightUnit = unit
    }

    /** Sets the weight from the value shown in the current unit. */
    fun setWeightDisplay(value: Int) {
        weightKg = if (weightUnit == "kg") value else lbToKg(value)
    }

    /** Sets the height from the value shown in the current unit. */
    fun setHeightDisplay(value: Int) {
        heightCm = if (heightUnit == "cm") value else inToCm(value)
    }
}

internal fun kgToLb(kg: Int): Int = (kg * 2.20462).roundToInt()

internal fun lbToKg(lb: Int): Int = (lb / 2.20462).roundToInt()

internal fun cmToIn(cm: Int): Int = (cm / 2.54).roundToInt()

internal fun inToCm(inches: Int): Int = (inches * 2.54).roundToInt()
