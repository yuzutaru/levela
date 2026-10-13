package com.yuzutaru.profile.data.repository

import com.yuzutaru.profile.data.model.UserProfile
import kotlinx.coroutines.flow.Flow

/** Reads and writes the local profile, mapping between the domain model and Room. */
interface UserProfileRepository {
    /** The active profile, observed for the UI. Emits `null` before onboarding completes. */
    fun observeActiveProfile(): Flow<UserProfile?>

    suspend fun activeProfile(): UserProfile?

    /** Persists a profile as a pending local change (written offline). */
    suspend fun save(profile: UserProfile)

    /**
     * Re-parents a guest profile onto an account after registration/login.
     * The row keeps its UUID; only the owner changes, and it is queued for push.
     */
    suspend fun attachToAccount(id: String, accountUserId: String)
}
