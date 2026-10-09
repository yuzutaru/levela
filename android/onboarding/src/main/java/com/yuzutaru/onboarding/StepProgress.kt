package com.yuzutaru.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp

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
