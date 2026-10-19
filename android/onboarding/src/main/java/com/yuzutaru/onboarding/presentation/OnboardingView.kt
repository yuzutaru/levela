package com.yuzutaru.onboarding.presentation

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
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.yuzutaru.design.ui.theme.LevelaTheme
import com.yuzutaru.onboarding.R
import com.yuzutaru.onboarding.presentation.model.GenderOption
import com.yuzutaru.onboarding.presentation.model.OnboardingStep
import com.yuzutaru.onboarding.presentation.model.OnboardingTokens
import com.yuzutaru.onboarding.presentation.widget.AgeWheelPicker
import com.yuzutaru.onboarding.presentation.widget.BackButton
import com.yuzutaru.onboarding.presentation.widget.NextButton
import com.yuzutaru.onboarding.presentation.widget.SkipButton
import com.yuzutaru.onboarding.presentation.widget.StepProgress
import com.yuzutaru.onboarding.presentation.widget.ValueStep
import kotlinx.coroutines.launch

/**
 * The Levela post-guest onboarding flow (welcome, goal, gender, age, weight,
 * height, activity).
 *
 * Shown after the user taps **Continue as a guest** on the splash. Seven steps:
 * a welcome intro, a single-select goal step, a gender carousel, an age wheel
 * step, then weight and height — the latter pair each using a draggable ruler
 * picker and a unit toggle — and finally a single-select activity-level step.
 * Tapping Next on the last step asks [OnboardingViewModel.complete] to persist
 * the collected profile through its use case; once saved, [onFinished] is called
 * so the host can move on. Mirrors the iOS `OnboardingView`.
 *
 * @param onFinished called once the profile has been saved on the final step.
 */
@Composable
fun OnboardingView(
    viewModel: OnboardingViewModel,
    modifier: Modifier = Modifier,
    onFinished: () -> Unit = {},
) {
    val currentOnFinished by rememberUpdatedState(onFinished)
    LaunchedEffect(viewModel.isComplete) {
        if (viewModel.isComplete) currentOnFinished()
    }
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
                    OnboardingStep.Gender ->
                        GenderStep(
                            selectedSex = viewModel.sex,
                            toggleSex = viewModel::toggleSex,
                            hasSex = viewModel.hasSex,
                            backOnClicked = viewModel::back,
                            next = viewModel::next,
                            skip = viewModel::skipSex,
                        )
                    OnboardingStep.Age ->
                        AgeStep(
                            age = viewModel.age,
                            setAge = viewModel::setAge,
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
                            onFinished = viewModel::complete,
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
                            onFinished = viewModel::complete,
                        )
                    OnboardingStep.Activity ->
                        ActivityStep(
                            selectedActivity = viewModel.activityLevel,
                            selectActivity = viewModel::selectActivity,
                            hasActivity = viewModel.hasActivity,
                            backOnClicked = viewModel::back,
                            isLastStep = viewModel.isLastStep,
                            next = viewModel::next,
                            onFinished = viewModel::complete,
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
            OptionCard(
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

/**
 * A single-select option card: a status dot on the left, then a title and an
 * optional subtitle. Shared by the goal and activity steps.
 */
@Composable
private fun OptionCard(
    title: String,
    subtitle: String?,
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
        OptionDot(isSelected = isSelected)
        Spacer(Modifier.width(14.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                color = OnboardingTokens.Title,
            )
            if (subtitle != null) {
                Spacer(Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = OnboardingTokens.Subtitle,
                )
            }
        }
    }
}

/** The option card's status dot: filled when selected, a ring when not. */
@Composable
private fun OptionDot(
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

/**
 * The gender step: title + subtitle + a single-screen carousel of three
 * toggleable gender cards + a "prefer to skip this" pill + back / Continue.
 * Continue stays disabled until a gender is chosen; tapping the selected card
 * again clears the choice, and skipping advances with the value left unset.
 */
@Composable
private fun ColumnScope.GenderStep(
    selectedSex: String?,
    toggleSex: (String) -> Unit,
    hasSex: Boolean,
    backOnClicked: () -> Unit,
    next: () -> Unit,
    skip: () -> Unit,
) {
    Spacer(Modifier.height(28.dp))

    Text(
        text = OnboardingTokens.GenderTitle,
        style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
        color = OnboardingTokens.Title,
        modifier = Modifier.fillMaxWidth(),
        textAlign = TextAlign.Start,
    )

    Spacer(Modifier.height(8.dp))

    Text(
        text = OnboardingTokens.GenderSubtitle,
        style = MaterialTheme.typography.bodyLarge,
        color = OnboardingTokens.Subtitle,
        modifier = Modifier.fillMaxWidth(),
        textAlign = TextAlign.Start,
    )

    Spacer(Modifier.height(16.dp))

    GenderCarousel(
        options = OnboardingTokens.genderOptions,
        selectedSex = selectedSex,
        toggleSex = toggleSex,
        modifier = Modifier
            .weight(1f)
            .fillMaxWidth(),
    )

    Spacer(Modifier.height(16.dp))

    SkipButton(
        label = OnboardingTokens.Skip,
        onClick = skip,
        modifier = Modifier.fillMaxWidth(),
    )

    Spacer(Modifier.height(12.dp))

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BackButton(onClick = backOnClicked)
        Spacer(Modifier.width(12.dp))
        NextButton(
            label = OnboardingTokens.ContinueLabel,
            onClick = next,
            enabled = hasSex,
            modifier = Modifier.weight(1f),
        )
    }

    Spacer(Modifier.height(24.dp))
}

/**
 * The age step: title + the age wheel + back / Next. The age always has a
 * default, so Next is always enabled.
 */
@Composable
private fun ColumnScope.AgeStep(
    age: Int,
    setAge: (Int) -> Unit,
    backOnClicked: () -> Unit,
    next: () -> Unit,
) {
    Spacer(Modifier.height(28.dp))

    Text(
        text = OnboardingTokens.AgeTitle,
        style = MaterialTheme.typography.headlineMedium.copy(fontWeight = FontWeight.Bold),
        color = OnboardingTokens.Title,
        textAlign = TextAlign.Center,
    )

    Spacer(Modifier.height(24.dp))

    AgeWheelPicker(age = age, onAgeChange = setAge)

    Spacer(Modifier.weight(1f))

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        BackButton(onClick = backOnClicked)
        Spacer(Modifier.width(12.dp))
        NextButton(
            label = OnboardingTokens.Next,
            onClick = next,
            modifier = Modifier.weight(1f),
        )
    }

    Spacer(Modifier.height(24.dp))
}

/** Test tag for the swipeable gender carousel. */
const val GenderCarouselTag: String = "onboarding:gender:carousel"

/**
 * The gender carousel: a swipeable, snapping row with the selected card centred
 * and the neighbouring cards peeking at the edges. Tapping a card toggles it and
 * scrolls it to the centre.
 */
@Composable
private fun GenderCarousel(
    options: List<GenderOption>,
    selectedSex: String?,
    toggleSex: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val initialPage = remember {
        options.indexOfFirst { it.value == selectedSex }.takeIf { it >= 0 }
            ?: (options.size / 2)
    }
    val pagerState = rememberPagerState(initialPage = initialPage, pageCount = { options.size })
    val scope = rememberCoroutineScope()

    BoxWithConstraints(
        modifier = modifier,
        contentAlignment = Alignment.Center,
    ) {
        val cardWidth = minOf(
            maxWidth * OnboardingTokens.GenderCardWidthFraction,
            maxHeight * OnboardingTokens.GenderCardAspectRatio,
        )
        val cardHeight = cardWidth / OnboardingTokens.GenderCardAspectRatio
        val horizontalPadding = (maxWidth - cardWidth) / 2f

        HorizontalPager(
            state = pagerState,
            pageSpacing = OnboardingTokens.GenderCardSpacing.dp,
            contentPadding = PaddingValues(horizontal = horizontalPadding),
            modifier = Modifier
                .fillMaxSize()
                .testTag(GenderCarouselTag),
        ) { page ->
            val option = options[page]
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center,
            ) {
                GenderCard(
                    option = option,
                    isSelected = option.value == selectedSex,
                    onClick = {
                        toggleSex(option.value)
                        scope.launch { pagerState.animateScrollToPage(page) }
                    },
                    modifier = Modifier
                        .width(cardWidth)
                        .height(cardHeight),
                )
            }
        }
    }
}

/** A single gender card: symbol + label + selection check, with a large symbol. */
@Composable
private fun GenderCard(
    option: GenderOption,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(OnboardingTokens.GenderCardCorner.dp)
    val background = if (isSelected) option.selected else option.surface
    val border = if (isSelected) option.selected else OnboardingTokens.GenderCardInactiveBorder
    val content = if (isSelected) option.onSelected else OnboardingTokens.GenderCardInactiveText
    val icon = if (isSelected) option.onSelected else option.accent
    val iconBackground = if (isSelected) {
        option.onSelected.copy(alpha = 0.20f)
    } else {
        option.accent.copy(alpha = 0.14f)
    }
    val symbolBackground = if (isSelected) {
        option.onSelected.copy(alpha = 0.16f)
    } else {
        option.accent.copy(alpha = 0.10f)
    }

    Column(
        modifier = modifier
            .clip(shape)
            .background(background)
            .border(1.dp, border, shape)
            .clickable(onClick = onClick)
            .semantics { selected = isSelected }
            .padding(18.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(iconBackground),
                contentAlignment = Alignment.Center,
            ) {
                GenderSymbol(
                    symbol = option.symbol,
                    color = icon,
                    modifier = Modifier.size(20.dp),
                )
            }

            Spacer(Modifier.width(10.dp))

            Text(
                text = option.label,
                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
                color = content,
                modifier = Modifier.weight(1f),
            )

            Spacer(Modifier.width(8.dp))

            GenderCheck(isSelected = isSelected, mark = option.accent)
        }

        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentAlignment = Alignment.Center,
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(0.82f)
                    .aspectRatio(1f)
                    .clip(CircleShape)
                    .background(symbolBackground),
            )
            GenderSymbol(
                symbol = option.symbol,
                color = icon,
                modifier = Modifier
                    .fillMaxWidth(0.46f)
                    .aspectRatio(1f),
            )
            GenderSparkles(
                color = icon.copy(alpha = 0.75f),
                modifier = Modifier.fillMaxSize(),
            )
        }
    }
}

/** The card's selection indicator: a check when selected, an empty box otherwise. */
@Composable
private fun GenderCheck(
    isSelected: Boolean,
    mark: Color,
    modifier: Modifier = Modifier,
) {
    val shape = RoundedCornerShape(8.dp)
    Box(
        modifier = modifier
            .size(26.dp)
            .clip(shape)
            .background(
                if (isSelected) OnboardingTokens.GenderCheckActive else Color.Transparent
            )
            .border(
                width = 1.dp,
                color = if (isSelected) {
                    OnboardingTokens.GenderCheckActive
                } else {
                    OnboardingTokens.GenderCheckInactiveBorder
                },
                shape = shape,
            ),
        contentAlignment = Alignment.Center,
    ) {
        if (isSelected) {
            Canvas(modifier = Modifier.size(width = 13.dp, height = 10.dp)) {
                drawLine(
                    color = mark,
                    start = Offset(0f, size.height * 0.55f),
                    end = Offset(size.width * 0.38f, size.height),
                    strokeWidth = 2.dp.toPx(),
                    cap = StrokeCap.Round,
                )
                drawLine(
                    color = mark,
                    start = Offset(size.width * 0.38f, size.height),
                    end = Offset(size.width, 0f),
                    strokeWidth = 2.dp.toPx(),
                    cap = StrokeCap.Round,
                )
            }
        }
    }
}

/** A large gender symbol drawn with strokes, so both platforms stay consistent. */
@Composable
private fun GenderSymbol(
    symbol: String,
    color: Color,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier = modifier) {
        val w = size.width
        val h = size.height
        val radius = minOf(w, h) * 0.21f
        val strokeWidth = minOf(w, h) * 0.075f
        val stroke = Stroke(width = strokeWidth, cap = StrokeCap.Round, join = StrokeJoin.Round)

        fun line(start: Offset, end: Offset) {
            drawLine(
                color = color,
                start = start,
                end = end,
                strokeWidth = strokeWidth,
                cap = StrokeCap.Round,
            )
        }

        when (symbol) {
            "female" -> {
                val cx = w * 0.5f
                val cy = h * 0.36f
                drawCircle(color = color, radius = radius, center = Offset(cx, cy), style = stroke)
                line(Offset(cx, cy + radius), Offset(cx, h * 0.92f))
                line(Offset(w * 0.28f, h * 0.78f), Offset(w * 0.72f, h * 0.78f))
            }

            "male" -> {
                val cx = w * 0.40f
                val cy = h * 0.62f
                drawCircle(color = color, radius = radius, center = Offset(cx, cy), style = stroke)
                val start = Offset(
                    cx + radius * 0.7071f,
                    cy - radius * 0.7071f,
                )
                val end = Offset(w * 0.86f, h * 0.14f)
                line(start, end)
                line(end, Offset(w * 0.62f, h * 0.14f))
                line(end, Offset(w * 0.86f, h * 0.40f))
            }

            else -> {
                val cx = w * 0.46f
                val cy = h * 0.58f
                drawCircle(color = color, radius = radius, center = Offset(cx, cy), style = stroke)
                val start = Offset(
                    cx + radius * 0.7071f,
                    cy - radius * 0.7071f,
                )
                val end = Offset(w * 0.88f, h * 0.10f)
                line(start, end)
                line(end, Offset(w * 0.66f, h * 0.10f))
                line(end, Offset(w * 0.88f, h * 0.34f))
                line(Offset(cx, cy + radius), Offset(cx, h * 0.95f))
                line(Offset(w * 0.26f, h * 0.82f), Offset(w * 0.66f, h * 0.82f))
            }
        }
    }
}

/** Small decorative dots around the central symbol, matching the reference cards. */
@Composable
private fun GenderSparkles(
    color: Color,
    modifier: Modifier = Modifier,
) {
    Canvas(modifier = modifier) {
        val radius = size.minDimension * 0.018f
        drawCircle(color, radius, Offset(size.width * 0.16f, size.height * 0.22f))
        drawCircle(color, radius * 0.75f, Offset(size.width * 0.84f, size.height * 0.32f))
        drawCircle(color, radius * 0.6f, Offset(size.width * 0.72f, size.height * 0.78f))
    }
}

/**
 * The activity step: title + a scrollable list of single-select activity-level
 * cards + back / Next. Next stays disabled until a level is chosen.
 */
@Composable
private fun ColumnScope.ActivityStep(
    selectedActivity: String?,
    selectActivity: (String) -> Unit,
    hasActivity: Boolean,
    backOnClicked: () -> Unit,
    isLastStep: Boolean,
    next: () -> Unit,
    onFinished: () -> Unit,
) {
    Spacer(Modifier.height(28.dp))

    Text(
        text = OnboardingTokens.ActivityTitle,
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
        OnboardingTokens.activityLevels.forEach { level ->
            OptionCard(
                title = level.title,
                subtitle = level.subtitle,
                isSelected = level.title == selectedActivity,
                onClick = { selectActivity(level.title) },
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
            onClick = { if (isLastStep) onFinished() else next() },
            enabled = hasActivity,
            modifier = Modifier.weight(1f),
        )
    }

    Spacer(Modifier.height(24.dp))
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun OnboardingViewPreview() {
    LevelaTheme {
        OnboardingView(
            viewModel = remember { OnboardingViewModel {} },
        )
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

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun GenderStepPreview() {
    LevelaTheme {
        var sex by remember { mutableStateOf<String?>("Male") }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            GenderStep(
                selectedSex = sex,
                toggleSex = { sex = if (sex == it) null else it },
                hasSex = sex != null,
                backOnClicked = {},
                next = {},
                skip = {},
            )
        }
    }
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun AgeStepPreview() {
    LevelaTheme {
        var age by remember { mutableStateOf(OnboardingTokens.ageDefault) }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            AgeStep(
                age = age,
                setAge = { age = it },
                backOnClicked = {},
                next = {},
            )
        }
    }
}

@Preview(showBackground = true, heightDp = 900)
@Composable
private fun ActivityStepPreview() {
    LevelaTheme {
        var activity by remember { mutableStateOf<String?>("Moderately active") }
        Column(
            modifier = Modifier.fillMaxSize().padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            ActivityStep(
                selectedActivity = activity,
                selectActivity = { activity = it },
                hasActivity = activity != null,
                backOnClicked = {},
                isLastStep = true,
                next = {},
                onFinished = {},
            )
        }
    }
}
