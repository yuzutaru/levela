import Design
import SwiftUI

/// Contract values for the post-guest onboarding flow.
///
/// Mirrors `assets/onboarding/onboarding-contract.json` and the Android
/// `OnboardingTokens`. Do not hand-edit: change the contract and run
/// `scripts/verify_onboarding_parity.sh`.
public enum OnboardingTokens {
    // Flow — steps: welcome, goal, gender, age, weight, height, activity
    public static let steps: [OnboardingStep] = [.welcome, .goal, .gender, .age, .weight, .height, .activity]

    // Copy
    public static let welcomeTitle = "Start your Fitness Journey"
    public static let welcomeSubtitle = "Start your fitness journey with our app's guidance and support"
    public static let goalTitle = "What is your goal?"
    public static let genderTitle = "What is your Gender?"
    public static let genderSubtitle = "Please select your gender for better personalized health experience."
    public static let ageTitle = "Age"
    public static let weightTitle = "What is your weight?"
    public static let heightTitle = "What is your height?"
    public static let activityTitle = "What is your activity level?"
    public static let start = "Let's start"
    public static let next = "Next"
    public static let continueLabel = "Continue"
    public static let skip = "Prefer to skip this"
    public static let back = "Back"

    // Goals — the single-select goal cards (title + subtitle).
    public static let goals: [GoalOption] = [
        GoalOption(title: "Lose fat", subtitle: "Burn fat and reveal a leaner physique"),
        GoalOption(title: "Maintain weight", subtitle: "Keep your current weight and stay consistent"),
        GoalOption(title: "Gain muscle", subtitle: "Build strength and add lean muscle"),
        GoalOption(title: "Improve health", subtitle: "Feel better and boost daily energy"),
        GoalOption(title: "Improve performance", subtitle: "Get stronger, faster and more athletic"),
        GoalOption(title: "Fast consistently", subtitle: "Stick to a regular fasting routine"),
        GoalOption(title: "Train for an event", subtitle: "Prepare for a race or competition"),
    ]

    // Gender — the single-select cards. Each carries its label, icon symbol and
    // pastel surface / saturated accent colours.
    public static let genderOptions: [GenderOption] = [
        GenderOption(
            value: "Female",
            label: "I Am Female",
            symbol: "female",
            surface: .pink100,
            accent: .pink700,
            selected: .pink700,
            onSelected: .white
        ),
        GenderOption(
            value: "Male",
            label: "I Am Male",
            symbol: "male",
            surface: .blue100,
            accent: .blue500,
            selected: .blue500,
            onSelected: .white
        ),
        GenderOption(
            value: "Prefer not to say",
            label: "Prefer not to say",
            symbol: "neutral",
            surface: .orange100,
            accent: .orange700,
            selected: .orange500,
            onSelected: .navy900
        ),
    ]

    // The persisted values, used to validate selections.
    public static let sexOptions = genderOptions.map(\.value)

    // Activity level outside workouts — the single-select cards (title + subtitle).
    public static let activityLevels: [GoalOption] = [
        GoalOption(title: "Sedentary", subtitle: "Little to no daily activity or a desk job"),
        GoalOption(title: "Lightly active", subtitle: "Light daily activity or walking 1–3 days a week"),
        GoalOption(title: "Moderately active", subtitle: "Moderate daily activity 3–5 days a week"),
        GoalOption(title: "Very active", subtitle: "Daily activity 6–7 days a week"),
        GoalOption(title: "Extra active", subtitle: "A physical job plus daily activity"),
    ]

    // Units
    public static let weightUnits = ["lb", "kg"]
    public static let heightUnits = ["ft/in", "cm"]
    public static let defaultWeightUnit = "kg"
    public static let defaultHeightUnit = "cm"
    public static let ageUnit = "years"

    // Age (single unit: years). Range/default are in years.
    public static let ageMin = 13
    public static let ageMax = 100
    public static let ageStep = 1
    public static let ageDefault = 30

    // Values (see onboarding-contract.json). Ranges/defaults are per display unit.
    public static let weightKgMin = 30
    public static let weightKgMax = 160
    public static let weightKgStep = 1
    public static let weightKgDefault = 70
    public static let weightLbMin = 66
    public static let weightLbMax = 352
    public static let weightLbStep = 1
    public static let weightLbDefault = 154
    public static let heightCmMin = 120
    public static let heightCmMax = 220
    public static let heightCmStep = 1
    public static let heightCmDefault = 170
    // Imperial height range is in total inches, displayed as feet'inches" (47–87 in = 3'11"–7'3").
    public static let heightInMin = 47
    public static let heightInMax = 87
    public static let heightInStep = 1
    public static let heightInDefault = 67

    // Colours (design-system primitives, see THEME_COLORS.md)
    public static let background = Color.white
    public static let title = Color.navy900
    public static let subtitle = Color.gray500
    public static let value = Color.navy900
    public static let activeSegment = Color.blue500
    public static let inactiveSegment = Color.gray200
    public static let rulerTick = Color.gray300
    public static let rulerLabel = Color.gray500
    public static let rulerAccent = Color.blue500
    public static let ageWheelSelectedBackground = Color.blue500
    public static let ageWheelSelectedText = Color.white
    public static let ageWheelText = Color.navy900
    public static let ageWheelFadedText = Color.gray300
    public static let cardWeight = Color.lightBlue100
    public static let cardWeightAccent = Color.lightBlue300
    public static let cardHeight = Color.blue100
    public static let cardHeightAccent = Color.blue300
    public static let nextBackground = Color.blue500
    public static let nextText = Color.white
    public static let nextDisabledBackground = Color.gray200
    public static let nextDisabledText = Color.gray500
    public static let goalCardActive = Color.blue100
    public static let goalCardActiveBorder = Color.blue500
    public static let goalCardInactive = Color.white
    public static let goalCardInactiveBorder = Color.gray200
    public static let goalDotActive = Color.blue500
    public static let goalDotInactive = Color.gray300
    public static let toggleTrack = Color.gray100
    public static let toggleSelectedBackground = Color.blue500
    public static let toggleSelectedText = Color.white
    public static let toggleUnselectedText = Color.gray500

    // Gender cards (per-option colours live on GenderOption)
    public static let genderCardInactiveText = Color.navy900
    public static let genderCardInactiveBorder = Color.gray200
    public static let genderCheckActive = Color.white
    public static let genderCheckInactiveBorder = Color.gray200
    public static let skipBackground = Color.blue100
    public static let skipText = Color.blue700

    // Layout
    public static let welcomeIllustrationCorner = 28
    public static let goalCardCorner = 20
    public static let genderCardCorner = 32
    public static let genderCardWidthFraction = 0.72
    public static let genderCardAspectRatio = 0.72
    public static let genderCardSpacing = 12
    // The age wheel: five rows tall, the middle one carrying the selected age.
    public static let ageWheelVisibleRows = 5
    public static let ageWheelRowHeight = 84
    public static let ageWheelCorner = 26
}

/// A single-select goal option: a card title and its supporting subtitle.
public struct GoalOption: Hashable, Sendable {
    public let title: String
    public let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

/// A gender card: persisted value, display label, icon symbol and card colours.
public struct GenderOption: Hashable, Sendable {
    public let value: String
    public let label: String
    public let symbol: String
    public let surface: Color
    public let accent: Color
    public let selected: Color
    public let onSelected: Color

    public init(
        value: String,
        label: String,
        symbol: String,
        surface: Color,
        accent: Color,
        selected: Color,
        onSelected: Color
    ) {
        self.value = value
        self.label = label
        self.symbol = symbol
        self.surface = surface
        self.accent = accent
        self.selected = selected
        self.onSelected = onSelected
    }
}
