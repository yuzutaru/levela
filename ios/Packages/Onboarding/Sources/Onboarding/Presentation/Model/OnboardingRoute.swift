import Foundation

/// The navigation contract for the onboarding feature.
///
/// The app owns the `NavigationStack` and only needs to know about these values,
/// never the view internals. Mirrors the Android `OnboardingRoute`.
public enum OnboardingRoute: Hashable, Sendable {
    case welcome
}
