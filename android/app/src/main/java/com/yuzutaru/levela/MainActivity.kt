package com.yuzutaru.levela

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.res.painterResource
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.OnboardingView
import com.yuzutaru.splash.SplashView

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            LevelaTheme {
                // Splash is the launch screen; tapping "Continue as a guest"
                // reports completion and moves on to the onboarding flow.
                var showOnboarding by remember { mutableStateOf(false) }
                if (showOnboarding) {
                    OnboardingView()
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
