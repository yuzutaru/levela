package com.yuzutaru.levela.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import com.yuzutaru.design.ui.theme.LevelaTheme

/**
 * A placeholder home screen.
 *
 * Stands in for the real main menu while it is built out: a blank, themed screen
 * with a centered "MainMenu" label, so the splash → onboarding → home navigation
 * can be verified end to end. Replace this with the real menu later.
 */
@Composable
fun MainMenuScreen(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = "MainMenu",
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.testTag("mainmenu.title"),
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun MainMenuScreenPreview() {
    LevelaTheme {
        MainMenuScreen()
    }
}
