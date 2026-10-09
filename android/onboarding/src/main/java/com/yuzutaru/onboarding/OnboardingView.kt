package com.yuzutaru.onboarding

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.LevelaTheme

/**
 * The Levela post-guest onboarding flow (weight, height).
 *
 * Shown after the user taps **Continue as a guest** on the splash. Two steps,
 * each with a draggable ruler picker and a unit toggle; the last step reports
 * completion through [onFinished]. Mirrors the iOS `OnboardingView`.
 *
 * @param onFinished called when the user taps Next on the final step.
 */
@Composable
fun OnboardingView(
    modifier: Modifier = Modifier,
    onFinished: () -> Unit = {},
    viewModel: OnboardingViewModel = remember { OnboardingViewModel() },
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(OnboardingTokens.Background)
            .systemBarsPadding()
            .padding(horizontal = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(20.dp))

        StepProgress(current = viewModel.stepIndex, count = viewModel.stepCount)

        Spacer(Modifier.height(28.dp))

        Text(
            text = when (viewModel.step) {
                OnboardingStep.Weight -> OnboardingTokens.WeightTitle
                OnboardingStep.Height -> OnboardingTokens.HeightTitle
            },
            style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
            color = OnboardingTokens.Title,
            textAlign = TextAlign.Center,
        )

        Spacer(Modifier.height(20.dp))

        when (viewModel.step) {
            OnboardingStep.Weight -> UnitToggle(
                units = OnboardingTokens.weightUnits,
                selected = viewModel.weightUnit,
                onSelect = viewModel::selectWeightUnit,
            )

            OnboardingStep.Height -> UnitToggle(
                units = OnboardingTokens.heightUnits,
                selected = viewModel.heightUnit,
                onSelect = viewModel::selectHeightUnit,
            )
        }

        Spacer(Modifier.height(28.dp))

        when (viewModel.step) {
            OnboardingStep.Weight -> ValueCard(
                value = viewModel.weightDisplay,
                unit = viewModel.weightUnit,
                scale = weightScale(viewModel.weightUnit),
                onValueChange = viewModel::setWeightDisplay,
                background = OnboardingTokens.CardWeight,
                accent = OnboardingTokens.CardWeightAccent,
            )

            OnboardingStep.Height -> ValueCard(
                value = viewModel.heightDisplay,
                unit = viewModel.heightUnit,
                scale = heightScale(viewModel.heightUnit),
                onValueChange = viewModel::setHeightDisplay,
                background = OnboardingTokens.CardHeight,
                accent = OnboardingTokens.CardHeightAccent,
            )
        }

        Spacer(Modifier.weight(1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            BackButton(onClick = viewModel::back)
            Spacer(Modifier.width(12.dp))
            NextButton(
                label = OnboardingTokens.Next,
                onClick = {
                    if (viewModel.isLastStep) onFinished() else viewModel.next()
                },
                modifier = Modifier.weight(1f),
            )
        }

        Spacer(Modifier.height(24.dp))
    }
}

/** The tick scale for a value card, in the currently displayed unit. */
private data class Scale(val start: Int, val end: Int, val step: Int)

private fun weightScale(unit: String): Scale = when (unit) {
    "lb" -> Scale(OnboardingTokens.weightLbMin, OnboardingTokens.weightLbMax, OnboardingTokens.weightLbStep)
    else -> Scale(OnboardingTokens.weightKgMin, OnboardingTokens.weightKgMax, OnboardingTokens.weightKgStep)
}

private fun heightScale(unit: String): Scale = when (unit) {
    "inches" -> Scale(OnboardingTokens.heightInMin, OnboardingTokens.heightInMax, OnboardingTokens.heightInStep)
    else -> Scale(OnboardingTokens.heightCmMin, OnboardingTokens.heightCmMax, OnboardingTokens.heightCmStep)
}

@Composable
private fun ValueCard(
    value: Int,
    unit: String,
    scale: Scale,
    onValueChange: (Int) -> Unit,
    background: Color,
    accent: Color,
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(OnboardingTokens.CardCorner.dp))
            .background(background)
            .padding(vertical = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = value.toString(),
            style = MaterialTheme.typography.displayMedium.copy(fontWeight = FontWeight.Bold),
            color = OnboardingTokens.Value,
        )
        Spacer(Modifier.height(6.dp))
        RulerPicker(
            value = value,
            rangeStart = scale.start,
            rangeEnd = scale.end,
            step = scale.step,
            onValueChange = onValueChange,
            accentColor = accent,
        )
        Spacer(Modifier.height(2.dp))
        Text(
            text = unit,
            style = MaterialTheme.typography.labelMedium,
            color = OnboardingTokens.RulerLabel,
        )
    }
}

@Composable
private fun NextButton(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .height(56.dp)
            .clip(RoundedCornerShape(percent = 50))
            .background(OnboardingTokens.NextBackground)
            .clickable(onClick = onClick)
            .padding(horizontal = 24.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelLarge,
            color = OnboardingTokens.NextText,
        )
        Spacer(Modifier.width(10.dp))
        Chevrons(color = OnboardingTokens.NextText, count = 3)
    }
}

@Composable
private fun BackButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .size(56.dp)
            .clip(CircleShape)
            .background(OnboardingTokens.Background)
            .border(1.dp, Gray200, CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Chevron(color = OnboardingTokens.Title, direction = -1)
    }
}

@Composable
private fun Chevrons(
    color: Color,
    count: Int,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(count) { Chevron(color = color, direction = 1) }
    }
}

/** Draws a single chevron; [direction] > 0 points right, otherwise left. */
@Composable
private fun Chevron(
    color: Color,
    direction: Int,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier.size(width = 6.dp, height = 11.dp)) {
        val w = size.width
        val h = size.height
        val path = Path().apply {
            if (direction >= 0) {
                moveTo(0f, 0f)
                lineTo(w, h / 2f)
                lineTo(0f, h)
            } else {
                moveTo(w, 0f)
                lineTo(0f, h / 2f)
                lineTo(w, h)
            }
        }
        drawPath(
            path = path,
            color = color,
            style = Stroke(
                width = 1.6.dp.toPx(),
                cap = StrokeCap.Round,
                join = StrokeJoin.Round,
            ),
        )
    }
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun OnboardingViewPreview() {
    LevelaTheme {
        OnboardingView()
    }
}
