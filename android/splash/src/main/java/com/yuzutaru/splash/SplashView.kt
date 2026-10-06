package com.yuzutaru.splash

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import kotlinx.coroutines.delay

/**
 * The Levela splash (launch welcome) screen.
 *
 * Auto-advances through the [SplashStage]s in [SplashTokens]; the Login /
 * Register / guest actions are visual only for now, and the whole flow reports
 * completion through [onFinished] so the app can wire navigation later.
 *
 * Mirrors the iOS `SplashView`.
 */
@Composable
fun SplashView(
    modifier: Modifier = Modifier,
    onFinished: () -> Unit = {},
    viewModel: SplashViewModel = remember { SplashViewModel() },
) {
    val stage = viewModel.stage
    val currentOnFinished by rememberUpdatedState(onFinished)

    // Advance through the timed stages once, then report completion.
    LaunchedEffect(viewModel) {
        while (true) {
            val delayMs = viewModel.nextDelayMs() ?: break
            delay(delayMs)
            viewModel.advance()
        }
        currentOnFinished()
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .drawBehind {
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
            }
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(Modifier.weight(1f))

            Image(
                painter = painterResource(R.drawable.ic_splash_logo),
                contentDescription = null,
                modifier = Modifier.size(SplashTokens.LogoSize),
            )

            AnimatedVisibility(
                visible = stage != SplashStage.Brand,
                enter = fadeIn(),
                exit = fadeOut(),
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Spacer(Modifier.height(24.dp))
                    SplashTitle()
                }
            }

            Spacer(Modifier.weight(1f))

            AnimatedVisibility(
                visible = stage == SplashStage.Actions,
                enter = fadeIn(),
                exit = fadeOut(),
            ) {
                SplashActions(
                    onLogin = {},
                    onRegister = {},
                    onGuest = {},
                )
            }
        }
    }
}

@Composable
private fun SplashTitle() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = SplashTokens.TitleLine1,
            style = MaterialTheme.typography.headlineMedium,
            color = SplashTokens.Title,
            textAlign = TextAlign.Center,
        )
        Text(
            text = SplashTokens.TitleLine2,
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
            color = SplashTokens.Title,
            textAlign = TextAlign.Center,
        )
    }
}

@Composable
private fun SplashActions(
    onLogin: () -> Unit,
    onRegister: () -> Unit,
    onGuest: () -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        SplashButton(
            text = SplashTokens.Login,
            background = SplashTokens.LoginBackground,
            textColor = SplashTokens.LoginText,
            onClick = onLogin,
        )
        Spacer(Modifier.height(12.dp))
        SplashButton(
            text = SplashTokens.Register,
            background = SplashTokens.RegisterBackground,
            textColor = SplashTokens.RegisterText,
            onClick = onRegister,
        )
        Spacer(Modifier.height(18.dp))
        Text(
            text = SplashTokens.Guest,
            style = MaterialTheme.typography.labelMedium,
            color = SplashTokens.GuestText,
            textDecoration = TextDecoration.Underline,
            modifier = Modifier
                .clickable(onClick = onGuest)
                .padding(4.dp),
        )
    }
}

@Composable
private fun SplashButton(
    text: String,
    background: Color,
    textColor: Color,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(percent = 50))
            .background(background)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelLarge,
            color = textColor,
        )
    }
}

@Preview(showBackground = true)
@Composable
private fun SplashViewPreview() {
    LevelaTheme {
        SplashView()
    }
}
