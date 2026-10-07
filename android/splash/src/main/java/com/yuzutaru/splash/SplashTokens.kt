package com.yuzutaru.splash

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Blue500
import com.yuzutaru.design.ui.theme.Blue700
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.White

/**
 * Contract values for the splash flow.
 *
 * Mirrors `assets/splash/splash-contract.json` and the iOS `SplashTokens`.
 * Do not hand-edit: change the contract and run
 * `scripts/verify_splash_parity.sh`.
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
    val BackgroundGradient: List<Color> = listOf(White, LightBlue100)
    val BackgroundGlow: Color = LightBlue300
    val Title: Color = Navy900
    val LoginBackground: Color = Gray100
    val LoginText: Color = Blue700
    val RegisterBackground: Color = Blue500
    val RegisterText: Color = White
    val GuestText: Color = Gray500

    // Icon (the app's launcher icon foreground, injected by the app)
    val IconSize = 96.dp
}
