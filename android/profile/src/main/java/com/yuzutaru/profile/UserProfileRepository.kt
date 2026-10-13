package com.yuzutaru.profile

import com.yuzutaru.profile.local.SyncState
import com.yuzutaru.profile.local.UserProfileDao
import com.yuzutaru.profile.local.UserProfileEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/** Reads and writes the local profile, mapping between the domain model and Room. */
class UserProfileRepository(private val dao: UserProfileDao) {
    /** The active profile, observed for the UI. Emits `null` before onboarding completes. */
    fun observeActiveProfile(): Flow<UserProfile?> = dao.observeActiveProfile().map { it?.toDomain() }

    suspend fun activeProfile(): UserProfile? = dao.activeProfile()?.toDomain()

    /** Persists a profile as a pending local change (written offline). */
    suspend fun save(profile: UserProfile) {
        dao.upsert(profile.toEntity(syncState = SyncState.Pending))
    }

    /**
     * Re-parents a guest profile onto an account after registration/login.
     * The row keeps its UUID; only the owner changes, and it is queued for push.
     */
    suspend fun attachToAccount(id: String, accountUserId: String) {
        dao.markSynced(id = id, state = SyncState.Pending, accountUserId = accountUserId)
    }
}

internal fun UserProfileEntity.toDomain() = UserProfile(
    id = id,
    accountUserId = accountUserId,
    goal = goal,
    ageYears = ageYears,
    sex = sex,
    weightKg = weightKg,
    heightCm = heightCm,
    activityLevel = activityLevel,
    weightUnit = weightUnit,
    heightUnit = heightUnit,
    onboardingCompleted = onboardingCompleted,
    createdAt = createdAt,
    updatedAt = updatedAt,
)

internal fun UserProfile.toEntity(syncState: SyncState) = UserProfileEntity(
    id = id,
    accountUserId = accountUserId,
    goal = goal,
    ageYears = ageYears,
    sex = sex,
    weightKg = weightKg,
    heightCm = heightCm,
    activityLevel = activityLevel,
    weightUnit = weightUnit,
    heightUnit = heightUnit,
    onboardingCompleted = onboardingCompleted,
    createdAt = createdAt,
    updatedAt = updatedAt,
    syncState = syncState,
    deleted = false,
)
