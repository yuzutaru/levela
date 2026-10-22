package com.yuzutaru.mainmenu.presentation

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Navy900

/**
 * The shared page chrome of the main-menu destinations: the page padding and
 * the large top-left heading.
 *
 * Every destination titles itself the same way, so the heading treatment lives
 * here instead of being repeated per screen.
 */
public object MenuPageLayout {
    /** The page's horizontal padding. */
    public val HorizontalPadding: Dp = 24.dp

    /** The page's top padding, below the status bar. */
    public val TopPadding: Dp = 8.dp

    /** The page's bottom padding, above the navigation bar. */
    public val BottomPadding: Dp = 24.dp
}

/**
 * The large top-left page title of a main-menu destination.
 *
 * @param text the title copy.
 * @param testTag the stable test tag for the title.
 */
@Composable
public fun MenuPageTitle(
    text: String,
    testTag: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = text,
        style = MaterialTheme.typography.displaySmall,
        color = Navy900,
        modifier = modifier.testTag(testTag),
    )
}
