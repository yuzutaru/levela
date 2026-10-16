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

/** The app's top-level screens, in the order the guest walks them. */
private enum class LevelaFlow { Splash, Onboarding, MainMenu }

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val container = (application as LevelaApplication).container
        setContent {
            LevelaTheme {
                // Splash is the launch screen; tapping "Continue as a guest"
                // reports completion and crossfades into the onboarding flow.
                var flow by remember { mutableStateOf(LevelaFlow.Splash) }
                // The onboarding view model owns persistence (through its use
                // case); the activity only decides which flow is on screen.
                val onboardingViewModel: OnboardingViewModel =
                    viewModel(factory = container.onboardingViewModelFactory)
                AnimatedContent(
                    targetState = flow,
                    transitionSpec = {
                        fadeIn(tween(250)) togetherWith fadeOut(tween(250))
                    },
                    label = "levela-flow",
                ) { current ->
                    when (current) {
                        LevelaFlow.Splash -> SplashView(
                            icon = painterResource(R.drawable.ic_launcher_foreground),
                            onFinished = { flow = LevelaFlow.Onboarding },
                        )
                        LevelaFlow.Onboarding -> OnboardingView(
                            viewModel = onboardingViewModel,
                            // The profile is already persisted by the view model
                            // on the final Next; from here we move on to the
                            // (mock) main menu.
                            onFinished = { flow = LevelaFlow.MainMenu },
                        )
                        LevelaFlow.MainMenu -> MainMenuScreen()
                    }
                }
            }
        }
    }
}
