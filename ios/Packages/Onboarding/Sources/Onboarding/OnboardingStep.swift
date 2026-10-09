import Foundation

/// The steps of the post-guest onboarding flow.
///
/// Mirrors the Android `OnboardingStep`. The step raw values must match
/// `flow.steps` in `assets/onboarding/onboarding-contract.json`
/// (enforced by `scripts/verify_onboarding_parity.sh`).
public enum OnboardingStep: String, CaseIterable, Hashable, Sendable {
    case welcome
    case weight
    case height
}
