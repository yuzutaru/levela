package com.yuzutaru.onboarding

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray200

/** The primary pill button shared by the onboarding steps. */
@Composable
internal fun NextButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    showChevrons: Boolean = true,
    enabled: Boolean = true,
) {
    Row(
        modifier = modifier
            .height(56.dp)
            .clip(RoundedCornerShape(percent = 50))
            .background(
                if (enabled) OnboardingTokens.NextBackground else OnboardingTokens.NextDisabledBackground
            )
            .clickable(enabled = enabled, onClick = onClick)
            .padding(horizontal = 24.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelLarge,
            color = if (enabled) OnboardingTokens.NextText else OnboardingTokens.NextDisabledText,
        )
        if (showChevrons) {
            Spacer(Modifier.width(10.dp))
            Chevrons(
                color = if (enabled) OnboardingTokens.NextText else OnboardingTokens.NextDisabledText,
                count = 3,
            )
        }
    }
}

/** The circular outlined back button shared by the onboarding steps. */
@Composable
internal fun BackButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .size(56.dp)
            .clip(CircleShape)
            .background(OnboardingTokens.Background)
            .border(1.dp, Gray200, CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Chevron(color = OnboardingTokens.Title, direction = -1)
    }
}

@Composable
private fun Chevrons(
    color: Color,
    count: Int,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(count) { Chevron(color = color, direction = 1) }
    }
}

/** Draws a single chevron; [direction] > 0 points right, otherwise left. */
@Composable
private fun Chevron(
    color: Color,
    direction: Int,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier.size(width = 6.dp, height = 11.dp)) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            if (direction >= 0) {
                moveTo(0f, 0f)
                lineTo(w, h / 2f)
                lineTo(0f, h)
            } else {
                moveTo(w, 0f)
                lineTo(0f, h / 2f)
                lineTo(w, h)
            }
        }
        drawPath(
            path = path,
            color = color,
            style = Stroke(
                width = 1.6.dp.toPx(),
                cap = StrokeCap.Round,
                join = StrokeJoin.Round,
            ),
        )
    }
}
