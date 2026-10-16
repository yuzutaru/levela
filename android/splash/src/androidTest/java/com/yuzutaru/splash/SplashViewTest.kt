package com.yuzutaru.splash

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.ColorPainter
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.yuzutaru.design.ui.theme.LevelaTheme
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

/**
 * UI tests for [SplashView].
 *
 * The timed stages are pinned by holding the main clock ([autoAdvance] off) and
 * either injecting a [SplashViewModel] already sitting on a stage or advancing
 * the clock explicitly, so nothing depends on wall-clock timing.
 */
class SplashViewTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val icon = ColorPainter(Color(0xFF94A3B8))

    @Test
    fun brandStageShowsIconOnly() {
        setContentAt(SplashStage.Brand)

        composeTestRule.onNodeWithText(SplashTokens.TitleLine1).assertDoesNotExist()
        composeTestRule.onNodeWithText(SplashTokens.TitleLine2).assertDoesNotExist()
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()
    }

    @Test
    fun welcomeStageShowsTitleButNotActions() {
        setContentAt(SplashStage.Welcome)

        composeTestRule.onNodeWithText(SplashTokens.TitleLine1).assertIsDisplayed()
        composeTestRule.onNodeWithText(SplashTokens.TitleLine2).assertIsDisplayed()
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()
    }

    @Test
    fun actionsStageShowsGuestButton() {
        setContentAt(SplashStage.Actions)

        composeTestRule.onNodeWithText(SplashTokens.Guest).assertIsDisplayed()
    }

    @Test
    fun authActionsStayHiddenWhileAccountsAreDeferred() {
        setContentAt(SplashStage.Actions)

        assertFalse(SplashTokens.ShowAuthActions)
        composeTestRule.onNodeWithText(SplashTokens.Login).assertDoesNotExist()
        composeTestRule.onNodeWithText(SplashTokens.Register).assertDoesNotExist()
    }

    @Test
    fun tappingGuestReportsFinished() {
        var finished = false
        setContentAt(SplashStage.Actions, onFinished = { finished = true })

        composeTestRule.onNodeWithText(SplashTokens.Guest).performClick()

        assertTrue(finished)
    }

    @Test
    fun autoAdvancesToActionsAfterTheTimedStages() {
        composeTestRule.mainClock.autoAdvance = false
        var finished = false
        setContent(onFinished = { finished = true })

        // Starts on the brand stage: icon only, no title or actions.
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceBrandMs + 1)
        composeTestRule.onNodeWithText(SplashTokens.TitleLine1).assertIsDisplayed()
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceWelcomeMs + 1)
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertIsDisplayed()

        // Advancing on its own must not complete the flow.
        assertFalse(finished)
    }

    @Test
    fun autoFinishSkipsActionsAndCompletesAfterWelcome() {
        composeTestRule.mainClock.autoAdvance = false
        var finished = false
        setContent(autoFinish = true, onFinished = { finished = true })

        // Starts on the brand stage.
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceBrandMs + 1)
        composeTestRule.onNodeWithText(SplashTokens.TitleLine1).assertIsDisplayed()
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        // After the welcome stage, autoFinish completes without showing actions.
        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceWelcomeMs + 1)
        assertTrue(finished)
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()
    }

    @Test
    fun autoFinishNeverShowsGuestButton() {
        composeTestRule.mainClock.autoAdvance = false
        setContent(autoFinish = true)

        // Brand stage.
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        // Welcome stage.
        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceBrandMs + 1)
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()

        // After welcome would have advanced to actions, but autoFinish completes.
        composeTestRule.mainClock.advanceTimeBy(SplashTokens.AutoAdvanceWelcomeMs + 1)
        composeTestRule.onNodeWithText(SplashTokens.Guest).assertDoesNotExist()
    }

    private fun setContentAt(
        stage: SplashStage,
        onFinished: () -> Unit = {},
    ) {
        val viewModel = SplashViewModel()
        while (viewModel.stage != stage) viewModel.advance()
        setContent(viewModel, onFinished)
    }

    private fun setContent(
        viewModel: SplashViewModel = SplashViewModel(),
        onFinished: () -> Unit = {},
        autoFinish: Boolean = false,
    ) {
        composeTestRule.mainClock.autoAdvance = false
        composeTestRule.setContent {
            LevelaTheme {
                SplashView(
                    icon = icon,
                    onFinished = onFinished,
                    autoFinish = autoFinish,
                    viewModel = viewModel,
                )
            }
        }
    }
}
