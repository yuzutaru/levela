package com.yuzutaru.summary.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.yuzutaru.design.ui.theme.Gray400
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.design.ui.theme.Orange500
import com.yuzutaru.design.ui.theme.Pink500
import com.yuzutaru.design.ui.theme.Teal500
import com.yuzutaru.design.ui.theme.White

private val PreviewCardCorner = 28.dp
private val PreviewCardElevation = 12.dp
private val WideRingSpacing = 16.dp
private val WideMacroSpacing = 12.dp

/** How the card arranges its content. */
public enum class NutritionSummaryLayout {
    /** The original short stack, for the Today destination's half-width card. */
    Stacked,

    /** The wide row — ring on the left, per-macro detail on the right. */
    Wide,
}

/** The mock nutrition summary shown for Day 8 (placeholder until data lands). */
public data class NutritionSummary(
    public val dayLabel: String = "Day 8",
    public val consumedCalories: String = "1,320",
    public val dailyCalories: String = "2,300",
    public val percentComplete: Int = 64,
    public val deltaPercent: Int = 3,
    public val macros: List<MacroSummary> = listOf(
        MacroSummary("Carbs", 112, 240, Orange500),
        MacroSummary("Proteins", 48, 140, Pink500),
        MacroSummary("Fats", 32, 110, Teal500),
    ),
)

public data class MacroSummary(
    public val label: String,
    public val consumed: Int,
    public val daily: Int,
    public val color: Color,
)

/**
 * The nutrition summary card.
 *
 * [layout] picks the arrangement: [NutritionSummaryLayout.Stacked] (the default)
 * keeps the original short stack for the Today destination's half-width card;
 * [NutritionSummaryLayout.Wide] is the reference design for the Nutrition
 * destination's full-width card — a calorie header, then the ring on the left
 * with the per-macro detail (vertical colour bar + consumed / daily weight) on
 * the right. Both layouts share the calorie header (flame icon + values).
 */
@Composable
public fun NutritionSummaryCard(
    modifier: Modifier = Modifier,
    summary: NutritionSummary = NutritionSummary(),
    layout: NutritionSummaryLayout = NutritionSummaryLayout.Stacked,
) {
    if (layout == NutritionSummaryLayout.Wide) {
        WideNutritionSummaryCard(summary, modifier)
    } else {
        StackedNutritionSummaryCard(summary, modifier)
    }
}

@Composable
private fun StackedNutritionSummaryCard(
    summary: NutritionSummary,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        CalorieHeader(summary)

        NutritionRing(
            summary = summary,
            modifier = Modifier.align(Alignment.CenterHorizontally)
                .padding(start = 16.dp, end = 16.dp),
        )

        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            summary.macros.forEach { macro ->
                MacroRow(macro)
            }
        }
    }
}

@Composable
private fun WideNutritionSummaryCard(
    summary: NutritionSummary,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        CalorieHeader(summary)

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(WideRingSpacing),
        ) {
            NutritionRing(
                summary = summary,
                modifier = Modifier.weight(1.1f),
            )

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(WideMacroSpacing),
            ) {
                summary.macros.forEach { macro ->
                    MacroDetail(macro)
                }
            }
        }
    }
}

@Composable
private fun MacroDetail(macro: MacroSummary) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Box(
            modifier = Modifier
                .size(width = 3.dp, height = 40.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(macro.color),
        )
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(
                text = macro.label,
                fontSize = 11.sp,
                color = Gray500,
                maxLines = 1,
            )
            Row {
                Text(
                    text = "${macro.consumed}",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Navy900,
                    maxLines = 1,
                )
                Text(
                    text = " / ${macro.daily}g",
                    fontSize = 11.sp,
                    color = Gray500,
                    maxLines = 1,
                )
            }
        }
    }
}

@Composable
private fun CalorieHeader(summary: NutritionSummary) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(
            imageVector = Icons.Filled.LocalFireDepartment,
            contentDescription = null,
            tint = Orange500,
            modifier = Modifier.size(14.dp),
        )
        Spacer(Modifier.width(4.dp))
        Text(
            text = summary.consumedCalories,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold,
            color = Navy900,
            maxLines = 1,
        )
        Text(
            text = " / ${summary.dailyCalories} kcal",
            fontSize = 11.sp,
            color = Gray500,
            maxLines = 1,
        )
    }
}

@Composable
private fun MacroRow(macro: MacroSummary) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(width = 16.dp, height = 3.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(macro.color),
        )
        Spacer(Modifier.width(6.dp))
        Text(
            text = macro.label,
            fontSize = 11.sp,
            color = Gray500,
            modifier = Modifier.weight(1f),
            maxLines = 1,
        )
        Text(
            text = "${macro.consumed} / ${macro.daily}",
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            color = Navy900,
            maxLines = 1,
        )
        Text(
            text = " g",
            fontSize = 10.sp,
            color = Gray400,
            maxLines = 1,
        )
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 500)
@Composable
private fun NutritionSummaryCardWidePreview() {
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
                }
                .padding(horizontal = 24.dp, vertical = 8.dp),
        ) {
            NutritionSummaryCard(
                summary = NutritionSummary(
                    consumedCalories = "1.320",
                    dailyCalories = "2300",
                ),
                layout = NutritionSummaryLayout.Wide,
                modifier = Modifier
                    .fillMaxWidth()
                    .summaryCard(),
            )
        }
    }
}

@Preview(showBackground = true, widthDp = 393, heightDp = 852)
@Composable
private fun NutritionSummaryCardPreview() {
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
                }
                .padding(24.dp),
        ) {
            NutritionSummaryCard(
                modifier = Modifier
                    .width(197.dp)
                    .heightIn(min = 256.dp)
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
