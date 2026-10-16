package com.yuzutaru.profile.data.repository

import com.yuzutaru.profile.data.local.UserProfileDao
import com.yuzutaru.profile.data.local.UserProfileEntity
import com.yuzutaru.profile.data.model.SyncState
import com.yuzutaru.profile.data.model.UserProfile
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Test

class UserProfileRepositoryImplTest {

    @Test
    fun saveWritesAPendingUndeletedRow() = runTest {
        val dao = FakeUserProfileDao()
        val repository = UserProfileRepositoryImpl(dao)

        repository.save(sampleProfile())

        assertEquals(1, dao.upserted.size)
        val entity = dao.upserted.single()
        assertEquals(SyncState.Pending, entity.syncState)
        assertFalse(entity.deleted)
        assertEquals(sampleProfile(), entity.toDomain())
    }

    @Test
    fun attachToAccountQueuesAPendingPushForTheNewOwner() = runTest {
        val dao = FakeUserProfileDao()
        val repository = UserProfileRepositoryImpl(dao)

        repository.attachToAccount(id = "8a1b-uuid", accountUserId = "account-1")

        val call = dao.markSyncedCalls.single()
        assertEquals("8a1b-uuid", call.id)
        assertEquals(SyncState.Pending, call.state)
        assertEquals("account-1", call.accountUserId)
    }

    @Test
    fun activeProfileIsNullWhenNothingIsStored() = runTest {
        val repository = UserProfileRepositoryImpl(FakeUserProfileDao())

        assertNull(repository.activeProfile())
    }

    @Test
    fun activeProfileMapsTheStoredEntityToTheDomainModel() = runTest {
        val dao = FakeUserProfileDao()
        val repository = UserProfileRepositoryImpl(dao)
        val profile = sampleProfile()
        dao.stored = profile.toEntity(SyncState.Synced)

        assertEquals(profile, repository.activeProfile())
    }

    @Test
    fun observeActiveProfileMapsNullThenTheStoredProfile() = runTest {
        val dao = FakeUserProfileDao()
        val repository = UserProfileRepositoryImpl(dao)

        assertNull(repository.observeActiveProfile().first())

        val profile = sampleProfile()
        dao.emit(profile.toEntity(SyncState.Pending))

        assertEquals(profile, repository.observeActiveProfile().first())
    }

    private fun sampleProfile() = UserProfile(
        id = "8a1b-uuid",
        accountUserId = null,
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

    /** In-memory stand-in for the Room DAO — records writes and emits a single profile. */
    private class FakeUserProfileDao : UserProfileDao {
        val upserted = mutableListOf<UserProfileEntity>()
        val markSyncedCalls = mutableListOf<MarkSyncedCall>()
        var stored: UserProfileEntity? = null
        private val active = MutableStateFlow<UserProfileEntity?>(null)

        fun emit(entity: UserProfileEntity?) {
            stored = entity
            active.value = entity
        }

        override fun observeActiveProfile(): Flow<UserProfileEntity?> = active

        override suspend fun activeProfile(): UserProfileEntity? = stored

        override suspend fun pendingChanges(): List<UserProfileEntity> = emptyList()

        override suspend fun upsert(profile: UserProfileEntity) {
            upserted += profile
            emit(profile)
        }

        override suspend fun markSynced(id: String, state: SyncState, accountUserId: String?) {
            markSyncedCalls += MarkSyncedCall(id, state, accountUserId)
        }
    }

    private data class MarkSyncedCall(
        val id: String,
        val state: SyncState,
        val accountUserId: String?,
    )
}
