package com.yuzutaru.levela.presentation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.outlined.FitnessCenter
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Restaurant
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.splash.SplashTokens

/**
 * The app's bottom-navigation destinations, in left-to-right order.
 *
 * Each destination is still a placeholder — a blank, themed screen with a large
 * centered title — until the real feature screens land. The navigation shell
 * itself is final.
 */
internal enum class MainMenuTab(
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
) {
    Today("Today", Icons.Filled.Home, Icons.Outlined.Home),
    Nutrition("Nutrition", Icons.Filled.Restaurant, Icons.Outlined.Restaurant),
    Train("Train", Icons.Filled.FitnessCenter, Icons.Outlined.FitnessCenter),
    Profile("Profile", Icons.Filled.Person, Icons.Outlined.Person),
    ;

    /** Stable test tag for the destination's centered title. */
    val screenTag: String get() = "mainmenu.${name.lowercase()}"

    /** Stable test tag for this destination's navigation-bar item. */
    val itemTag: String get() = "mainmenu.tab.${name.lowercase()}"
}

/**
 * The post-onboarding main menu: a Material 3 bottom navigation bar over four
 * destinations, sharing the splash-style background. Today is the landing
 * destination.
 */
@Composable
fun MainMenuScreen(modifier: Modifier = Modifier) {
    var selectedTab by rememberSaveable { mutableStateOf(MainMenuTab.Today) }

    Box(modifier = modifier.fillMaxSize()) {
        MenuBackground(Modifier.matchParentSize())

        Scaffold(
            modifier = Modifier.fillMaxSize(),
            containerColor = Color.Transparent,
            bottomBar = {
                NavigationBar(
                    containerColor = Color.Transparent,
                    tonalElevation = 0.dp,
                ) {
                    MainMenuTab.entries.forEach { tab ->
                        val selected = tab == selectedTab
                        NavigationBarItem(
                            selected = selected,
                            onClick = { selectedTab = tab },
                            icon = {
                                Icon(
                                    imageVector = if (selected) {
                                        tab.selectedIcon
                                    } else {
                                        tab.unselectedIcon
                                    },
                                    contentDescription = tab.label,
                                )
                            },
                            label = { Text(tab.label) },
                            modifier = Modifier.testTag(tab.itemTag),
                        )
                    }
                }
            },
        ) { innerPadding ->
            MainMenuDestination(
                tab = selectedTab,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
            )
        }
    }
}

/**
 * The splash-style background shared by every main-menu destination: a white →
 * light-blue vertical gradient with a radial glow at the top.
 */
@Composable
internal fun MenuBackground(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier.drawBehind {
            drawRect(Brush.verticalGradient(SplashTokens.BackgroundGradient))
            drawRect(
                Brush.radialGradient(
                    colors = listOf(
                        SplashTokens.BackgroundGlow.copy(alpha = 0.55f),
                        Color.Transparent,
                    ),
                    center = Offset(size.width / 2f, -size.height * 0.08f),
                    radius = size.width * 1.1f,
                )
            )
        },
    )
}

/**
 * The destination content: the Today screen, or a placeholder for the tabs
 * whose real screens have not landed yet.
 */
@Composable
private fun MainMenuDestination(tab: MainMenuTab, modifier: Modifier = Modifier) {
    when (tab) {
        MainMenuTab.Today -> TodayScreen(modifier)
        else -> PlaceholderDestination(tab = tab, modifier = modifier)
    }
}

/** The blank placeholder for a destination, differentiated by its big title. */
@Composable
private fun PlaceholderDestination(tab: MainMenuTab, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = tab.label,
            style = MaterialTheme.typography.displaySmall,
            color = SplashTokens.Title,
            modifier = Modifier.testTag(tab.screenTag),
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
