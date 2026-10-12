package com.yuzutaru.onboarding

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme

/**
 * The segmented step indicator at the top of the onboarding flow: one segment
 * per step, completed/current segments filled with the active colour.
 */
@Composable
fun StepProgress(
    current: Int,
    count: Int,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
    ) {
        repeat(count) { index ->
            Box(
                modifier = Modifier
                    .width(32.dp)
                    .height(4.dp)
                    .clip(RoundedCornerShape(percent = 50))
                    .background(
                        if (index <= current) {
                            OnboardingTokens.ActiveSegment
                        } else {
                            OnboardingTokens.InactiveSegment
                        }
                    ),
            )
        }
    }
}

@Preview(name = "Light", showBackground = true)
@Composable
private fun StepProgressPreviewLight() = StepProgressPreviewContent()

@Preview(name = "Dark", showBackground = true, uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun StepProgressPreviewDark() = StepProgressPreviewContent()

@Composable
private fun StepProgressPreviewContent() {
    LevelaTheme {
        Box(modifier = Modifier.padding(16.dp)) {
            StepProgress(current = 3, count = OnboardingTokens.steps.size)
        }
    }
}
