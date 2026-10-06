package com.yuzutaru.splash

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.Lavender200
import com.yuzutaru.design.ui.theme.Purple700
import com.yuzutaru.design.ui.theme.Purple800
import com.yuzutaru.design.ui.theme.Purple900
import com.yuzutaru.design.ui.theme.Purple950
import com.yuzutaru.design.ui.theme.White

/**
 * Contract values for the splash flow.
 *
 * Mirrors `assets/splash/splash-contract.json` and the iOS `SplashTokens`.
 * Do not hand-edit: change the contract and run
 * `scripts/generate_splash_assets.sh` / `scripts/verify_splash_parity.sh`.
 */
object SplashTokens {
    // Flow — stages: brand, welcome, actions
    val stages: List<SplashStage> = listOf(
        SplashStage.Brand,
        SplashStage.Welcome,
        SplashStage.Actions,
    )
    const val AutoAdvanceBrandMs = 1200L
    const val AutoAdvanceWelcomeMs = 1200L
    const val ShowEveryLaunch = true

    // Copy
    const val TitleLine1 = "Start your"
    const val TitleLine2 = "Fitness Journey"
    const val Login = "Login"
    const val Register = "Register"
    const val Guest = "Continue as a guest"

    // Colours (design-system primitives, see THEME_COLORS.md)
    val BackgroundGradient: List<Color> = listOf(Purple800, Purple950, Purple900)
    val BackgroundGlow: Color = Purple800
    val Title: Color = White
    val Logo: Color = Lavender200
    val LoginBackground: Color = Purple700
    val LoginText: Color = Gray200
    val RegisterBackground: Color = White
    val RegisterText: Color = Purple950
    val GuestText: Color = Lavender200

    // Logo
    val LogoSize = 64.dp
}
