package com.yuzutaru.levela

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createEmptyComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.test.core.app.ActivityScenario
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.yuzutaru.profile.data.ProfileData
import com.yuzutaru.profile.data.model.SyncState
import com.yuzutaru.profile.data.local.UserProfileEntity
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Instrumented tests for [MainActivity] routing logic.
 *
 * Verifies that returning users (with an existing profile) skip onboarding
 * and land directly on the main menu after the splash.
 */
@RunWith(AndroidJUnit4::class)
class MainActivityRoutingTest {

    @get:Rule
    val composeTestRule = createEmptyComposeRule()

    private var scenario: ActivityScenario<MainActivity>? = null

    @After
    fun tearDown() {
        scenario?.close()
    }

    @Test
    fun returningUserLandsOnMainMenu() {
        // Seed the database with a profile before launching the activity.
        seedProfile()

        scenario = ActivityScenario.launch(MainActivity::class.java)

        // Wait for the main menu to appear (splash auto-finishes → main menu),
        // landing on the Today destination.
        composeTestRule.waitUntil(timeoutMillis = 5_000) {
            composeTestRule.onAllNodesWithTag("mainmenu.today")
                .fetchSemanticsNodes().isNotEmpty()
        }

        composeTestRule.onNodeWithTag("mainmenu.today").assertIsDisplayed()
    }

    private fun seedProfile() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        val profileData = ProfileData(context)
        runBlocking {
            profileData.userProfileRepository.save(
                com.yuzutaru.profile.data.model.UserProfile(
                    id = "test-profile-id",
                    accountUserId = null,
                    goal = "Lose fat",
                    ageYears = 30,
                    sex = "Female",
                    weightKg = 70.0,
                    heightCm = 170.0,
                    activityLevel = "Moderately active",
                    weightUnit = "kg",
                    heightUnit = "cm",
                    onboardingCompleted = true,
                    createdAt = 1_000L,
                    updatedAt = 1_000L,
                )
            )
        }
    }
}
