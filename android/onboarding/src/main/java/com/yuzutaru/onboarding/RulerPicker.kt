package com.yuzutaru.onboarding

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.drawText
import androidx.compose.ui.text.rememberTextMeasurer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

/**
 * A draggable, snapping ruler used by the onboarding value cards.
 *
 * The value under the fixed centre marker is reported through [onValueChange]
 * live while dragging and re-committed, snapped to [step], on release. The
 * ruler resets its scroll position whenever the scale ([rangeStart] /
 * [rangeEnd] / [step]) changes, e.g. when the unit is switched.
 */
@Composable
fun RulerPicker(
    value: Int,
    rangeStart: Int,
    rangeEnd: Int,
    step: Int,
    onValueChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    tickSpacing: Dp = 14.dp,
    majorEvery: Int = 10,
    activeColor: Color = OnboardingTokens.Value,
    accentColor: Color = OnboardingTokens.CardWeightAccent,
    tickColor: Color = OnboardingTokens.RulerTick,
    labelColor: Color = OnboardingTokens.RulerLabel,
) {
    val tickCount = ((rangeEnd - rangeStart) / step).coerceAtLeast(1)
    val index = (value - rangeStart).toFloat() / step
    // Continuous position in tick units; re-keyed when the scale changes.
    var position by remember(rangeStart, rangeEnd, step) { mutableFloatStateOf(index) }

    val density = LocalDensity.current
    val spacingPx = with(density) { tickSpacing.toPx() }
    val textMeasurer = rememberTextMeasurer()
    val labelStyle = MaterialTheme.typography.labelSmall.copy(color = labelColor)
    val activeLabelStyle = MaterialTheme.typography.labelSmall.copy(color = activeColor)

    fun commit() {
        val snapped = position.roundToInt().coerceIn(0, tickCount)
        position = snapped.toFloat()
        onValueChange(rangeStart + snapped * step)
    }

    Canvas(
        modifier = modifier
            .fillMaxWidth()
            .height(78.dp)
            .pointerInput(rangeStart, rangeEnd, step, spacingPx) {
                detectHorizontalDragGestures(onDragEnd = { commit() }) { change, dragAmount ->
                    change.consume()
                    position = (position - dragAmount / spacingPx).coerceIn(0f, tickCount.toFloat())
                    val snapped = position.roundToInt().coerceIn(0, tickCount)
                    onValueChange(rangeStart + snapped * step)
                }
            },
    ) {
        val centerX = size.width / 2f
        val baseline = size.height * 0.62f
        val translate = centerX - (position * spacingPx + spacingPx / 2f)

        // Soft accent highlight behind the centre.
        val bandWidth = 48.dp.toPx()
        drawRoundRect(
            color = accentColor.copy(alpha = 0.55f),
            topLeft = Offset(centerX - bandWidth / 2f, 4.dp.toPx()),
            size = Size(bandWidth, size.height - 8.dp.toPx()),
            cornerRadius = CornerRadius(bandWidth / 2f, bandWidth / 2f),
        )

        val selected = position.roundToInt().coerceIn(0, tickCount)

        for (j in 0..tickCount) {
            val x = j * spacingPx + spacingPx / 2f + translate
            if (x < -spacingPx || x > size.width + spacingPx) continue

            val tickValue = rangeStart + j * step
            val isMajor = tickValue % majorEvery == 0
            val isCenter = j == selected

            val tickHeight = when {
                isCenter -> 34.dp.toPx()
                isMajor -> 22.dp.toPx()
                else -> 12.dp.toPx()
            }
            drawLine(
                color = if (isCenter) activeColor else tickColor,
                start = Offset(x, baseline - tickHeight),
                end = Offset(x, baseline),
                strokeWidth = (if (isCenter) 2.dp else 1.dp).toPx(),
            )

            if (isMajor || isCenter) {
                val layout = textMeasurer.measure(
                    text = tickValue.toString(),
                    style = if (isCenter) activeLabelStyle else labelStyle,
                )
                drawText(
                    textLayoutResult = layout,
                    topLeft = Offset(x - layout.size.width / 2f, baseline + 8.dp.toPx()),
                )
            }
        }

        // Fixed centre marker.
        drawLine(
            color = activeColor,
            start = Offset(centerX, baseline - 42.dp.toPx()),
            end = Offset(centerX, baseline + 2.dp.toPx()),
            strokeWidth = 2.dp.toPx(),
        )
    }
}
