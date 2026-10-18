package com.yuzutaru.onboarding.presentation.widget

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.presentation.model.OnboardingStep
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import com.yuzutaru.onboarding.presentation.formatFtIn

/** A weight or height step: title + unit toggle + value card + back / Next. */
@Composable
internal fun ColumnScope.ValueStep(
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
            OnboardingStep.Goal -> OnboardingTokens.GoalTitle
            OnboardingStep.Gender -> OnboardingTokens.GenderTitle
            OnboardingStep.Age -> OnboardingTokens.AgeTitle
            OnboardingStep.Weight -> OnboardingTokens.WeightTitle
            OnboardingStep.Height -> OnboardingTokens.HeightTitle
            OnboardingStep.Activity -> OnboardingTokens.ActivityTitle
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
