import Design
import SwiftUI

/// Contract values for the post-guest onboarding flow.
///
/// Mirrors `assets/onboarding/onboarding-contract.json` and the Android
/// `OnboardingTokens`. Do not hand-edit: change the contract and run
/// `scripts/verify_onboarding_parity.sh`.
public enum OnboardingTokens {
    // Flow — steps: weight, height
    public static let steps: [OnboardingStep] = [.welcome, .weight, .height]

    // Copy
    public static let welcomeTitle = "Start your Fitness Journey"
    public static let welcomeSubtitle = "Start your fitness journey with our app's guidance and support"
    public static let weightTitle = "What is your weight?"
    public static let heightTitle = "What is your height?"
    public static let start = "Let's start"
    public static let next = "Next"
    public static let back = "Back"

    // Units
    public static let weightUnits = ["lb", "kg"]
    public static let heightUnits = ["inches", "cm"]
    public static let defaultWeightUnit = "kg"
    public static let defaultHeightUnit = "cm"

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
    public static let cardWeight = Color.lightBlue100
    public static let cardWeightAccent = Color.lightBlue300
    public static let cardHeight = Color.blue100
    public static let cardHeightAccent = Color.blue300
    public static let nextBackground = Color.blue500
    public static let nextText = Color.white
    public static let toggleTrack = Color.gray100
    public static let toggleSelectedBackground = Color.blue500
    public static let toggleSelectedText = Color.white
    public static let toggleUnselectedText = Color.gray500

    // Layout
    public static let welcomeIllustrationCorner = 28
}
