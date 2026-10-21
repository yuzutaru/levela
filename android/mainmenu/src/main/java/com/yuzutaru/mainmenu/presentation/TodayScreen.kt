package com.yuzutaru.mainmenu.presentation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.White
import com.yuzutaru.mainmenu.presentation.model.TodayTokens
import com.yuzutaru.mainmenu.presentation.widget.EndFastingButton
import com.yuzutaru.mainmenu.presentation.widget.FastingRing
import com.yuzutaru.mainmenu.presentation.widget.FastingTimes
import com.yuzutaru.mainmenu.presentation.widget.PhaseBanner
import com.yuzutaru.summary.presentation.widget.SummaryCards

private const val CardMinHeightFraction = 0.30f
private val HorizontalPadding = 24.dp
private val TopPadding = 8.dp
private val CardSpacing = 24.dp
private val FastingSpacing = 24.dp
private val BottomPadding = 24.dp

/**
 * The Today destination: a large top-left heading over the shared summary card
 * row (nutrition summary, steps and active minutes) and, below it, the fasting
 * view — the phase banner, the fasting ring, the start/end times and the
 * end-fasting action.
 *
 * The screen scrolls: the fasting view sits below the fold of the summary cards.
 * The splash-style background is drawn by the app shell behind the content;
 * this view only paints content.
 */
@Composable
fun TodayScreen(modifier: Modifier = Modifier) {
    BoxWithConstraints(modifier = modifier.fillMaxSize()) {
        val cardMinHeight = maxHeight * CardMinHeightFraction

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = HorizontalPadding)
                .padding(top = TopPadding, bottom = BottomPadding),
        ) {
            Text(
                text = TodayTokens.Title,
                style = MaterialTheme.typography.displaySmall,
                color = Navy900,
                modifier = Modifier.testTag(TodayTokens.ScreenTag),
            )

            Spacer(Modifier.height(CardSpacing))

            SummaryCards(minHeight = cardMinHeight)

            Spacer(Modifier.height(FastingSpacing))

            FastingSection()
        }
    }
}

@Composable
private fun FastingSection(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        PhaseBanner()
        FastingRing()
        FastingTimes()
        EndFastingButton()
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun TodayScreenPreview() {
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
                },
        ) {
            TodayScreen()
        }
    }
}
