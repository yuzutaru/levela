package com.yyzutaru.levela.presentation

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.splash.SplashTokens

private const val Title = "Overview"

@Composable
internal fun TodayScreen(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .padding(24),
    ) {
        Text(
            text = Title,
            style = MaterialTheme.typography.displaySmall,
            color = SplashTokens.Title,
        )

        Box(
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(
                text = "Nutrition Summary",
                style = MaterialTheme.typography.bodyMedium,
                color = Color.Gray,
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun TodayScreenPreview() {
    LevelaTheme {
        Box {
            TodayScreen()
        }
    }
}