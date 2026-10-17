package com.yuzutaru.levela

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuzutaru.profile.data.repository.UserProfileRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

/**
 * Owns the app's launch-time state: whether a profile already exists.
 *
 * The repository stays inside the view model instead of being touched directly
 * by the Activity. `null` means "still loading", `false` means "no profile yet"
 * (route to onboarding) and `true` means "returning user" (route to main menu).
 */
class RootViewModel @Inject constructor(
    repository: UserProfileRepository,
) : ViewModel() {
    val hasProfile: StateFlow<Boolean?> = repository.observeActiveProfile()
        .map { it != null }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)
}