package com.yuzutaru.levela

import android.app.Application
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import com.yuzutaru.onboarding.presentation.OnboardingViewModel
import com.yuzutaru.profile.data.ProfileData
import com.yuzutaru.profile.data.repository.UserProfileRepository

/**
 * Holds the app's long-lived singletons.
 *
 * A small hand-rolled container stands in for a DI framework: features receive
 * their dependencies from here rather than constructing them inline.
 */
class LevelaApplication : Application() {
    val container: AppContainer by lazy { AppContainer(this) }
}

/** The app's dependency graph. Everything is lazy, so nothing is built until used. */
class AppContainer(application: Application) {
    private val profile by lazy { ProfileData(application) }

    val userProfileRepository: UserProfileRepository get() = profile.userProfileRepository

    /** Persists the onboarding result; the `:app` implementation of the save. */
    val completeOnboardingUseCase: CompleteOnboardingUseCase by lazy {
        CompleteOnboardingUseCase(userProfileRepository)
    }

    /** Builds the onboarding view model, injecting the use case. */
    val onboardingViewModelFactory: ViewModelProvider.Factory by lazy {
        viewModelFactory {
            initializer { OnboardingViewModel(completeOnboardingUseCase::invoke) }
        }
    }
}
