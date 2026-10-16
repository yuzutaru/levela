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
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.lifecycle.compose.collectAsStateWithLifecycle
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
                // The root view model owns the launch-time "has profile?" state.
                // Returning users skip onboarding and land on the main menu.
                val rootViewModel: RootViewModel = viewModel(factory = container.rootViewModelFactory)
                val hasProfile by rootViewModel.hasProfile.collectAsStateWithLifecycle()

                val resolved = hasProfile
                if (resolved == null) {
                    Box(
                        modifier = Modifier.fillMaxSize(),
                        contentAlignment = Alignment.Center,
                    ) {
                        CircularProgressIndicator()
                    }
                } else {
                    // Splash is the launch screen. For new users, tapping
                    // "Continue as a guest" reports completion and crossfades
                    // into the onboarding flow. For returning users, the splash
                    // auto-finishes and lands directly on the main menu.
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
                                autoFinish = resolved,
                                onFinished = {
                                    flow = if (resolved) {
                                        LevelaFlow.MainMenu
                                    } else {
                                        LevelaFlow.Onboarding
                                    }
                                },
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
}
