package com.yuzutaru.nutrition.presentation.model

/**
 * The mock fasting summary shown on the Nutrition screen (placeholder until the
 * fasting data source lands).
 *
 * Shaped like the future model so only the data source has to change: the timer
 * is a preformatted label for now rather than a live clock.
 */
public data class FastingSummary(
    public val percentComplete: Int = 50,
    public val timer: String = "10:01:33",
    public val startLabel: String = "Yesterday 19:39",
    public val endLabel: String = "Today 15:39",
    public val phaseTitle: String = "New Phase!",
    public val phaseSubtitle: String = "Your metabolism is shifting gears.",
)
