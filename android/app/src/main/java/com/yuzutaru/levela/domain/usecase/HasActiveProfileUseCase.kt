package com.yuzutaru.levela.domain.usecase

import com.yuzutaru.profile.data.repository.UserProfileRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/**
 * Resolves whether an active profile exists.
 *
 * The app-side use case for the launch-time check: it keeps the repository out
 * of [com.yuzutaru.levela.presentation.RootViewModel], mirroring the iOS `HasActiveProfileUseCase`. Emits `true`
 * once a profile exists and `false` before onboarding completes.
 */
class HasActiveProfileUseCase(
    private val repository: UserProfileRepository,
) {
    operator fun invoke(): Flow<Boolean> = repository.observeActiveProfile().map { it != null }
}
