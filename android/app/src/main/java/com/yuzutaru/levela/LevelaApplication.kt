package com.yuzutaru.levela

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * The application entry point. Hilt generates the dependency graph; classes
 * annotated with `@AndroidEntryPoint` (e.g. [MainActivity]) receive injections
 * from it, and view models use `@HiltViewModel` + `hiltViewModel()`.
 */
@HiltAndroidApp
class LevelaApplication : Application()
