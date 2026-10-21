package com.yuzutaru.nutrition.presentation.model

/**
 * Contract values for the Nutrition destination.
 *
 * Mirrors the iOS `NutritionTokens` and the `mainmenu.nutrition` handle that the
 * app-level tests assert against. Keep [ScreenTag] stable: routing and
 * end-to-end tests find the destination by it.
 */
public object NutritionTokens {
    /** The Nutrition heading copy. */
    public const val Title: String = "Nutrition"

    /** Stable test tag for the Nutrition destination's heading. */
    public const val ScreenTag: String = "mainmenu.nutrition"
}
