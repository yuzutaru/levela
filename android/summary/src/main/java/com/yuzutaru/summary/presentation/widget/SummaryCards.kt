package com.yuzutaru.summary.presentation.widget

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.White

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

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun SummaryCardsPreview() {
    LevelaTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .drawBehind {
                    drawRect(Brush.verticalGradient(listOf(White, LightBlue100)))
                    drawRect(
                        Brush.radialGradient(
                            colors = listOf(LightBlue300.copy(alpha = 0.55f), Color.Transparent),
                            center = Offset(size.width / 2f, -size.height * 0.08f),
                            radius = size.width * 1.1f,
                        )
                    )
                }
                .padding(24.dp),
        ) {
            SummaryCards(
                minHeight = 256.dp,
            )
        }
    }
}
