package com.yuzutaru.splash

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SplashViewModelTest {

    @Test
    fun startsOnBrandStage() {
        val viewModel = SplashViewModel()

        assertEquals(SplashStage.Brand, viewModel.stage)
        assertFalse(viewModel.isFinished)
    }

    @Test
    fun advancesThroughEveryStage() {
        val viewModel = SplashViewModel()

        viewModel.advance()
        assertEquals(SplashStage.Welcome, viewModel.stage)

        viewModel.advance()
        assertEquals(SplashStage.Actions, viewModel.stage)
        assertTrue(viewModel.isFinished)

        // Stays put once finished.
        viewModel.advance()
        assertEquals(SplashStage.Actions, viewModel.stage)
    }

    @Test
    fun nextDelayFollowsTheContract() {
        val viewModel = SplashViewModel()

        assertEquals(SplashTokens.AutoAdvanceBrandMs, viewModel.nextDelayMs())
        viewModel.advance()
        assertEquals(SplashTokens.AutoAdvanceWelcomeMs, viewModel.nextDelayMs())
        viewModel.advance()
        assertNull(viewModel.nextDelayMs())
    }
}
