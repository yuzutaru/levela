package com.yuzutaru.profile.data.repository

import com.yuzutaru.profile.data.model.SyncState
import com.yuzutaru.profile.data.local.UserProfileDao
import com.yuzutaru.profile.data.local.UserProfileEntity
import com.yuzutaru.profile.data.model.UserProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

/** Room-backed [UserProfileRepository]. Maps between the domain model and the entity. */
class UserProfileRepositoryImpl(private val dao: UserProfileDao) : UserProfileRepository {
    override fun observeActiveProfile(): Flow<UserProfile?> =
        dao.observeActiveProfile().map { it?.toDomain() }

    override suspend fun activeProfile(): UserProfile? = dao.activeProfile()?.toDomain()

    override suspend fun save(profile: UserProfile) {
        dao.upsert(profile.toEntity(syncState = SyncState.Pending))
    }

    override suspend fun attachToAccount(id: String, accountUserId: String) {
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
