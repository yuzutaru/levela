package com.yuzutaru.nutrition.presentation.model

import org.junit.Assert.assertEquals
import org.junit.Test

class NutritionTokensTest {

    @Test
    fun titleCopy() {
        assertEquals("Nutrition", NutritionTokens.Title)
    }

    @Test
    fun screenTagStaysStable() {
        // The app-level routing and end-to-end tests assert on this exact tag.
        assertEquals("mainmenu.nutrition", NutritionTokens.ScreenTag)
    }
}
