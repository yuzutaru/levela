package com.yuzutaru.nutrition.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray400
import com.yuzutaru.design.ui.theme.Green100
import com.yuzutaru.design.ui.theme.Green500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.nutrition.presentation.model.FastingSummary

/**
 * The fast's start and end times, each with a small edit affordance. The values
 * are read-only for now — the mock does not wire an editor.
 */
@Composable
public fun FastingTimes(
    summary: FastingSummary = FastingSummary(),
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        TimeColumn(
            label = "START",
            value = summary.startLabel,
            alignment = Alignment.Start,
        )
        TimeColumn(
            label = "END",
            value = summary.endLabel,
            alignment = Alignment.End,
        )
    }
}

@Composable
private fun TimeColumn(
    label: String,
    value: String,
    alignment: Alignment.Horizontal,
) {
    Column(horizontalAlignment = alignment) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = Gray400,
        )
        Spacer(Modifier.height(4.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = value,
                style = MaterialTheme.typography.titleMedium,
                color = Navy900,
                maxLines = 1,
            )
            Spacer(Modifier.width(6.dp))
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(Green100),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = Icons.Filled.Edit,
                    contentDescription = null,
                    tint = Green500,
                    modifier = Modifier.size(15.dp),
                )
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 393)
@Composable
private fun FastingTimesPreview() {
    LevelaTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Gray100)
                .padding(24.dp),
        ) {
            FastingTimes()
        }
    }
}
