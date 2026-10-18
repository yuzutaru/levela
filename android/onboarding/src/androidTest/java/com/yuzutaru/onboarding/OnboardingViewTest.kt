package com.yuzutaru.onboarding

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.data.OnboardingProfile
import com.yuzutaru.onboarding.presentation.OnboardingView
import com.yuzutaru.onboarding.presentation.OnboardingViewModel
import com.yuzutaru.onboarding.presentation.model.OnboardingStep
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import com.yuzutaru.onboarding.presentation.widget.BackButtonTag
import com.yuzutaru.onboarding.presentation.widget.NextButtonTag
import com.yuzutaru.onboarding.presentation.widget.SkipButtonTag
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

/**
 * UI tests for [OnboardingView].
 *
 * Each test drops the flow onto a chosen step (by advancing the injected
 * [OnboardingViewModel]) and drives it through the real composables, so the
 * step gating, unit toggles and completion wiring are exercised on-device.
 * Content is asserted against the shared [OnboardingTokens] (never hardcoded
 * copy); the back button is located by its test tag because its chevron carries
 * no text.
 */
class OnboardingViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun welcomeStepShowsCopyAndStartAdvances() {
        setContent(step = OnboardingStep.Welcome)

        composeTestRule.onNodeWithText(OnboardingTokens.WelcomeTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.WelcomeSubtitle).assertIsDisplayed()

        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        composeTestRule.onNodeWithText(OnboardingTokens.GoalTitle).assertIsDisplayed()
    }

    @Test
    fun goalStepGatesNextUntilAGoalIsChosen() {
        setContent(step = OnboardingStep.Goal)

        composeTestRule.onNodeWithText(OnboardingTokens.GoalTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()

        composeTestRule.onNodeWithText(OnboardingTokens.goals.first().title).performClick()

        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()
    }

    @Test
    fun goalStepBackReturnsToWelcome() {
        setContent(step = OnboardingStep.Goal)

        composeTestRule.onNodeWithTag(BackButtonTag).performClick()

        composeTestRule.onNodeWithText(OnboardingTokens.WelcomeTitle).assertIsDisplayed()
    }

    @Test
    fun genderStepGatesContinueUntilAGenderIsChosen() {
        setContent(step = OnboardingStep.Gender)

        composeTestRule.onNodeWithText(OnboardingTokens.GenderTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.GenderSubtitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()

        // The carousel opens on the middle card (Male).
        composeTestRule.onNodeWithText(OnboardingTokens.genderOptions[1].label).performClick()

        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()
    }

    @Test
    fun genderStepTogglesTheSelectedCardOff() {
        setContent(step = OnboardingStep.Gender)

        val label = OnboardingTokens.genderOptions[1].label
        composeTestRule.onNodeWithText(label).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()

        composeTestRule.onNodeWithText(label).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
    }

    @Test
    fun genderStepSkipAdvancesWithoutASelection() {
        setContent(step = OnboardingStep.Gender)

        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
        composeTestRule.onNodeWithTag(SkipButtonTag).performClick()

        composeTestRule.onNodeWithText(OnboardingTokens.AgeTitle).assertIsDisplayed()
    }

    @Test
    fun ageStepShowsTheDefaultAndAdvances() {
        setContent(step = OnboardingStep.Age)

        composeTestRule.onNodeWithText(OnboardingTokens.AgeTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.ageDefault.toString()).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()

        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        composeTestRule.onNodeWithText(OnboardingTokens.WeightTitle).assertIsDisplayed()
    }

    @Test
    fun weightUnitTogglePreservesTheMeasurement() {
        setContent(step = OnboardingStep.Weight)

        composeTestRule.onNodeWithText(OnboardingTokens.WeightTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.weightKgDefault.toString()).assertIsDisplayed()

        // The unselected option is the only single match (the selected one is
        // also echoed under the ruler), so tapping it is unambiguous.
        composeTestRule.onNodeWithText("lb").performClick()

        composeTestRule.onNodeWithText(OnboardingTokens.weightLbDefault.toString()).assertIsDisplayed()
    }

    @Test
    fun heightUnitToggleShowsFeetAndInches() {
        setContent(step = OnboardingStep.Height)

        composeTestRule.onNodeWithText(OnboardingTokens.HeightTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.heightCmDefault.toString()).assertIsDisplayed()

        composeTestRule.onNodeWithText("ft/in").performClick()

        composeTestRule.onNodeWithText("5'7\"").assertIsDisplayed()
    }

    @Test
    fun activityStepGatesNextAndCompletes() {
        var finished = false
        var saved: OnboardingProfile? = null
        setContent(
            step = OnboardingStep.Activity,
            save = { saved = it },
            onFinished = { finished = true },
        )

        composeTestRule.onNodeWithText(OnboardingTokens.ActivityTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()

        composeTestRule.onNodeWithText(OnboardingTokens.activityLevels.first().title).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()

        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        composeTestRule.waitUntil(timeoutMillis = 5_000) { finished }
        assertNotNull(saved)
        assertEquals(OnboardingTokens.activityLevels.first().title, saved?.activityLevel)
    }

    @Test
    fun walksTheWholeFlowAndFinishesOnce() {
        var finished = false
        val saved = mutableListOf<OnboardingProfile>()
        setContent(save = { saved += it }, onFinished = { finished = true })

        // Welcome -> Goal
        composeTestRule.onNodeWithText(OnboardingTokens.WelcomeTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Goal -> Gender
        composeTestRule.onNodeWithText(OnboardingTokens.GoalTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.goals.first().title).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Gender -> Age
        composeTestRule.onNodeWithText(OnboardingTokens.GenderTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.genderOptions[1].label).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Age -> Weight
        composeTestRule.onNodeWithText(OnboardingTokens.AgeTitle).assertIsDisplayed()
        composeTestRule.onNodeWithText(OnboardingTokens.ageDefault.toString()).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Weight -> Height
        composeTestRule.onNodeWithText(OnboardingTokens.WeightTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Height -> Activity
        composeTestRule.onNodeWithText(OnboardingTokens.HeightTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        // Activity -> finish
        composeTestRule.onNodeWithText(OnboardingTokens.ActivityTitle).assertIsDisplayed()
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
        composeTestRule.onNodeWithText(OnboardingTokens.activityLevels.first().title).performClick()
        composeTestRule.onNodeWithTag(NextButtonTag).performClick()

        composeTestRule.waitUntil(timeoutMillis = 5_000) { finished }
        assertTrue(finished)
        assertEquals(1, saved.size)
        assertEquals(OnboardingTokens.genderOptions[1].value, saved.first().sex)
    }

    /**
     * Sets [OnboardingView] content already sitting on [step], wired to [save]
     * (the host-app persistence hook) and [onFinished].
     */
    private fun setContent(
        step: OnboardingStep = OnboardingStep.Welcome,
        save: suspend (OnboardingProfile) -> Unit = {},
        onFinished: () -> Unit = {},
    ) {
        val viewModel = OnboardingViewModel(save)
        while (viewModel.step != step) viewModel.next()
        composeTestRule.setContent {
            LevelaTheme {
                OnboardingView(viewModel = viewModel, onFinished = onFinished)
            }
        }
    }
}
