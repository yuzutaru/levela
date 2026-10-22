package com.yuzutaru.mainmenu.presentation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.White
import com.yuzutaru.mainmenu.presentation.model.NutritionTokens

/**
 * The Nutrition destination: a large top-left page title, like the Today
 * destination's "Overview" heading, over the page's content area.
 *
 * The content is empty for now — the nutrition widgets land with the nutrition
 * feature. The splash-style background is drawn by the app shell behind the
 * content; this view only paints content.
 */
@Composable
public fun NutritionScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = MenuPageLayout.HorizontalPadding)
            .padding(
                top = MenuPageLayout.TopPadding,
                bottom = MenuPageLayout.BottomPadding,
            ),
    ) {
        MenuPageTitle(
            text = NutritionTokens.Title,
            testTag = NutritionTokens.ScreenTag,
        )
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun NutritionScreenPreview() {
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
            NutritionScreen()
        }
    }
}
