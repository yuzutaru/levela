package com.yuzutaru.nutrition.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray100
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.Gray500
import com.yuzutaru.design.ui.theme.LevelaTheme

/** The full-width "End Fasting" action. Visual-only for now. */
@Composable
fun EndFastingButton(
    modifier: Modifier = Modifier,
    label: String = "End Fasting",
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(Gray200),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.titleMedium,
            color = Gray500,
        )
    }
}

@Preview(showBackground = true, widthDp = 393)
@Composable
private fun EndFastingButtonPreview() {
    LevelaTheme {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Gray100)
                .padding(24.dp),
        ) {
            EndFastingButton()
        }
    }
}
