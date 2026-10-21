package com.yuzutaru.today.presentation.widget

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuzutaru.design.ui.theme.Gray400
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.White
import com.yuzutaru.today.presentation.todayCard

/**
 * The mock active minutes shown on the Today dashboard.
 *
 * Shaped like the future model, so only the data source has to change when
 * real activity tracking lands.
 */
internal data class ActiveMinutesSummary(
    val label: String = "Active Minutes",
    val total: String = "558",
    val averagePerDay: Int = 80,
)

/**
 * The active minutes summary: the label, the day's active minutes and the
 * daily average they are measured against. The card fills the space it is
 * given, so the three lines spread out instead of crowding the top of the card.
 */
@Composable
internal fun ActiveMinutesCard(
    modifier: Modifier = Modifier,
    summary: ActiveMinutesSummary = ActiveMinutesSummary(),
) {
    Column(
        modifier = modifier.padding(16.dp),
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        Text(
            text = summary.label,
            style = MaterialTheme.typography.labelMedium,
            color = Gray500,
            maxLines = 1,
        )

        Row(modifier = Modifier.fillMaxWidth()) {
            Text(
                text = summary.total,
                style = MaterialTheme.typography.headlineMedium.copy(fontSize = 26.sp),
                color = Navy900,
                maxLines = 1,
                softWrap = false,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.alignByBaseline(),
            )
            Text(
                text = " min",
                style = MaterialTheme.typography.labelSmall,
                color = Gray400,
                maxLines = 1,
                modifier = Modifier.alignByBaseline(),
            )
        }

        Text(
            text = "Avg: ${summary.averagePerDay} min/day",
            style = MaterialTheme.typography.labelSmall,
            color = Gray400,
            maxLines = 1,
        )
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun ActiveMinutesCardPreview() {
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
            ActiveMinutesCard(
                modifier = Modifier
                    .width(166.dp)
                    .height(122.dp)
                    .todayCard(),
            )
        }
    }
}
