package com.yuzutaru.profile

import android.content.Context
import com.yuzutaru.profile.local.ProfileDatabase

/**
 * Builds the profile feature's data layer and exposes its repositories.
 *
 * Room types stay inside `:profile`; consumers (e.g. `:app`) only see repositories
 * and domain models.
 */
class ProfileData(context: Context) {
    private val database = ProfileDatabase.build(context)

    val userProfileRepository: UserProfileRepository =
        UserProfileRepositoryImpl(database.userProfileDao())
}
