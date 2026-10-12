package com.yuzutaru.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

/**
 * The offline-first Room database.
 *
 * Schema JSON is exported to `data/schemas/` (`exportSchema = true`) so future
 * migrations can be written against it. Bump [version] and add a `Migration`
 * when the schema changes — never fall back to destructive migration.
 */
@Database(entities = [UserProfileEntity::class], version = 1, exportSchema = true)
@TypeConverters(Converters::class)
abstract class LevelaDatabase : RoomDatabase() {
    abstract fun userProfileDao(): UserProfileDao

    companion object {
        private const val Name = "levela.db"

        fun build(context: Context): LevelaDatabase =
            Room.databaseBuilder(context.applicationContext, LevelaDatabase::class.java, Name)
                .build()
    }
}
