package com.yuzutaru.splash

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue

/**
 * Drives the splash flow.
 *
 * The platform counterpart of the iOS `SplashViewModel`; the owning view
 * schedules the timed advancement, the view model only owns the current stage.
 */
class SplashViewModel {
    var stage: SplashStage by mutableStateOf(SplashStage.Brand)
        private set

    /** True once the flow has reached its final stage. */
    val isFinished: Boolean get() = stage == SplashStage.Actions

    /** Delay before advancing from the current stage, or `null` when finished. */
    fun nextDelayMs(): Long? = when (stage) {
        SplashStage.Brand -> SplashTokens.AutoAdvanceBrandMs
        SplashStage.Welcome -> SplashTokens.AutoAdvanceWelcomeMs
        SplashStage.Actions -> null
    }

    /** Advances to the next stage, staying on [SplashStage.Actions]. */
    fun advance() {
        stage = when (stage) {
            SplashStage.Brand -> SplashStage.Welcome
            SplashStage.Welcome -> SplashStage.Actions
            SplashStage.Actions -> SplashStage.Actions
        }
    }
}
