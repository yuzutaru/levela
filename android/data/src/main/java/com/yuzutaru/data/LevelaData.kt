package com.yuzutaru.data

import android.content.Context
import com.yuzutaru.data.local.LevelaDatabase

/**
 * Builds the data layer and exposes its repositories.
 *
 * Room types stay inside `:data`; consumers (e.g. `:app`) only see repositories
 * and domain models.
 */
class LevelaData(context: Context) {
    private val database = LevelaDatabase.build(context)

    val userProfileRepository: UserProfileRepository = UserProfileRepository(database.userProfileDao())
}
