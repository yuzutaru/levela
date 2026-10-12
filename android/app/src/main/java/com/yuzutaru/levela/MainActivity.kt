package com.yuzutaru.levela

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.res.painterResource
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.OnboardingView
import com.yuzutaru.splash.SplashView
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val container = (application as LevelaApplication).container
        setContent {
            LevelaTheme {
                // Splash is the launch screen; tapping "Continue as a guest"
                // reports completion and crossfades into the onboarding flow.
                var showOnboarding by remember { mutableStateOf(false) }
                val scope = rememberCoroutineScope()
                AnimatedContent(
                    targetState = showOnboarding,
                    transitionSpec = {
                        fadeIn(tween(250)) togetherWith fadeOut(tween(250))
                    },
                    label = "splash-to-onboarding",
                ) { isOnboarding ->
                    if (isOnboarding) {
                        // Persist the collected profile offline; it stays guest-owned
                        // until the user registers, then syncs under the account.
                        OnboardingView(
                            onFinished = { profile ->
                                scope.launch {
                                    container.userProfileRepository.save(profile.toUserProfile())
                                }
                            },
                        )
                    } else {
                        SplashView(
                            icon = painterResource(R.drawable.ic_launcher_foreground),
                            onFinished = { showOnboarding = true },
                        )
                    }
                }
            }
        }
    }
}
