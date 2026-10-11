package com.yuzutaru.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.Gray200
import com.yuzutaru.design.ui.theme.LevelaTheme

/**
 * The Levela post-guest onboarding flow (welcome, weight, height).
 *
 * Shown after the user taps **Continue as a guest** on the splash. Three steps:
 * a welcome intro, then weight and height — the latter pair each using a
 * draggable ruler picker and a unit toggle. The last step reports completion
 * through [onFinished]. Mirrors the iOS `OnboardingView`.
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

        AnimatedContent(
            targetState = viewModel.step,
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            transitionSpec = {
                val forward = OnboardingTokens.steps.indexOf(targetState) >
                    OnboardingTokens.steps.indexOf(initialState)
                if (forward) {
                    // Push forward: the new step enters from the right while the
                    // old one leaves to the left.
                    (slideInHorizontally { it } + fadeIn()) togetherWith
                        (slideOutHorizontally { -it } + fadeOut())
                } else {
                    // Go back: the previous step enters from the left while the
                    // current one leaves to the right.
                    (slideInHorizontally { -it } + fadeIn()) togetherWith
                        (slideOutHorizontally { it } + fadeOut())
                }
            },
            label = "onboarding-step",
        ) { step ->
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                when (step) {
                    OnboardingStep.Welcome -> WelcomeStep(onStart = viewModel::next)
                    OnboardingStep.Weight ->
                        ValueStep(
                            step = step,
                            weightUnit = viewModel.weightUnit,
                            selectWeightUnit = viewModel::selectWeightUnit,
                            heightUnit = viewModel.heightUnit,
                            selectHeightUnit = viewModel::selectHeightUnit,
                            weightDisplay = viewModel.weightDisplay,
                            setWeightDisplay = viewModel::setWeightDisplay,
                            heightDisplay = viewModel.heightDisplay,
                            heightDisplayText = viewModel.heightDisplayText,
                            setHeightDisplay = viewModel::setHeightDisplay,
                            backOnClicked = viewModel::back,
                            isLastStep = viewModel.isLastStep,
                            next = viewModel::next,
                            onFinished = onFinished
                        )
                    OnboardingStep.Height ->
                        ValueStep(
                            step = step,
                            weightUnit = viewModel.weightUnit,
                            selectWeightUnit = viewModel::selectWeightUnit,
                            heightUnit = viewModel.heightUnit,
                            selectHeightUnit = viewModel::selectHeightUnit,
                            weightDisplay = viewModel.weightDisplay,
                            setWeightDisplay = viewModel::setWeightDisplay,
                            heightDisplay = viewModel.heightDisplay,
                            heightDisplayText = viewModel.heightDisplayText,
                            setHeightDisplay = viewModel::setHeightDisplay,
                            backOnClicked = viewModel::back,
                            isLastStep = viewModel.isLastStep,
                            next = viewModel::next,
                            onFinished = onFinished
                        )
                }
            }
        }
    }
}

/** The intro step: headline + subtitle + hero illustration + a primary "Let's start" button. */
@Composable
private fun ColumnScope.WelcomeStep(onStart: () -> Unit) {
    Spacer(Modifier.height(48.dp))

    Text(
        text = OnboardingTokens.WelcomeTitle,
        style = MaterialTheme.typography.headlineLarge.copy(fontWeight = FontWeight.Bold),
        color = OnboardingTokens.Title,
        textAlign = TextAlign.Center,
    )

    Spacer(Modifier.height(12.dp))

    Text(
        text = OnboardingTokens.WelcomeSubtitle,
        style = MaterialTheme.typography.bodyLarge,
        color = OnboardingTokens.Subtitle,
        textAlign = TextAlign.Center,
    )

    Spacer(Modifier.height(24.dp))

    Image(
        painter = painterResource(R.drawable.welcome_illustration),
        contentDescription = null,
        contentScale = ContentScale.Fit,
        modifier = Modifier
            .weight(1f, fill = false)
            .aspectRatio(1f)
            .clip(RoundedCornerShape(OnboardingTokens.WelcomeIllustrationCorner.dp)),
    )

    Spacer(Modifier.height(16.dp))

    NextButton(
        label = OnboardingTokens.Start,
        onClick = onStart,
        showChevrons = false,
        modifier = Modifier.fillMaxWidth(),
    )

    Spacer(Modifier.height(24.dp))
}

/** A weight or height step: title + unit toggle + value card + back / Next. */
@Composable
private fun ColumnScope.ValueStep(
    step: OnboardingStep,
    weightUnit: String,
    selectWeightUnit: (String) -> Unit,
    heightUnit: String,
    selectHeightUnit: (String) -> Unit,
    weightDisplay: Int,
    setWeightDisplay: (Int) -> Unit,
    heightDisplay: Int,
    heightDisplayText: String,
    setHeightDisplay: (Int) -> Unit,
    backOnClicked: () -> Unit,
    isLastStep: Boolean,
    next: () -> Unit,
    onFinished: () -> Unit,
) {
    Spacer(Modifier.height(28.dp))

    Text(
        text = when (step) {
            OnboardingStep.Welcome -> OnboardingTokens.WelcomeTitle
            OnboardingStep.Weight -> OnboardingTokens.WeightTitle
            OnboardingStep.Height -> OnboardingTokens.HeightTitle
        },
        style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
        color = OnboardingTokens.Title,
        textAlign = TextAlign.Center,
    )

    Spacer(Modifier.height(20.dp))

    when (step) {
        OnboardingStep.Weight -> UnitToggle(
            units = OnboardingTokens.weightUnits,
            selected = weightUnit,
            onSelect = selectWeightUnit,
        )

        else -> UnitToggle(
            units = OnboardingTokens.heightUnits,
            selected = heightUnit,
            onSelect = selectHeightUnit,
        )
    }

    Spacer(Modifier.height(28.dp))

    when (step) {
        OnboardingStep.Weight -> ValueCard(
            value = weightDisplay,
            displayText = weightDisplay.toString(),
            unit = weightUnit,
            scale = weightScale(weightUnit),
            onValueChange = setWeightDisplay,
            background = OnboardingTokens.CardWeight,
            accent = OnboardingTokens.CardWeightAccent,
        )

        else -> ValueCard(
            value = heightDisplay,
            displayText = heightDisplayText,
            unit = heightUnit,
            scale = heightScale(heightUnit),
            onValueChange = setHeightDisplay,
            background = OnboardingTokens.CardHeight,
            accent = OnboardingTokens.CardHeightAccent,
        )
    }

    Spacer(Modifier.weight(1f))

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BackButton(onClick = backOnClicked)
        Spacer(Modifier.width(12.dp))
        NextButton(
            label = OnboardingTokens.Next,
            onClick = {
                if (isLastStep) onFinished() else next()
            },
            modifier = Modifier.weight(1f),
        )
    }

    Spacer(Modifier.height(24.dp))
}

/** The tick scale for a value card, in the currently displayed unit. */
private data class Scale(
    val start: Int,
    val end: Int,
    val step: Int,
    val majorEvery: Int = 10,
    val label: (Int) -> String = { it.toString() },
)

private fun weightScale(unit: String): Scale = when (unit) {
    "lb" -> Scale(OnboardingTokens.weightLbMin, OnboardingTokens.weightLbMax, OnboardingTokens.weightLbStep)
    else -> Scale(OnboardingTokens.weightKgMin, OnboardingTokens.weightKgMax, OnboardingTokens.weightKgStep)
}

private fun heightScale(unit: String): Scale = when (unit) {
    "cm" -> Scale(OnboardingTokens.heightCmMin, OnboardingTokens.heightCmMax, OnboardingTokens.heightCmStep)
    else -> Scale(
        OnboardingTokens.heightInMin,
        OnboardingTokens.heightInMax,
        OnboardingTokens.heightInStep,
        // A label on every foot boundary (total inches), e.g. 60 → 5'0".
        majorEvery = 12,
        label = ::formatFtIn,
    )
}

@Composable
private fun ValueCard(
    value: Int,
    displayText: String,
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
            text = displayText,
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
            majorEvery = scale.majorEvery,
            labelFormatter = scale.label,
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
    showChevrons: Boolean = true,
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
        if (showChevrons) {
            Spacer(Modifier.width(10.dp))
            Chevrons(color = OnboardingTokens.NextText, count = 3)
        }
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

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun ValueStepWeightPreview() {
    LevelaTheme {
        var weightUnit by remember { mutableStateOf(OnboardingTokens.defaultWeightUnit) }
        var heightUnit by remember { mutableStateOf(OnboardingTokens.defaultHeightUnit) }
        var weightDisplay by remember { mutableIntStateOf(OnboardingTokens.weightKgDefault) }
        var heightDisplay by remember { mutableIntStateOf(OnboardingTokens.heightCmDefault) }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ValueStep(
                step = OnboardingStep.Weight,
                weightUnit = weightUnit,
                selectWeightUnit = { weightUnit = it },
                heightUnit = heightUnit,
                selectHeightUnit = { heightUnit = it },
                weightDisplay = weightDisplay,
                setWeightDisplay = { weightDisplay = it },
                heightDisplay = heightDisplay,
                heightDisplayText = heightDisplay.toString(),
                setHeightDisplay = { heightDisplay = it },
                backOnClicked = {},
                isLastStep = false,
                next = {},
                onFinished = {},
            )
        }
    }
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun ValueStepHeightPreview() {
    LevelaTheme {
        var weightUnit by remember { mutableStateOf(OnboardingTokens.defaultWeightUnit) }
        var heightUnit by remember { mutableStateOf(OnboardingTokens.defaultHeightUnit) }
        var weightDisplay by remember { mutableIntStateOf(OnboardingTokens.weightKgDefault) }
        var heightDisplay by remember { mutableIntStateOf(OnboardingTokens.heightCmDefault) }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ValueStep(
                step = OnboardingStep.Height,
                weightUnit = weightUnit,
                selectWeightUnit = { weightUnit = it },
                heightUnit = heightUnit,
                selectHeightUnit = { heightUnit = it },
                weightDisplay = weightDisplay,
                setWeightDisplay = { weightDisplay = it },
                heightDisplay = heightDisplay,
                heightDisplayText = heightDisplay.toString(),
                setHeightDisplay = { heightDisplay = it },
                backOnClicked = {},
                isLastStep = true,
                next = {},
                onFinished = {},
            )
        }
    }
}
