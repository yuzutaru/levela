package com.yuzutaru.nutrition.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Blue500
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray400
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.design.ui.theme.LightBlue100
import com.yuzutaru.design.ui.theme.LightBlue300
import com.yuzutaru.design.ui.theme.Navy900
import com.yuzutaru.nutrition.presentation.model.FastingSummary
import androidx.compose.ui.tooling.preview.Preview

/**
 * The phase notification shown above the fasting ring: a soft info banner that
 * announces the body's current fasting phase.
 */
@Composable
fun PhaseBanner(
    summary: FastingSummary = FastingSummary(),
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(LightBlue100)
            .border(1.dp, LightBlue300, RoundedCornerShape(24.dp))
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            imageVector = Icons.Filled.AutoAwesome,
            contentDescription = null,
            tint = Blue500,
            modifier = Modifier.size(24.dp),
        )
        Spacer(Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = summary.phaseTitle,
                style = MaterialTheme.typography.titleMedium,
                color = Navy900,
            )
            Text(
                text = summary.phaseSubtitle,
                style = MaterialTheme.typography.bodySmall,
                color = Gray500,
            )
        }
        Icon(
            imageVector = Icons.Filled.Close,
            contentDescription = null,
            tint = Gray400,
            modifier = Modifier.size(18.dp),
        )
    }
}

@Preview(showBackground = true, widthDp = 393)
@Composable
private fun PhaseBannerPreview() {
    LevelaTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Gray100)
                .padding(24.dp),
        ) {
            PhaseBanner()
        }
    }
}
