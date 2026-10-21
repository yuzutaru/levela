package com.yuzutaru.today.presentation.widget

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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.geometry.Offset
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

/** The mock nutrition summary shown for Day 8 (placeholder until data lands). */
internal data class NutritionSummary(
    val dayLabel: String = "Day 8",
    val consumedCalories: String = "1,320",
    val dailyCalories: String = "2,300",
    val percentComplete: Int = 64,
    val deltaPercent: Int = 3,
    val macros: List<MacroSummary> = listOf(
        MacroSummary("Carbs", 112, 240, Orange500),
        MacroSummary("Proteins", 48, 140, Pink500),
        MacroSummary("Fats", 32, 110, Teal500),
    ),
)

internal data class MacroSummary(
    val label: String,
    val consumed: Int,
    val daily: Int,
    val color: Color,
)

@Composable
internal fun NutritionSummaryCard(
    modifier: Modifier = Modifier,
    summary: NutritionSummary = NutritionSummary(),
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
