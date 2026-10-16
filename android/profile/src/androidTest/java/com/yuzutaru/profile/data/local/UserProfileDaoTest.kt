package com.yuzutaru.profile.data.local

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import com.yuzutaru.profile.data.model.SyncState
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class UserProfileDaoTest {

    private lateinit var database: ProfileDatabase
    private lateinit var dao: UserProfileDao

    @Before
    fun createDatabase() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, ProfileDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        dao = database.userProfileDao()
    }

    @After
    fun closeDatabase() {
        database.close()
    }

    @Test
    fun upsertInsertsThenUpdatesByPrimaryKey() = runTest {
        dao.upsert(entity(id = "p1", goal = "Lose fat", updatedAt = 1_000L))
        assertEquals("Lose fat", dao.activeProfile()?.goal)

        dao.upsert(entity(id = "p1", goal = "Gain muscle", updatedAt = 2_000L))
        assertEquals("Gain muscle", dao.activeProfile()?.goal)
        assertEquals(1, dao.pendingChanges().size)
    }

    @Test
    fun activeProfileIsNullWhenEmpty() = runTest {
        assertNull(dao.activeProfile())
    }

    @Test
    fun observeActiveProfileReturnsTheNewestNonDeletedRow() = runTest {
        dao.upsert(entity(id = "old", updatedAt = 1_000L))
        dao.upsert(entity(id = "new", updatedAt = 2_000L))

        assertEquals("new", dao.observeActiveProfile().first()?.id)
    }

    @Test
    fun activeProfileIgnoresDeletedRows() = runTest {
        dao.upsert(entity(id = "kept", updatedAt = 1_000L))
        dao.upsert(entity(id = "deleted", updatedAt = 2_000L, deleted = true))

        assertEquals("kept", dao.activeProfile()?.id)
    }

    @Test
    fun pendingChangesExcludesSyncedRows() = runTest {
        dao.upsert(entity(id = "pending", syncState = SyncState.Pending))
        dao.upsert(entity(id = "failed", syncState = SyncState.Failed))
        dao.upsert(entity(id = "synced", syncState = SyncState.Synced))

        val ids = dao.pendingChanges().map { it.id }.toSet()

        assertEquals(setOf("pending", "failed"), ids)
    }

    @Test
    fun markSyncedUpdatesStateAndAccount() = runTest {
        dao.upsert(entity(id = "p1", syncState = SyncState.Pending))

        dao.markSynced(id = "p1", state = SyncState.Synced, accountUserId = "account-1")

        val stored = dao.activeProfile()
        assertEquals(SyncState.Synced, stored?.syncState)
        assertEquals("account-1", stored?.accountUserId)
        assertTrue(dao.pendingChanges().isEmpty())
    }

    @Test
    fun syncStateRoundTripsThroughTheConverters() = runTest {
        dao.upsert(entity(id = "p1", syncState = SyncState.Pending))
        assertEquals(SyncState.Pending, dao.activeProfile()?.syncState)

        dao.upsert(entity(id = "p1", syncState = SyncState.Synced))
        assertEquals(SyncState.Synced, dao.activeProfile()?.syncState)

        dao.upsert(entity(id = "p1", syncState = SyncState.Failed))
        assertEquals(SyncState.Failed, dao.activeProfile()?.syncState)
    }

    private fun entity(
        id: String,
        goal: String? = "Lose fat",
        updatedAt: Long = 1_000L,
        syncState: SyncState = SyncState.Pending,
        deleted: Boolean = false,
    ) = UserProfileEntity(
        id = id,
        accountUserId = null,
        goal = goal,
        ageYears = 30,
        sex = "Female",
        weightKg = 70.5,
        heightCm = 170.0,
        activityLevel = "Moderately active",
        weightUnit = "kg",
        heightUnit = "cm",
        onboardingCompleted = true,
        createdAt = 1_000L,
        updatedAt = updatedAt,
        syncState = syncState,
        deleted = deleted,
    )
}
