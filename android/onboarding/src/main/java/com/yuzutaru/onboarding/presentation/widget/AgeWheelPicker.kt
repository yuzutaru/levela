package com.yuzutaru.onboarding.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import kotlinx.coroutines.launch
import kotlin.math.abs

/** Test tag for the row currently under the wheel's centre marker. */
const val AgeWheelValueTag: String = "onboarding:age:value"

/** Test tag for an age row; the centred row uses [AgeWheelValueTag] instead. */
fun ageWheelRowTag(value: Int): String = "onboarding:age:$value"

/**
 * A vertical, snapping wheel used by the age step.
 *
 * The selected age sits in the vertical centre in a solid primary card; the
 * neighbouring ages are progressively smaller and lighter, like a physical
 * wheel. Scrolling reports the age under the centre marker through
 * [onAgeChange]; tapping an age scrolls it to the centre. Mirrors the iOS
 * `AgeWheelPicker`.
 */
@Composable
internal fun AgeWheelPicker(
    age: Int,
    onAgeChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    range: IntRange = OnboardingTokens.ageMin..OnboardingTokens.ageMax,
) {
    val ages = remember(range) { range.toList() }
    val initialIndex = ages.indexOf(age).coerceAtLeast(0)
    val listState = rememberLazyListState(initialFirstVisibleItemIndex = initialIndex)
    val itemHeight = OnboardingTokens.ageWheelRowHeight.dp
    val scope = rememberCoroutineScope()

    // The item nearest the vertical centre of the viewport is the selected one.
    val centeredIndex by remember(listState) {
        derivedStateOf {
            val info = listState.layoutInfo
            val center = (info.viewportStartOffset + info.viewportEndOffset) / 2
            info.visibleItemsInfo
                .minByOrNull { abs(it.offset + it.size / 2 - center) }
                ?.index
        }
    }

    // Report the centred age as the wheel settles. Ignored when it already
    // matches, so the external-sync effect below never fights a drag.
    LaunchedEffect(centeredIndex) {
        val value = centeredIndex?.let(ages::getOrNull) ?: return@LaunchedEffect
        if (value != age) onAgeChange(value)
    }

    // Keep an externally changed age centred (e.g. a tap on a distant row).
    LaunchedEffect(age) {
        val target = ages.indexOf(age)
        if (target >= 0 && centeredIndex != target) {
            listState.animateScrollToItem(target)
        }
    }

    LazyColumn(
        state = listState,
        modifier = modifier
            .fillMaxWidth()
            .height(itemHeight * OnboardingTokens.ageWheelVisibleRows),
        contentPadding = PaddingValues(
            vertical = itemHeight * ((OnboardingTokens.ageWheelVisibleRows - 1) / 2),
        ),
        flingBehavior = rememberSnapFlingBehavior(lazyListState = listState),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        itemsIndexed(ages) { index, value ->
            AgeWheelRow(
                value = value,
                distance = abs(value - age),
                isSelected = value == age,
                onSelect = { scope.launch { listState.animateScrollToItem(index) } },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(itemHeight),
            )
        }
    }
}

/**
 * One age in the wheel. The selected value is the large primary card; the
 * others shrink and fade with their distance from the centre.
 */
@Composable
private fun AgeWheelRow(
    value: Int,
    distance: Int,
    isSelected: Boolean,
    onSelect: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val style: TextStyle = when (distance) {
        0 -> MaterialTheme.typography.displayLarge
        1 -> MaterialTheme.typography.displaySmall
        2 -> MaterialTheme.typography.headlineSmall
        else -> MaterialTheme.typography.titleSmall
    }
    val color: Color = when (distance) {
        0 -> OnboardingTokens.AgeWheelSelectedText
        1 -> OnboardingTokens.AgeWheelText
        else -> OnboardingTokens.AgeWheelFadedText
    }
    val opacity = when (distance) {
        0, 1 -> 1f
        2 -> 0.9f
        else -> 0.5f
    }
    val interactionSource = remember { MutableInteractionSource() }

    Box(
        modifier = modifier
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onSelect,
            )
            .testTag(if (isSelected) AgeWheelValueTag else ageWheelRowTag(value))
            .semantics(mergeDescendants = true) { selected = isSelected },
        contentAlignment = Alignment.Center,
    ) {
        if (isSelected) {
            // A soft halo behind the solid card, so the selection reads as
            // raised without leaving the palette.
            Box(
                modifier = Modifier
                    .size(width = 132.dp, height = 124.dp)
                    .clip(RoundedCornerShape(30.dp))
                    .background(OnboardingTokens.AgeWheelSelectedBackground.copy(alpha = 0.18f)),
            )
            Box(
                modifier = Modifier
                    .size(width = 120.dp, height = 112.dp)
                    .clip(RoundedCornerShape(OnboardingTokens.ageWheelCorner.dp))
                    .background(OnboardingTokens.AgeWheelSelectedBackground),
            )
        }

        Text(
            text = value.toString(),
            style = style,
            color = color,
            modifier = Modifier.alpha(opacity),
        )
    }
}

@Preview(showBackground = true, heightDp = 640)
@Composable
private fun AgeWheelPickerPreview() {
    LevelaTheme {
        var age by remember { mutableIntStateOf(OnboardingTokens.ageDefault) }
        AgeWheelPicker(age = age, onAgeChange = { age = it })
    }
}
