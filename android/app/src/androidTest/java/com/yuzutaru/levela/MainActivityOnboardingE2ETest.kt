package com.yuzutaru.levela

import android.content.Context
import android.database.sqlite.SQLiteException
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.assertIsEnabled
import androidx.compose.ui.test.assertIsNotEnabled
import androidx.compose.ui.test.assertTextEquals
import androidx.compose.ui.test.junit4.createEmptyComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.core.app.ActivityScenario
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import com.yuzutaru.onboarding.presentation.widget.AgeWheelValueTag
import com.yuzutaru.onboarding.presentation.widget.NextButtonTag
import com.yuzutaru.onboarding.presentation.widget.ageWheelRowTag
import com.yuzutaru.profile.data.ProfileData
import com.yuzutaru.splash.SplashGuestButtonTag
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end test for the guest path through the real app: splash → onboarding
 * → main menu.
 *
 * This is the Android counterpart of the iOS `OnboardingUITests`: it launches
 * [MainActivity] out of process, enters through the splash guest button and
 * walks all seven onboarding steps through the actual Compose tree, asserting
 * the gating, the unit conversions and the persisted profile. The in-module
 * `OnboardingViewTest` covers the same view in isolation; this test additionally
 * covers the app wiring (splash hand-off, Hilt-backed save, navigation).
 *
 * The database is cleared before and after so the flow always starts as a new
 * guest, regardless of which other instrumented test ran first.
 */
@RunWith(AndroidJUnit4::class)
class MainActivityOnboardingE2ETest {

    @get:Rule
    val composeTestRule = createEmptyComposeRule()

    private val context: Context =
        ApplicationProvider.getApplicationContext()

    private var scenario: ActivityScenario<MainActivity>? = null

    @Before
    fun startAsANewGuest() {
        clearProfiles()
    }

    @After
    fun tearDown() {
        scenario?.close()
        clearProfiles()
    }

    @Test
    fun guestWalksTheWholeFlowAndLandsOnMainMenu() {
        scenario = ActivityScenario.launch(MainActivity::class.java)

        // Splash auto-advances to its actions stage; enter as a guest.
        waitForTag(SplashGuestButtonTag)
        composeTestRule.onNodeWithTag(SplashGuestButtonTag).performClick()

        // Welcome -> goal.
        waitForTag(NextButtonTag)
        onClickTag(NextButtonTag)

        // Goal -> gender: Next waits for a goal.
        waitForUniqueText(OnboardingTokens.GoalTitle)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
        clickText(OnboardingTokens.goals.first().title)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()
        onClickTag(NextButtonTag)

        // Gender -> age: Continue waits for a gender choice.
        waitForUniqueText(OnboardingTokens.GenderTitle)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
        clickText(OnboardingTokens.genderOptions[1].label)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()
        onClickTag(NextButtonTag)

        // Age -> weight: the wheel opens on the default and a tap selects.
        waitForUniqueText(OnboardingTokens.AgeTitle)
        waitForValue(OnboardingTokens.ageDefault.toString())
        val nextAge = OnboardingTokens.ageDefault + 1
        waitForTag(ageWheelRowTag(nextAge))
        composeTestRule.onNodeWithTag(ageWheelRowTag(nextAge)).performClick()
        waitForValue(nextAge.toString())
        onClickTag(NextButtonTag)

        // Weight -> height: 70 kg converts to 154 lb without losing the value.
        waitForUniqueText(OnboardingTokens.WeightTitle)
        composeTestRule.onNodeWithText(OnboardingTokens.weightKgDefault.toString())
            .assertIsDisplayed()
        clickText("lb")
        waitForUniqueText(OnboardingTokens.weightLbDefault.toString())
        onClickTag(NextButtonTag)

        // Height -> activity: 170 cm renders as 5'7" in feet/inches.
        waitForUniqueText(OnboardingTokens.HeightTitle)
        clickText("ft/in")
        waitForUniqueText("5'7\"")
        onClickTag(NextButtonTag)

        // Activity: Next gates the final step, then completion navigates on.
        waitForUniqueText(OnboardingTokens.ActivityTitle)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsNotEnabled()
        clickText(OnboardingTokens.activityLevels.first().title)
        composeTestRule.onNodeWithTag(NextButtonTag).assertIsEnabled()
        onClickTag(NextButtonTag)

        waitForTag("mainmenu.title")
        composeTestRule.onNodeWithTag("mainmenu.title").assertIsDisplayed()

        // The guest profile was persisted with the collected values, in kg / cm.
        val profile = runBlocking {
            ProfileData(context).userProfileRepository.activeProfile()
        }
        assertNotNull(profile)
        val saved = requireNotNull(profile)
        assertEquals(OnboardingTokens.goals.first().title, saved.goal)
        assertEquals(nextAge, saved.ageYears)
        assertEquals(OnboardingTokens.genderOptions[1].value, saved.sex)
        assertEquals(OnboardingTokens.weightKgDefault.toDouble(), saved.weightKg, 0.0)
        assertEquals(OnboardingTokens.heightCmDefault.toDouble(), saved.heightCm, 0.0)
        assertEquals(OnboardingTokens.activityLevels.first().title, saved.activityLevel)
    }

    // MARK: - Waits

    /** Waits until a step transition settles on exactly one node with [tag]. */
    private fun waitForTag(tag: String, timeoutMillis: Long = 20_000) {
        composeTestRule.waitUntil(timeoutMillis) {
            composeTestRule.onAllNodesWithTag(tag).fetchSemanticsNodes().size == 1
        }
    }

    /** Waits until exactly one node shows [text] (transitions keep both steps briefly). */
    private fun waitForUniqueText(text: String, timeoutMillis: Long = 20_000) {
        composeTestRule.waitUntil(timeoutMillis) {
            composeTestRule.onAllNodesWithText(text).fetchSemanticsNodes().size == 1
        }
    }

    /** Waits until the age wheel's centred value reads [expected]. */
    private fun waitForValue(expected: String, timeoutMillis: Long = 20_000) {
        composeTestRule.waitUntil(timeoutMillis) {
            runCatching {
                composeTestRule.onNodeWithTag(AgeWheelValueTag).assertTextEquals(expected)
            }.isSuccess
        }
    }

    private fun onClickTag(tag: String) {
        waitForTag(tag)
        composeTestRule.onNodeWithTag(tag).performClick()
        composeTestRule.waitForIdle()
    }

    private fun clickText(text: String) {
        waitForUniqueText(text)
        composeTestRule.onNodeWithText(text).performClick()
        composeTestRule.waitForIdle()
    }

    // MARK: - Database

    /**
     * Removes any persisted profile so the app routes to onboarding. Uses a raw
     * connection because the app's Room instance may already be open in this
     * instrumentation process; falls back to deleting the file when the table
     * does not exist yet.
     */
    private fun clearProfiles() {
        try {
            context.openOrCreateDatabase("profile.db", Context.MODE_PRIVATE, null).use { db ->
                db.execSQL("DELETE FROM user_profile")
            }
        } catch (e: SQLiteException) {
            context.deleteDatabase("profile.db")
        }
    }
}
