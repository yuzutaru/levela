package com.yuzutaru.summary.presentation.widget

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

private val SummaryCardGap = 12.dp

/**
 * The dashboard's summary row: the nutrition summary card takes the left half;
 * the right half holds the step summary card on top and the active minutes card
 * below, each taking half of the nutrition card's height. The row grows with
 * the nutrition card's content but never drops below [minHeight].
 *
 * Shared by the Today and Nutrition destinations.
 */
@Composable
fun SummaryCards(
    minHeight: Dp,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Max)
            .heightIn(min = minHeight),
        horizontalArrangement = Arrangement.spacedBy(SummaryCardGap),
    ) {
        NutritionSummaryCard(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                .summaryCard(),
        )

        Column(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight(),
            verticalArrangement = Arrangement.spacedBy(SummaryCardGap),
        ) {
            StepsCard(
                modifier = Modifier
                    .weight(1f)
                    .summaryCard(),
            )
            ActiveMinutesCard(
                modifier = Modifier
                    .weight(1f)
                    .summaryCard(),
            )
        }
    }
}
