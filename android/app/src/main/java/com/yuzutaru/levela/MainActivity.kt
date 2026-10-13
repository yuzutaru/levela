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
import androidx.compose.runtime.setValue
import androidx.compose.ui.res.painterResource
import androidx.lifecycle.viewmodel.compose.viewModel
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.presentation.OnboardingView
import com.yuzutaru.onboarding.presentation.OnboardingViewModel
import com.yuzutaru.splash.SplashView

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
                // The onboarding view model owns persistence (through its use
                // case); the activity only decides which flow is on screen.
                val onboardingViewModel: OnboardingViewModel =
                    viewModel(factory = container.onboardingViewModelFactory)
                AnimatedContent(
                    targetState = showOnboarding,
                    transitionSpec = {
                        fadeIn(tween(250)) togetherWith fadeOut(tween(250))
                    },
                    label = "splash-to-onboarding",
                ) { isOnboarding ->
                    if (isOnboarding) {
                        OnboardingView(
                            viewModel = onboardingViewModel,
                            onFinished = {
                                // The profile is already persisted by the view
                                // model; this is the hook for navigating on once
                                // a home screen exists.
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
