package com.yuzutaru.design.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

// Icon-derived schemes (see ../THEME_COLORS.md): white light background,
// blue/green/orange accents, deep-navy dark theme.
private val LightColorScheme = lightColorScheme(
    primary = Blue500,
    onPrimary = White,
    secondary = Green500,
    onSecondary = White,
    tertiary = Orange500,
    onTertiary = Navy900,
    background = White,
    onBackground = Navy900,
    surface = White,
    onSurface = Navy900,
    surfaceVariant = Gray100,
    onSurfaceVariant = Gray700,
    outline = Gray200
)

private val DarkColorScheme = darkColorScheme(
    primary = Blue300,
    onPrimary = Navy900,
    secondary = Green300,
    onSecondary = Navy900,
    tertiary = Orange300,
    onTertiary = Navy900,
    background = Navy900,
    onBackground = Ink100,
    surface = Navy800,
    onSurface = Ink100,
    surfaceVariant = Navy700,
    onSurfaceVariant = Gray300,
    outline = Gray700
)

@Composable
fun LevelaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Off by default so the app matches the icon on every device. Set true to
    // opt into Material You dynamic colour on Android 12+.
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
