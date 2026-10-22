package com.yuzutaru.mainmenu

import com.yuzutaru.mainmenu.presentation.model.NutritionTokens
import org.junit.Assert.assertEquals
import org.junit.Test

class NutritionTokensTest {

    @Test
    fun copy() {
        assertEquals("Nutrition", NutritionTokens.Title)
    }

    @Test
    fun screenTagStaysStable() {
        // The app-level UI tests assert on this exact string.
        assertEquals("mainmenu.nutrition", NutritionTokens.ScreenTag)
    }
}
