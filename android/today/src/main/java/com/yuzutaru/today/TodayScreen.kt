package com.yuzutaru.today

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
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

private const val CardWidthFraction = 0.50f
private const val CardMinHeightFraction = 0.30f
private val HorizontalPadding = 24.dp
private val TopPadding = 8.dp
private val CardSpacing = 24.dp
private val CardCorner = 28.dp
private val CardElevation = 12.dp

/**
 * The Today destination: a large top-left heading over a half-width nutrition
 * summary card. The card grows with its content but never drops below 30% of
 * the available height, and the right half of the screen stays empty.
 *
 * The splash-style background is drawn by the app shell behind the content;
 * this view only paints content.
 */
@Composable
fun TodayScreen(modifier: Modifier = Modifier) {
    BoxWithConstraints(modifier = modifier.fillMaxSize()) {
        val cardWidth = maxWidth * CardWidthFraction
        val cardMinHeight = maxHeight * CardMinHeightFraction

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = HorizontalPadding)
                .padding(top = TopPadding),
        ) {
            Text(
                text = TodayTokens.Title,
                style = MaterialTheme.typography.displaySmall,
                color = Navy900,
                modifier = Modifier.testTag(TodayTokens.ScreenTag),
            )

            Spacer(Modifier.height(CardSpacing))

            NutritionSummaryCard(
                modifier = Modifier
                    .width(cardWidth)
                    .heightIn(min = cardMinHeight)
                    .shadow(
                        elevation = CardElevation,
                        shape = RoundedCornerShape(CardCorner),
                        clip = false,
                    )
                    .clip(RoundedCornerShape(CardCorner))
                    .background(White),
            )
        }
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
