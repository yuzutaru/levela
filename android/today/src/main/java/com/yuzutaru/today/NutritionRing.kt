package com.yuzutaru.today

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.Green500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.White

private val PreviewCardCorner = 28.dp
private val PreviewCardElevation = 12.dp
private val RingDiameter = 92.dp
private val RingStroke = 9.dp

/**
 * The progress ring: one arc per macro, sized by that macro's share of the
 * total grams consumed so the three arcs close the circle.
 */
@Composable
internal fun NutritionRing(
    summary: NutritionSummary,
    modifier: Modifier = Modifier,
) {
    val totalConsumed = summary.macros.sumOf { it.consumed }.toFloat()

    Box(
        modifier = modifier
            .size(RingDiameter)
            .padding(16.dp),
        contentAlignment = Alignment.Center,
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val strokeWidth = RingStroke.toPx()
            val inset = strokeWidth / 2
            drawCircle(
                color = Gray200,
                radius = size.minDimension / 2 - inset,
                style = Stroke(width = strokeWidth),
            )

            var startAngle = -90f
            summary.macros.forEach { macro ->
                val fraction = if (totalConsumed > 0f) macro.consumed / totalConsumed else 0f
                val sweep = fraction * 360f
                drawArc(
                    color = macro.color,
                    startAngle = startAngle,
                    sweepAngle = sweep,
                    useCenter = false,
                    topLeft = Offset(inset, inset),
                    size = Size(size.width - strokeWidth, size.height - strokeWidth),
                    style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
                )
                startAngle += sweep
            }
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = summary.dayLabel,
                fontSize = 10.sp,
                color = Gray500,
            )
            Text(
                text = "${summary.percentComplete}%",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Navy900,
            )
            Text(
                text = "+${summary.deltaPercent}%",
                fontSize = 11.sp,
                color = Green500,
            )
        }
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun NutritionRingPreview() {
    LevelaTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .drawBehind {
                    drawRect(White)
                    drawRect(
                        Brush.radialGradient(
                            colors = listOf(
                                LightBlue300.copy(alpha = 0.55f),
                                Color.Transparent
                            ),
                            center = Offset(size.width / 2f, -size.height * 0.08f),
                            radius = size.width * 1.1f,
                        )
                    )
                }
                .padding(24.dp),
        ) {
            NutritionRing(
                summary = NutritionSummary(),
                modifier = Modifier
                    .size(124.dp)
                    .shadow(
                        elevation = PreviewCardElevation,
                        shape = RoundedCornerShape(PreviewCardCorner),
                        clip = false,
                    )
                    .clip(RoundedCornerShape(PreviewCardCorner))
                    .background(White),
            )
        }
    }
}
