package com.yuzutaru.onboarding.widget

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.OnboardingTokens

/**
 * A two-option pill toggle (e.g. `lb` / `kg`). The selected option is filled
 * with the primary (navy) colour; the track uses the surface-variant grey.
 */
@Composable
fun UnitToggle(
    units: List<String>,
    selected: String,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(percent = 50))
            .background(OnboardingTokens.ToggleTrack)
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        units.forEach { unit ->
            val isSelected = unit == selected
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(percent = 50))
                    .background(
                        if (isSelected) OnboardingTokens.ToggleSelectedBackground else Color.Transparent
                    )
                    .clickable { onSelect(unit) }
                    .padding(horizontal = 18.dp, vertical = 8.dp),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = unit,
                    style = MaterialTheme.typography.labelMedium,
                    color = if (isSelected) {
                        OnboardingTokens.ToggleSelectedText
                    } else {
                        OnboardingTokens.ToggleUnselectedText
                    },
                )
            }
        }
    }
}

@Preview(name = "Light", showBackground = true)
@Composable
private fun UnitTogglePreviewLight() = UnitTogglePreviewContent()

@Preview(name = "Dark", showBackground = true, uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun UnitTogglePreviewDark() = UnitTogglePreviewContent()

@Composable
private fun UnitTogglePreviewContent() {
    LevelaTheme {
        var selected by remember { mutableStateOf(OnboardingTokens.defaultWeightUnit) }
        Box(modifier = Modifier.padding(16.dp)) {
            UnitToggle(
                units = OnboardingTokens.weightUnits,
                selected = selected,
                onSelect = { selected = it },
            )
        }
    }
}
