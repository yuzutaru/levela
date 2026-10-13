package com.yuzutaru.profile.data.local

import androidx.room.TypeConverter

/** Room type converters for the `user_profile` table. */
class Converters {
    @TypeConverter
    fun fromSyncState(state: SyncState): String = state.name

    @TypeConverter
    fun toSyncState(value: String): SyncState = SyncState.valueOf(value)
}
