package com.yuzutaru.onboarding

import androidx.compose.ui.graphics.Color
import com.yuzutaru.design.ui.theme.Blue100
import com.yuzutaru.design.ui.theme.Blue300
import com.yuzutaru.design.ui.theme.Blue500
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.Gray300
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.White

/**
 * Contract values for the post-guest onboarding flow.
 *
 * Mirrors `assets/onboarding/onboarding-contract.json` and the iOS
 * `OnboardingTokens`. Do not hand-edit: change the contract and run
 * `scripts/verify_onboarding_parity.sh`.
 */
object OnboardingTokens {
    // Flow — steps: weight, height
    val steps: List<OnboardingStep> = listOf(
        OnboardingStep.Welcome,
        OnboardingStep.Weight,
        OnboardingStep.Height,
    )

    // Copy
    const val WelcomeTitle = "Start your Fitness Journey"
    const val WelcomeSubtitle = "Start your fitness journey with our app's guidance and support"
    const val WeightTitle = "What is your weight?"
    const val HeightTitle = "What is your height?"
    const val Start = "Let's start"
    const val Next = "Next"
    const val Back = "Back"

    // Units
    val weightUnits = listOf("lb", "kg")
    val heightUnits = listOf("ft/in", "cm")
    const val defaultWeightUnit = "kg"
    const val defaultHeightUnit = "cm"

    // Values (see onboarding-contract.json). Ranges/defaults are per display unit.
    const val weightKgMin = 30
    const val weightKgMax = 160
    const val weightKgStep = 1
    const val weightKgDefault = 70
    const val weightLbMin = 66
    const val weightLbMax = 352
    const val weightLbStep = 1
    const val weightLbDefault = 154
    const val heightCmMin = 120
    const val heightCmMax = 220
    const val heightCmStep = 1
    const val heightCmDefault = 170
    // Imperial height range is in total inches, displayed as feet'inches" (47–87 in = 3'11"–7'3").
    const val heightInMin = 47
    const val heightInMax = 87
    const val heightInStep = 1
    const val heightInDefault = 67

    // Colours (design-system primitives, see THEME_COLORS.md)
    val Background: Color = White
    val Title: Color = Navy900
    val Subtitle: Color = Gray500
    val Value: Color = Navy900
    val ActiveSegment: Color = Blue500
    val InactiveSegment: Color = Gray200
    val RulerTick: Color = Gray300
    val RulerLabel: Color = Gray500
    val RulerAccent: Color = Blue500
    val CardWeight: Color = LightBlue100
    val CardWeightAccent: Color = LightBlue300
    val CardHeight: Color = Blue100
    val CardHeightAccent: Color = Blue300
    val NextBackground: Color = Blue500
    val NextText: Color = White
    val ToggleTrack: Color = Gray100
    val ToggleSelectedBackground: Color = Blue500
    val ToggleSelectedText: Color = White
    val ToggleUnselectedText: Color = Gray500

    // Layout
    val HorizontalPadding = 24
    val CardCorner = 28
    val WelcomeIllustrationCorner = 28
}
