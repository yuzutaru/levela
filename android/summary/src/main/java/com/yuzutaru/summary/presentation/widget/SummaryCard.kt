package com.yuzutaru.summary.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.White

private val SummaryCardCorner = 28.dp
private val SummaryCardElevation = 12.dp

/**
 * The shared card chrome: the white surface, the rounded corner and the shadow.
 *
 * Used by every summary card on the dashboard and, via [SummaryCards], shared by
 * the Today and Nutrition destinations.
 */
fun Modifier.summaryCard(): Modifier = this
    .shadow(
        elevation = SummaryCardElevation,
        shape = RoundedCornerShape(SummaryCardCorner),
        clip = false,
    )
    .clip(RoundedCornerShape(SummaryCardCorner))
    .background(White)
