package com.yuzutaru.mainmenu.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.mainmenu.presentation.widget.EndFastingButton
import com.yuzutaru.mainmenu.presentation.widget.FastingRing
import com.yuzutaru.mainmenu.presentation.widget.FastingTimes
import com.yuzutaru.mainmenu.presentation.widget.PhaseBanner
import com.yuzutaru.summary.presentation.widget.summaryCard

private val CardPadding = 20.dp
private val SectionSpacing = 16.dp

/**
 * The fasting view: the phase banner, the fasting ring, the start/end times and
 * the end-fasting action.
 *
 * Lives below the summary cards on the Today screen, inside the same white card
 * chrome the summary row uses ([summaryCard]); the shared splash-style
 * background is drawn by the app shell behind the content.
 */
@Composable
public fun FastingSection(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .summaryCard()
            .padding(CardPadding),
        verticalArrangement = Arrangement.spacedBy(SectionSpacing),
    ) {
        PhaseBanner()
        FastingRing()
        FastingTimes()
        EndFastingButton()
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 720)
@Composable
private fun FastingSectionPreview() {
    LevelaTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(LightBlue100)
                .padding(24.dp),
        ) {
            FastingSection()
        }
    }
}
