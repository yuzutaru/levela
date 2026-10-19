package com.yuzutaru.levela

import com.yuzutaru.profile.data.model.UserProfile
import com.yuzutaru.profile.data.repository.UserProfileRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

/**
 * In-memory [UserProfileRepository] for app-level unit tests.
 *
 * `stored` feeds `activeProfile()` / `observeActiveProfile()`, while `saved`
 * records every `save` call so use-case tests can assert what was persisted.
 */
class FakeUserProfileRepository(
    var stored: UserProfile? = null,
) : UserProfileRepository {
    private val active = MutableStateFlow(stored)

    val saved = mutableListOf<UserProfile>()
    val attached = mutableListOf<Pair<String, String>>()

    fun emit(profile: UserProfile?) {
        stored = profile
        active.value = profile
    }

    override fun observeActiveProfile(): Flow<UserProfile?> = active

    override suspend fun activeProfile(): UserProfile? = stored

    override suspend fun save(profile: UserProfile) {
        saved += profile
        emit(profile)
    }

    override suspend fun attachToAccount(id: String, accountUserId: String) {
        attached += id to accountUserId
    }
}

/** A completed, guest-owned profile for app-level tests. */
fun sampleUserProfile(
    id: String = "8a1b-uuid",
    accountUserId: String? = null,
) = UserProfile(
    id = id,
    accountUserId = accountUserId,
    goal = "Lose fat",
    ageYears = 30,
    sex = "Female",
    weightKg = 70.5,
    heightCm = 170.0,
    activityLevel = "Moderately active",
    weightUnit = "kg",
    heightUnit = "cm",
    onboardingCompleted = true,
    createdAt = 1_000L,
    updatedAt = 2_000L,
)
