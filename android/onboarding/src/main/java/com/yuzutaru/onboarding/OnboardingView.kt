package com.yuzutaru.onboarding

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
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

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun OnboardingViewPreview() {
    LevelaTheme {
        OnboardingView()
    }
}
