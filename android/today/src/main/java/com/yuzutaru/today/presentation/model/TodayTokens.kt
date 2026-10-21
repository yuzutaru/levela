package com.yuzutaru.today.presentation.model

/**
 * Contract values for the Today dashboard.
 *
 * Mirrors the iOS `TodayAccessibility` and the `mainmenu.today` handle that the
 * app-level UI tests assert against. Keep [ScreenTag] stable: the routing and
 * end-to-end tests find the destination by it.
 */
object TodayTokens {
    /** The Today heading copy. */
    const val Title = "Overview"

    /** Stable test tag for the Today destination's heading. */
    const val ScreenTag = "mainmenu.today"
}
