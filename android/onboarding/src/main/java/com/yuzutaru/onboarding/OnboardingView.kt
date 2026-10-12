package com.yuzutaru.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme

/**
 * The Levela post-guest onboarding flow (welcome, goal, weight, height).
 *
 * Shown after the user taps **Continue as a guest** on the splash. Four steps:
 * a welcome intro, a single-select goal step, then weight and height — the
 * latter pair each using a draggable ruler picker and a unit toggle. The last
 * step reports completion through [onFinished]. Mirrors the iOS `OnboardingView`.
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
                    OnboardingStep.Goal ->
                        GoalStep(
                            selectedGoal = viewModel.goal,
                            selectGoal = viewModel::selectGoal,
                            hasGoal = viewModel.hasGoal,
                            backOnClicked = viewModel::back,
                            next = viewModel::next,
                        )
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

/**
 * The goal step: title + a scrollable list of single-select goal cards + back /
 * Next. Next stays disabled until a goal is chosen.
 */
@Composable
private fun ColumnScope.GoalStep(
    selectedGoal: String?,
    selectGoal: (String) -> Unit,
    hasGoal: Boolean,
    backOnClicked: () -> Unit,
    next: () -> Unit,
) {
    Spacer(Modifier.height(28.dp))

    Text(
        text = OnboardingTokens.GoalTitle,
        style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
        color = OnboardingTokens.Title,
        textAlign = TextAlign.Center,
    )

    Spacer(Modifier.height(20.dp))

    Column(
        modifier = Modifier
            .weight(1f)
            .fillMaxWidth()
            .verticalScroll(rememberScrollState()),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        OnboardingTokens.goals.forEach { goal ->
            GoalCard(
                title = goal.title,
                subtitle = goal.subtitle,
                isSelected = goal.title == selectedGoal,
                onClick = { selectGoal(goal.title) },
            )
        }
    }

    Spacer(Modifier.height(20.dp))

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BackButton(onClick = backOnClicked)
        Spacer(Modifier.width(12.dp))
        NextButton(
            label = OnboardingTokens.Next,
            onClick = next,
            enabled = hasGoal,
            modifier = Modifier.weight(1f),
        )
    }

    Spacer(Modifier.height(24.dp))
}

/** A single-select goal card: a status dot on the left, then title + subtitle. */
@Composable
private fun GoalCard(
    title: String,
    subtitle: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(OnboardingTokens.GoalCardCorner.dp)
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(shape)
            .background(
                if (isSelected) OnboardingTokens.GoalCardActive else OnboardingTokens.GoalCardInactive
            )
            .border(
                width = 1.dp,
                color = if (isSelected) {
                    OnboardingTokens.GoalCardActiveBorder
                } else {
                    OnboardingTokens.GoalCardInactiveBorder
                },
                shape = shape,
            )
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        GoalDot(isSelected = isSelected)
        Spacer(Modifier.width(14.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                color = OnboardingTokens.Title,
            )
            Spacer(Modifier.height(2.dp))
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodyMedium,
                color = OnboardingTokens.Subtitle,
            )
        }
    }
}

/** The goal card's status dot: filled when selected, a ring when not. */
@Composable
private fun GoalDot(
    isSelected: Boolean,
    modifier: Modifier = Modifier,
) {
    val dot = modifier
        .size(14.dp)
        .clip(CircleShape)
    Box(
        modifier = if (isSelected) {
            dot.background(OnboardingTokens.GoalDotActive)
        } else {
            dot.border(1.5.dp, OnboardingTokens.GoalDotInactive, CircleShape)
        },
    )
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
private fun GoalStepPreview() {
    LevelaTheme {
        var goal by remember { mutableStateOf<String?>("Gain muscle") }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            GoalStep(
                selectedGoal = goal,
                selectGoal = { goal = it },
                hasGoal = goal != null,
                backOnClicked = {},
                next = {},
            )
        }
    }
}
