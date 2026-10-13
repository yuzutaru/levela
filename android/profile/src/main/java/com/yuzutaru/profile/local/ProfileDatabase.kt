package com.yuzutaru.profile.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/**
 * The offline-first Room database backing the profile feature.
 *
 * Schema JSON is exported to `profile/schemas/` (`exportSchema = true`) so future
 * migrations can be written against it. Bump [version] and add a `Migration`
 * when the schema changes — never fall back to destructive migration.
 */
@Database(entities = [UserProfileEntity::class], version = 1, exportSchema = true)
@TypeConverters(Converters::class)
abstract class ProfileDatabase : RoomDatabase() {
    abstract fun userProfileDao(): UserProfileDao

    companion object {
        private const val Name = "profile.db"

        fun build(context: Context): ProfileDatabase =
            Room.databaseBuilder(context.applicationContext, ProfileDatabase::class.java, Name)
                .build()
    }
}
