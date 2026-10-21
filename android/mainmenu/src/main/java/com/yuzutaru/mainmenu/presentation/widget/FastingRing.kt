package com.yuzutaru.mainmenu.presentation.widget

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FastForward
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.WaterDrop
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.Gray400
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.Green500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.Orange300
import com.yuzutaru.design.ui.theme.Orange500
import com.yuzutaru.design.ui.theme.Pink500
import com.yuzutaru.design.ui.theme.White
import com.yuzutaru.mainmenu.presentation.model.FastingSummary
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

private val RingStroke = 16.dp
private val BadgeSize = 56.dp
private val MarkerSize = 26.dp

/**
 * The fasting progress ring: an elapsed arc (green → orange) over a pale track,
 * with the current phase marked by a flame badge at the arc's leading edge. The
 * centre holds the elapsed label, the timer and a skip control.
 *
 * The arc starts at the bottom and sweeps clockwise through the left half to the
 * top, matching the design.
 */
@Composable
public fun FastingRing(
    summary: FastingSummary = FastingSummary(),
    modifier: Modifier = Modifier,
) {
    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(1f),
        contentAlignment = Alignment.Center,
    ) {
        val radius = maxWidth / 2 - RingStroke / 2
        // Start at 6 o'clock and sweep clockwise through the left half to the top.
        val sweepDegrees = summary.percentComplete.toFloat() / 100f * 360f
        val startAngle = 90f
        val endAngle = startAngle + sweepDegrees

        Canvas(modifier = Modifier.fillMaxSize()) {
            val strokePx = RingStroke.toPx()
            val inset = strokePx / 2
            drawCircle(
                color = Gray200,
                radius = size.minDimension / 2 - inset,
                style = Stroke(width = strokePx),
            )
            drawArc(
                brush = Brush.linearGradient(
                    colors = listOf(Green500, Orange300, Orange500),
                    start = Offset(0f, size.height),
                    end = Offset(0f, 0f),
                ),
                startAngle = startAngle,
                sweepAngle = sweepDegrees,
                useCenter = false,
                topLeft = Offset(inset, inset),
                size = Size(size.width - strokePx, size.height - strokePx),
                style = Stroke(width = strokePx, cap = StrokeCap.Round),
            )
        }

        // Stage markers around the ring: the fat-burn droplet and two phase
        // flames on the remaining track.
        RingMarker(angleDegrees = 150f, radius = radius, markerSize = MarkerSize) {
            Icon(
                imageVector = Icons.Filled.WaterDrop,
                contentDescription = null,
                tint = Pink500,
                modifier = Modifier.size(14.dp),
            )
        }
        RingMarker(angleDegrees = -55f, radius = radius, markerSize = MarkerSize) {
            Icon(
                imageVector = Icons.Filled.LocalFireDepartment,
                contentDescription = null,
                tint = Gray400,
                modifier = Modifier.size(14.dp),
            )
        }
        RingMarker(angleDegrees = 45f, radius = radius, markerSize = MarkerSize) {
            Icon(
                imageVector = Icons.Filled.LocalFireDepartment,
                contentDescription = null,
                tint = Gray400,
                modifier = Modifier.size(14.dp),
            )
        }

        // The current-position flame badge at the leading edge of the arc.
        RingMarker(
            angleDegrees = endAngle,
            radius = radius,
            markerSize = BadgeSize,
            borderColor = Orange500,
            borderWidth = 3.dp,
        ) {
            Icon(
                imageVector = Icons.Filled.LocalFireDepartment,
                contentDescription = null,
                tint = Orange500,
                modifier = Modifier.size(28.dp),
            )
        }

        Column(
            modifier = Modifier.fillMaxWidth(0.62f),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = "Elapsed time (${summary.percentComplete}%)",
                style = MaterialTheme.typography.bodyLarge,
                color = Gray500,
                textAlign = TextAlign.Center,
            )
            Text(
                text = summary.timer,
                style = MaterialTheme.typography.displayMedium,
                color = Navy900,
                maxLines = 1,
            )
            Spacer(Modifier.height(12.dp))
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(CircleShape)
                    .background(Gray100),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = Icons.Filled.FastForward,
                    contentDescription = null,
                    tint = Gray500,
                    modifier = Modifier.size(24.dp),
                )
            }
        }
    }
}

/** Places [content] on the ring's circumference at [angleDegrees] (0° = 3 o'clock). */
@Composable
private fun BoxScope.RingMarker(
    angleDegrees: Float,
    radius: Dp,
    markerSize: Dp,
    borderColor: Color = Gray200,
    borderWidth: Dp = 1.dp,
    content: @Composable () -> Unit,
) {
    val density = LocalDensity.current
    val radiusPx = with(density) { radius.toPx() }
    val radians = Math.toRadians(angleDegrees.toDouble())
    // The marker is center-aligned first, so the offset is just the displacement
    // from the ring's center to its circumference point.
    val dx = (radiusPx * cos(radians)).toFloat()
    val dy = (radiusPx * sin(radians)).toFloat()

    Box(
        modifier = Modifier
            .align(Alignment.Center)
            .offset { IntOffset(dx.roundToInt(), dy.roundToInt()) }
            .size(markerSize)
            .clip(CircleShape)
            .background(White)
            .border(borderWidth, borderColor, CircleShape),
        contentAlignment = Alignment.Center,
    ) {
        content()
    }
}

@Preview(showBackground = true, widthDp = 393)
@Composable
private fun FastingRingPreview() {
    LevelaTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(White)
                .padding(24.dp),
            contentAlignment = Alignment.Center,
        ) {
            FastingRing()
        }
    }
}
