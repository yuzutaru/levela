package com.yuzutaru.levela

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

/**
 * Owns the app's launch-time state: whether a profile already exists.
 *
 * The check goes through [HasActiveProfileUseCase], so the view model never
 * touches the repository directly. `null` means "still loading", `false` means
 * "no profile yet" (route to onboarding) and `true` means "returning user"
 * (route to main menu).
 */
@HiltViewModel
class RootViewModel @Inject constructor(
    hasActiveProfileUseCase: HasActiveProfileUseCase,
) : ViewModel() {
    val hasProfile: StateFlow<Boolean?> = hasActiveProfileUseCase()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)
}
