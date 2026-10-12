package com.yuzutaru.levela

import android.app.Application
import com.yuzutaru.data.LevelaData
import com.yuzutaru.data.UserProfileRepository

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
    private val data by lazy { LevelaData(application) }

    val userProfileRepository: UserProfileRepository get() = data.userProfileRepository
}
