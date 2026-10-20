package com.yuzutaru.levela.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.splash.SplashTokens

private const val Title = "Overview"
private const val CardWidthFraction = 0.50f
private const val CardHeightFraction = 0.30f
private val HorizontalPadding = 24.dp
private val TopPadding = 8.dp
private val CardSpacing = 24.dp
private val CardCorner = 28.dp
private val CardShadow = 12.dp
private val CardShape = RoundedCornerShape(CardCorner)

/**
 * The Today destination: a large top-left heading over one empty card.
 *
 * The card is intentionally blank — it is the shell for the workout summary
 * that lands later. The menu's splash-style background lives in
 * [MainMenuScreen], so this screen only paints content.
 */
@Composable
internal fun TodayScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .padding(horizontal = HorizontalPadding)
            .padding(top = TopPadding),
    ) {
        Text(
            text = Title,
            style = MaterialTheme.typography.displaySmall,
            color = SplashTokens.Title,
            modifier = Modifier.testTag(MainMenuTab.Today.screenTag),
        )

        Spacer(Modifier.height(CardSpacing))

        Box(
            modifier = Modifier
                .fillMaxWidth(CardWidthFraction)
                .fillMaxHeight(CardHeightFraction)
                .shadow(elevation = CardShadow, shape = CardShape, clip = false)
                .clip(CardShape)
                .background(Color.White),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun TodayScreenPreview() {
    LevelaTheme {
        Box {
            MenuBackground(Modifier.matchParentSize())
            TodayScreen()
        }
    }
}
