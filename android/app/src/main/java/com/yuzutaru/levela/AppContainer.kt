package com.yuzutaru.levela

import android.app.Application
import com.yuzutaru.profile.ProfileData
import com.yuzutaru.profile.UserProfileRepository

/**
 * Holds the app's long-lived singletons.
 *
 * A small hand-rolled container stands in for a DI framework: features receive
 * their dependencies from here rather than constructing them inline.
 */
class LevelaApplication : Application() {
    val container: AppContainer by lazy { AppContainer(this) }
}

/** The app's dependency graph. Everything is lazy, so nothing is built until used. */
class AppContainer(application: Application) {
    private val profile by lazy { ProfileData(application) }

    val userProfileRepository: UserProfileRepository get() = profile.userProfileRepository
}
