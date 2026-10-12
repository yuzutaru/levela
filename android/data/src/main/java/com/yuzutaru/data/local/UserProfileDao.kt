package com.yuzutaru.data.local

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

/**
 * Reads and writes for the local user profile.
 *
 * [pendingChanges] and [markSynced] exist for the sync engine that ships with
 * accounts; they are unused while the app is guest-only but keep the schema
 * sync-ready.
 */
@Dao
interface UserProfileDao {
    /** The active (non-deleted) profile, newest first, observed for the UI. */
    @Query("SELECT * FROM user_profile WHERE deleted = 0 ORDER BY updatedAt DESC LIMIT 1")
    fun observeActiveProfile(): Flow<UserProfileEntity?>

    /** One-shot read of the active profile. */
    @Query("SELECT * FROM user_profile WHERE deleted = 0 ORDER BY updatedAt DESC LIMIT 1")
    suspend fun activeProfile(): UserProfileEntity?

    /** Every row that still needs to be pushed to the backend. */
    @Query("SELECT * FROM user_profile WHERE syncState != 'Synced'")
    suspend fun pendingChanges(): List<UserProfileEntity>

    @Upsert
    suspend fun upsert(profile: UserProfileEntity)

    /** Marks a row as pushed, optionally attaching the account it now belongs to. */
    @Query("UPDATE user_profile SET syncState = :state, accountUserId = :accountUserId WHERE id = :id")
    suspend fun markSynced(id: String, state: SyncState, accountUserId: String?)
}
